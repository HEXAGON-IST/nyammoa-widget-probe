"""Observe actual SpringBoard/notification hosts; no artifact/cache upload."""
from pathlib import Path
import base64,json,os,subprocess,tempfile

def call(command,timeout=90):
    print('HOST_COMMAND '+json.dumps(command),flush=True)
    return subprocess.check_output(command,text=True,timeout=timeout).strip()

def sim(*args,timeout=90):return call(['xcrun','simctl',*args],timeout)

def image(path):
    print('PROBE_PNG_BEGIN '+path.name,flush=True)
    data=base64.b64encode(path.read_bytes()).decode()
    for start in range(0,len(data),3000):print('PROBE_PNG_DATA '+data[start:start+3000],flush=True)
    print('PROBE_PNG_END '+path.name,flush=True)

folder=Path(tempfile.mkdtemp(prefix='nyammoa-host-',dir=os.environ['RUNNER_TEMP']))
signing=os.environ.get('PROBE_SIGNING','adhoc-local')
tests=os.environ.get('PROBE_TESTS','all')
assert tests in ('all','notifications'), 'Unknown host test scope'
test_flags=['-only-testing:ProbeHostTests/ProbeHostTests/test02NotificationHosts'] if tests=='notifications' else []
assert signing in ('unsigned','adhoc-local'), 'Unknown simulator signing mode'
signing_flags=(['CODE_SIGNING_ALLOWED=NO','CODE_SIGNING_REQUIRED=NO'] if signing=='unsigned' else
    ['CODE_SIGNING_ALLOWED=YES','CODE_SIGNING_REQUIRED=YES','CODE_SIGN_IDENTITY=-',
     'CODE_SIGN_STYLE=Manual','DEVELOPMENT_TEAM=','PROVISIONING_PROFILE_SPECIFIER='])
print('PROBE_SIGNING_MODE '+signing,flush=True)
sdk=call(['xcrun','--sdk','iphonesimulator','--show-sdk-version'])
runtimes=json.loads(sim('list','runtimes','--json'))['runtimes']
runtime=next(r for r in runtimes if r.get('isAvailable') and 'iOS' in r['identifier'] and r['version']==sdk)
device=sim('create','NYAMMOA-host-I09','com.apple.CoreSimulator.SimDeviceType.iPhone-16',runtime['identifier'])
exit_code=1;result_bundle=folder/'result.xcresult'
try:
    sim('boot',device);sim('bootstatus',device,'-b',timeout=180)
    command=['xcodebuild','-project','ios/MoaVisualProbe.xcodeproj','-scheme','MoaHostChecks',
        '-configuration','Debug','-sdk','iphonesimulator','-destination','platform=iOS Simulator,id='+device,
        '-derivedDataPath',str(folder/'build'),'-resultBundlePath',str(result_bundle),
        '-parallel-testing-enabled','NO',*test_flags,*signing_flags,'test']
    with (folder/'test.log').open('w') as log:
        try:exit_code=subprocess.run(command,stdout=log,stderr=subprocess.STDOUT,timeout=780).returncode
        except subprocess.TimeoutExpired:print('HOST_TEST_TIMEOUT',flush=True)
    print((folder/'test.log').read_text(errors='replace'),flush=True)
finally:
    for bundle in sorted((folder/'build'/'Build'/'Products').glob('Debug-iphonesimulator/*.app')):
        result=subprocess.run(['codesign','-dvv',str(bundle)],capture_output=True,text=True,timeout=30)
        print('PROBE_SIGNATURE '+json.dumps({'bundle':bundle.name,'mode':signing,
            'exitCode':result.returncode,'details':result.stdout+result.stderr}),flush=True)
    try:
        print('PROBE_EXTENSION_LOG '+sim('spawn',device,'log','show','--last','8m','--style','compact',
            '--predicate','process == "MoaNotification" OR process == "MoaWidget" OR eventMessage CONTAINS "com.nyammoa.visualprobe"',timeout=60),flush=True)
    except (subprocess.CalledProcessError,subprocess.TimeoutExpired):print('EXTENSION_LOG_UNAVAILABLE',flush=True)
    if result_bundle.exists():
        exports=folder/'attachments'
        try:
            call(['xcrun','xcresulttool','export','attachments','--path',str(result_bundle),'--output-path',str(exports)],120)
            for path in sorted(exports.rglob('*.png')):image(path)
            for path in sorted(exports.rglob('*.json')):
                print('PROBE_ATTACHMENT_MANIFEST '+path.read_text(),flush=True)
            print('PROBE_XCTEST_SUMMARY '+call(['xcrun','xcresulttool','get','test-results','summary','--path',str(result_bundle)],60),flush=True)
        except (subprocess.CalledProcessError,subprocess.TimeoutExpired) as error:
            print('ATTACHMENT_EXPORT_UNVERIFIED '+str(error),flush=True)
    try:sim('shutdown',device)
    except (subprocess.CalledProcessError,subprocess.TimeoutExpired):print('OWNED_SIMULATOR_SHUTDOWN_FAILED',flush=True)
    print('PROBE_HOST_RUN '+json.dumps({'model':'iPhone 16','runtime':runtime['identifier'],'testExitCode':exit_code,'signing':signing,'testScope':tests,
        'visualAcceptance':'REQUIRES_LOCAL_SCREENSHOT_REVIEW','originalMedia':'NOT_INCLUDED','artwork':'APPROVED_ICON_AND_MOA','mediaSlot':'SYNTHETIC_PLACEHOLDER_NOT_X_OR_YOUTUBE'}),flush=True)
raise SystemExit(exit_code)
