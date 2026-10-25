"""Read generated metadata and compiler const-values without a Simulator/UI run."""
from pathlib import Path
import json,os,subprocess,tempfile
folder=Path(tempfile.mkdtemp(prefix='nyammoa-metadata-',dir=os.environ['RUNNER_TEMP']))
command=['xcodebuild','-project','ios/MoaVisualProbe.xcodeproj','-scheme','MoaVisualProbe',
    '-configuration','Debug','-sdk','iphonesimulator','-destination','generic/platform=iOS Simulator',
    '-derivedDataPath',str(folder),'CODE_SIGNING_ALLOWED=NO','CODE_SIGNING_REQUIRED=NO','build']
result=subprocess.run(command,capture_output=True,text=True,timeout=600)
print(result.stdout);print(result.stderr)
if result.returncode:raise SystemExit(result.returncode)
for name in ['MoaVisualProbe.app','MoaVisualProbe.app/PlugIns/MoaWidget.appex']:
    bundle=folder/'Build/Products/Debug-iphonesimulator'/name
    for path in sorted((bundle/'Metadata.appintents').rglob('*')):
        if not path.is_file():continue
        raw=path.read_bytes()
        try:value=json.loads(raw)
        except (UnicodeDecodeError,json.JSONDecodeError):value={'bytes':len(raw),'format':'NON_JSON'}
        print('PROBE_GENERATED_METADATA '+json.dumps({'bundle':name,'file':path.name,'value':value}))
for path in folder.rglob('*.swiftconstvalues'):
    if 'ProbeIntents' not in path.name:continue
    print('PROBE_CONST_VALUES '+json.dumps({'file':str(path.relative_to(folder)),'value':json.loads(path.read_text())}))
print('PROBE_METADATA_BUILD_ONLY '+json.dumps({'appLaunch':'NOT_RUN','hostAcceptance':'NOT_TESTED'}))
