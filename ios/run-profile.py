"""Exact installed profiles only. App launch is not widget host acceptance."""
from pathlib import Path
import argparse,base64,json,platform,subprocess
parser=argparse.ArgumentParser()
parser.add_argument('--only',required=True)
parser.add_argument('--app',type=Path,required=True)
parser.add_argument('--runtime',required=True)
parser.add_argument('--output',type=Path,required=True)
parser.add_argument('--emit-screenshots',action='store_true')
args=parser.parse_args()
assert platform.system()=='Darwin','Mac/Xcode only'
assert args.app.is_dir() and args.app.suffix=='.app'
ledger=json.loads((Path(__file__).resolve().parent.parent/'device-execution-matrix.json').read_text())
def sim(*parts):
    print(json.dumps({'simctl':parts}),flush=True)
    return subprocess.check_output(['xcrun','simctl',*parts],text=True,timeout=180 if parts[0]=='bootstatus' else 90).strip()
def emit(path):
    print('PROBE_PNG_BEGIN '+path.name,flush=True)
    encoded=base64.b64encode(path.read_bytes()).decode()
    for start in range(0,len(encoded),3000):print('PROBE_PNG_DATA '+encoded[start:start+3000],flush=True)
    print('PROBE_PNG_END '+path.name,flush=True)
types=json.loads(sim('list','devicetypes','--json'))['devicetypes']
runtimes=json.loads(sim('list','runtimes','--json'))['runtimes']
runtime=next((r for r in runtimes if r['identifier']==args.runtime and r.get('isAvailable')),None)
assert runtime,'Installed runtime required; downloads forbidden'
row=next(r for r in ledger['devices'] if r['id']==args.only and r['platform']=='iOS')
args.output.mkdir(parents=True,exist_ok=False)
result={'id':row['id'],'model':row['model'],'runtime':args.runtime,'appLaunch':'NOT_RUN','hostSurfaces':'NOT_TESTED'}
matching=[t for t in types if t['name'].casefold()==row['model'].casefold()]
supported=runtime.get('supportedDeviceTypes');owned=None
try:
    if len(matching)!=1:result['appLaunch']='UNAVAILABLE_DEVICE_TYPE'
    elif supported is not None and matching[0]['identifier'] not in {t['identifier'] for t in supported}:
        result['appLaunch']='UNAVAILABLE_IN_INSTALLED_RUNTIME'
    else:
        owned=sim('create','NYAMMOA-v25-'+row['id'],matching[0]['identifier'],args.runtime)
        result['ownedSimulator']=owned
        sim('boot',owned);sim('bootstatus',owned,'-b')
        sim('install',owned,str(args.app.resolve()))
        result['launchOutput']=sim('launch',owned,'com.nyammoa.visualprobe')
        result['appLaunch']='APP_LAUNCH_OBSERVED_ONLY'
        screenshot=args.output/(row['id']+'-app.png')
        sim('io',owned,'screenshot',str(screenshot));result['screenshot']='CAPTURED'
        if args.emit_screenshots:emit(screenshot)
except subprocess.CalledProcessError as error:
    result['appLaunch']='EXECUTION_FAILED';result['exitCode']=error.returncode
except subprocess.TimeoutExpired as error:
    result['appLaunch']='COMMAND_TIMEOUT';result['command']=error.cmd
finally:
    if owned:
        try:sim('shutdown',owned)
        except (subprocess.CalledProcessError,subprocess.TimeoutExpired):result['shutdown']='FAILED'
    (args.output/'matrix-results.json').write_text(json.dumps([result],indent=2)+'\n')
    print('PROBE_RESULT '+json.dumps(result),flush=True)
raise SystemExit(0 if result['appLaunch']=='APP_LAUNCH_OBSERVED_ONLY' else 1)
