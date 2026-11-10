# [Bug] OOM Crash - 메모리 한도 상향으로 종료 지연, MemoryGuard 자체 종료 반복

실험 환경: Ubuntu 26.04.1 LTS / WSL2 / x86_64 / 일반 사용자 jae0608(UID 1000). 커널은 6.18.58.1-microsoft-standard-WSL2입니다. 실험일은 **2026-11-10 KST(UTC+09:00)**입니다.

환경 출처는 [백업 시점 환경 기록](../environment-at-backup.txt)입니다. 이 파일은 20:16:42에 수집됐으므로 메모리 여유량 등을 장애 발생 순간의 값으로 인용하지 않습니다. 아래 수치는 10월 9일 기존 보고서와 구분한 이번 재실습의 값입니다. 바이너리 디컴파일·리버스 엔지니어링은 수행하지 않았습니다.

## 1. Description (현상 설명)

일반 사용자로 앱을 실행해 부팅 검사6개를 통과한 뒤, 앱 내부 Current Heap과 OS의 RSS가 증가했습니다. MEMORY_LIMIT=128에서는 내부150MB, 256에서는275MB에서 MemoryGuard가 한도 초과와 자체 종료를 기록했습니다.

한도 변경 효과를 확인하기 위해 **MEMORY_LIMIT만128→256MB로 변경**했습니다. CPU_MAX_OCCUPY=100과 MULTI_THREAD_ENABLE=false는 고정했습니다. 128/256은 허용 범위50~512MB 안의 비교값이며 모든 서버의 권장 운영값을 뜻하지 않습니다.

| 항목 | Before: 128MB | After: 256MB |
|---|---:|---:|
| 작업 PID | 11373 | 11834 |
| 앱 시작 로그 | 19:36:36.661 | 19:39:40.578 |
| MemoryGuard 종료 요청 | 19:36:53.846 | 19:40:12.933 |
| 로그 기준 생존 시간 | 17.185초 | 32.355초 |
| 최초 관측 RSS | 18,392KiB | 18,452KiB |
| 관측 최대 RSS | 146,412KiB | 274,492KiB |
| 내부 종료 시 메모리 값 | 150MB | 275MB |
| 작업 자식 CSV 표본 수 | 17 | 33 |
| 종료 코드 | 137 | 137 |

## 2. Evidence & Logs (증거 자료)

### 재현 및 수집 경로

1. 제공 x86 바이너리를 /home/jae0608/agent-b42-practice/agent-leak-app에 준비하고 소유자 실행 권한을 확인했습니다.
2. 일반 사용자, 필수 환경변수, 업로드·키·로그 디렉터리, 테스트 키와 포트15034를 확인했습니다.
3. 실행별 증거 폴더를 만들고 settings.txt에 조건을 저장했습니다.
4. 앱 실행 직후 부모와 자식을 찾아 각각 monitor.sh로 관제했습니다. wait 직후 종료 상태를 저장하고 종료 후 ps를 보존했습니다.
5. 한도만256으로 변경하고 같은 수집 절차를 반복했습니다.

아래는 실행 당시 구문의 요약입니다. RUN_DIR와 앱·자식 PID 준비를 전제로 하며 독립 실행용 전체 스크립트는 아닙니다.

```bash
source ./env.sh
export MEMORY_LIMIT=128       # After 실행에서는256
export CPU_MAX_OCCUPY=100
export MULTI_THREAD_ENABLE=false
./agent-leak-app > "$RUN_DIR/app.log" 2>&1 &
APP_PID=$!
# pgrep -P로 자식도 찾아 각 PID를 관제했습니다.
./monitor.sh "$APP_PID" > "$RUN_DIR/monitor-$APP_PID.csv" &
```

사용한 [env.sh](../scripts/env.sh)와 [monitor.sh](../scripts/monitor.sh)를 보존했습니다. env.sh는 초기128/100/false 설정이므로 각 실행의 적용값은 settings.txt와 부팅 로그로 대조합니다.

### 메모리 상승 수치

128MB 작업 자식의 실제 CSV 중 처음과 끝부분입니다. 중간 행은 생략했습니다.

```csv
timestamp,pid,ppid,elapsed_s,cpu_avg_pct,mem_pct,rss_kib,threads,state
2026-11-10T19:36:36+09:00,11373,11329,0,33.3,0.2,18392,1,SN
2026-11-10T19:36:50+09:00,11373,11329,14,0.9,1.8,146412,1,SN
2026-11-10T19:36:51+09:00,11373,11329,15,0.9,1.8,146412,1,SN
2026-11-10T19:36:52+09:00,11373,11329,16,0.8,1.8,146412,1,SN
```

RSS 열이18,392→146,412KiB로 증가했습니다. 256MB 실행의 관측 최대는274,492KiB입니다. RSS는 실제 RAM에 상주하는 프로세스 메모리이고 Current Heap은 앱 내부 지표입니다. 서로 같은 값으로 취급하지 않습니다.

