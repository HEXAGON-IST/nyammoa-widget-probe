"""Mac의 설치된 Simulator만 사용한다. 앱 실행 확인과 위젯/알림 수용은 별개다."""
from pathlib import Path
import argparse,subprocess,platform,json,re,time
parser=argparse.ArgumentParser();parser.add_argument('--only',default='ALL');parser.add_argument('--app',type=Path,required=True);parser.add_argument('--runtime',required=True);parser.add_argument('--output',type=Path,required=True);args=parser.parse_args()
assert platform.system()=='Darwin','Mac/Xcode only; no Windows emulation fallback'
assert args.app.is_dir() and args.app.suffix=='.app','Already built simulator app required'
P=Path(__file__).resolve().parent;ledger=json.loads((P.parent/'device-execution-matrix.json').read_text(encoding='utf-8'))
def sim(*parts):
 print(json.dumps({'simctl':list(parts)},ensure_ascii=False),flush=True)
 return subprocess.check_output(['xcrun','simctl',*parts],text=True,encoding='utf-8',timeout=180 if parts[0]=='bootstatus' else 90).strip()
types=json.loads(sim('list','devicetypes','--json'))['devicetypes'];runtimes=json.loads(sim('list','runtimes','--json'))['runtimes']
assert any(r['identifier']==args.runtime and r.get('isAvailable') for r in runtimes),'Installed available runtime identifier required; no download'
args.output.mkdir(parents=True,exist_ok=False);results=[]
for row in ledger['devices']:
 if row['platform']!='iOS' or (args.only!='ALL' and row['id']!=args.only):continue
 result={'id':row['id'],'model':row['model'],'runtime':args.runtime,'appLaunch':'NOT_RUN','widgetAndNotificationCells':'NOT_TESTED_REQUIRES_HOST_OBSERVATION'}
 matching=[t for t in types if t['name'].casefold()==row['model'].casefold()]
 if len(matching)!=1:result['appLaunch']='UNAVAILABLE_DEVICE_TYPE';results.append(result);continue
 print(json.dumps({'startingModel':row['model'],'id':row['id']}),flush=True)
 owned=None
 try:
  owned=sim('create','NYAMMOA-v25-'+row['id'],matching[0]['identifier'],args.runtime);result['ownedSimulator']=owned
  sim('boot',owned);sim('bootstatus',owned,'-b');sim('install',owned,str(args.app.resolve()))
  result['launchOutput']=sim('launch',owned,'com.nyammoa.visualprobe');result['appLaunch']='APP_LAUNCH_OBSERVED_ONLY'
  sim('io',owned,'screenshot',str((args.output/(row['id']+'-app.png')).resolve()))
 except subprocess.CalledProcessError as error:
  result['appLaunch']='EXECUTION_FAILED';result['exitCode']=error.returncode
  print(json.dumps(result),flush=True)
  results.append(result)
  (args.output/'matrix-results.json').write_text(json.dumps(results,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
  raise
 except subprocess.TimeoutExpired as error:
  result['appLaunch']='COMMAND_TIMEOUT';result['command']=error.cmd
 finally:
  if owned:
   try:sim('shutdown',owned)
   except (subprocess.CalledProcessError,subprocess.TimeoutExpired):result['shutdown']='FAILED_CHECK_MANUALLY'
 results.append(result)
 print(json.dumps(result,ensure_ascii=False),flush=True)
 (args.output/'matrix-results.json').write_text(json.dumps(results,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
print(json.dumps({'appLaunches':sum(r['appLaunch']=='APP_LAUNCH_OBSERVED_ONLY' for r in results),'widgetAndNotificationAcceptance':'NOT_TESTED'},ensure_ascii=False))

assert results and all(r['appLaunch']=='APP_LAUNCH_OBSERVED_ONLY' for r in results), 'Missing, unavailable or failed models are not a passing launch check'