원본: [128MB CSV](../evidence/oom-128-20261110-193545/monitor-11373.csv), [256MB CSV](../evidence/oom-256-20261110-193915/monitor-11834.csv), [128MB 설정](../evidence/oom-128-20261110-193545/settings.txt), [256MB 설정](../evidence/oom-256-20261110-193915/settings.txt).

### 종료 직전 로그

Before 원본에서 종료 직전3줄을 발췌했습니다.

```text
2026-11-10 19:36:53,845 [INFO] [MemoryWorker] Current Heap: 150MB
2026-11-10 19:36:53,846 [CRITICAL] [MemoryGuard] Memory limit exceeded (150MB >= 128MB) / (Recommend Over 256MB)
2026-11-10 19:36:53,846 [CRITICAL] [MemoryGuard] Self-terminating process 11373 to prevent system instability.
```

After 원본의 해당 구간입니다.

```text
2026-11-10 19:40:12,933 [INFO] [MemoryWorker] Current Heap: 275MB
2026-11-10 19:40:12,933 [CRITICAL] [MemoryGuard] Memory limit exceeded (275MB >= 256MB) / (Recommend Over 256MB)
2026-11-10 19:40:12,933 [CRITICAL] [MemoryGuard] Self-terminating process 11834 to prevent system instability.
```

원본: [128MB 앱 로그](../evidence/oom-128-20261110-193545/app.log), [256MB 앱 로그](../evidence/oom-256-20261110-193915/app.log).

두 실행의 종료 후 ps에는 제목만 남았습니다. 시작 시점에는 부모·자식 관계가 존재했습니다. [Before 시작 상태](../evidence/oom-128-20261110-193545/ps-start.txt), [Before 종료 후](../evidence/oom-128-20261110-193545/ps-after.txt), [After 종료 후](../evidence/oom-256-20261110-193915/ps-after.txt), [Before 종료 코드](../evidence/oom-128-20261110-193545/exit-code.txt), [After 종료 코드](../evidence/oom-256-20261110-193915/exit-code.txt).

## 3. Root Cause Analysis (원인 분석)

**확인한 직접 종료 원인:** RSS 증가, 앱의 Memory limit exceeded, 같은 작업 PID에 대한 Self-terminating 기록, 종료 후 PID 부재를 함께 확인했습니다. 따라서 앱 내부 MemoryGuard의 메모리 보호 종료로 판단합니다.

앱 내부 값은25MB 단위로 증가해128을 정확히 찍지 않고125→150, 256에서는250→275 단계에서 한도를 넘었습니다. Recommend Over 256MB는256초과 권고이므로256자체에서도 경고가 남지만 부팅 실패는 아닙니다.

**메모리 원리와 추론:** 프로세스 주소 공간에는 코드·데이터·힙·스택 등이 있습니다. 보관 데이터나 할당 참조가 계속 늘면 힙과 상주 메모리가 증가할 수 있습니다. 이런 증가가 지속되면 다른 프로세스가 사용할 RAM이 줄고 페이지 회수·스왑 등으로 지연이 생길 수 있습니다. 다만 이번 자료로 정확한 내부 자료구조나 해제 누락 위치는 확정하지 않았습니다.

**지표·종료 상태의 한계:** 1초대기 관제는 종료 직전 순간을 놓칠 수 있어 표의 값은 관측 최대 RSS입니다. After 마지막 표본에 RSS 0과 RN이 있으나, 종료와 가까운 한 행만으로 정상 회수·문제 해결을 주장하지 않습니다. 정확히0이 표시된 원인은 미확인입니다. 종료 코드137은Bash의128+시그널번호 규칙에서SIGKILL(9) 해석과 일치하며, 커널 OOM Killer가 개입했다는 단독 증거는 아닙니다.

## 4. Workaround & Verification (조치 및 검증)

MEMORY_LIMIT을128→256MB로 높이자 생존 시간이17.185→32.355초로 **15.170초 연장(약1.88배)**됐습니다. 시작 기준은 Agent listening, 종료 기준은 MemoryGuard의 종료 요청 로그입니다. 폴더 생성 시각이나 OS가 완전히 종료한 순간으로 계산하지 않았습니다.

그러나 두 번째 실행도 RSS 증가와 같은 보호 종료가 반복됐습니다. **한도 상향은 종료 지연을 위한 임시 조치이며 근본 해결로 판단하지 않습니다.** 근본 대응으로는 데이터 보관량·캐시 크기 제한, 만료·회수 정책, 참조 유지 분석과 소스 접근이 가능한 개발자의 할당 분석을 제안합니다.

별도512/40/false 실행의 메모리 회수 로그는 다른 실행 경로의 관측입니다. 이를 이번128/256 단일 변수 비교의 결과로 섞지 않습니다.

### 평가 설명 문장

“메모리 증가와 한도 초과·자체 종료 로그를 연결했습니다. 한도를 높여15.170초 더 생존했지만 같은 종료가 반복돼 임시 조치로 판단했습니다.”
