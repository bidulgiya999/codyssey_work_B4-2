# [Bug] OOM Crash - 메모리 한도 상향으로 종료 지연, MemoryGuard 자체 종료 반복

실험 환경: Ubuntu 26.04.1 LTS / WSL2 / x86_64 / 일반 사용자 jae0608(UID 1000). 커널은 6.18.58.1-microsoft-standard-WSL2입니다. 실험일은 **2026-11-10 KST(UTC+09:00)**입니다.

환경 출처는 [백업 시점 환경 기록](../environment-at-backup.txt)입니다. 이 파일은 20:16:42에 수집됐으므로 메모리 여유량 등을 장애 발생 순간의 값으로 인용하지 않습니다. 아래 수치는 10월 9일 기존 보고서와 구분한 이번 재실습의 값입니다. 바이너리 디컴파일·리버스 엔지니어링은 수행하지 않았습니다.

**처음 읽는 순서:** 아래 비교 표 → 실행 코드와 바로 밑의 **코드 해석** → CSV·로그의 **출력 해석** → 원인 → 조치입니다. `bash` 상자는 입력한 명령의 요약, `csv`·`text` 상자는 실제 출력 발췌입니다. 출력 자체를 터미널 명령으로 다시 입력하지 않습니다. [용어집](../glossary.md)에서 [OS](../glossary.md#os), [RSS](../glossary.md#rss), [Current Heap](../glossary.md#current-heap), [MemoryGuard](../glossary.md#memoryguard)를 클릭해 뜻을 확인할 수 있습니다.

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

### 코드 해석 — 왜 이렇게 입력했나요?

| 코드 | 하는 일 | 이번에 필요한 이유 |
|---|---|---|
| `source ./env.sh` | 현재 디렉터리의 설정 파일을 현재 Bash에서 실행합니다. | 앱에 필요한 경로·포트·기본값을 현재 터미널에 적용합니다. `cat`은 내용을 보여주기만 하므로 적용할 때는 `source`를 썼습니다. |
| `export MEMORY_LIMIT=128` | 자식 프로그램에도 전달되는 환경변수 값을 지정합니다. | 첫 실행의 종료 판단 한도를 128MB로 정합니다. 두 번째만 256으로 바꿔 한 변수의 효과를 비교했습니다. |
| `export CPU_MAX_OCCUPY=100` | 앱의 CPU 설정을 지정합니다. | 이번 두 메모리 실험에서 같은 조건을 유지했습니다. 100이 모든 실험의 권장값이거나 실제 CPU 사용률 100%라는 뜻은 아닙니다. |
| `export MULTI_THREAD_ENABLE=false` | 앱의 해당 동시 처리 설정을 끕니다. | 교착 재현 조건을 켜지 않고 메모리 비교를 진행했습니다. 앱 전체가 한 스레드라는 뜻은 아닙니다. |
| `./agent-leak-app` | 현재 디렉터리의 실행 파일을 시작합니다. | 준비한 Linux 바이너리를 일반 사용자로 실행합니다. `./`는 현재 위치라는 뜻입니다. |
| `> "$RUN_DIR/app.log"` | 표준 출력(1)을 파일에 저장합니다. | 화면이 사라져도 실행 결과를 증거로 남깁니다. `>`는 같은 파일이 있으면 덮어쓰므로 실행마다 다른 증거 폴더를 사용했습니다. |
| `2>&1` | 표준 오류(2)를 앞서 정한 표준 출력(1) 목적지로 보냅니다. | 일반 출력과 오류를 같은 앱 로그에 남깁니다. 리다이렉션은 왼쪽에서 오른쪽 순서로 적용됩니다. |
| 마지막 `&` | 명령을 백그라운드에서 시작합니다. | 앱이 실행되는 동안 같은 터미널에서 관제를 시작할 수 있습니다. |
| `APP_PID=$!` | 방금 백그라운드로 시작한 작업의 PID를 변수에 저장합니다. | 추후 조회·관제·종료 대상을 식별합니다. 이것은 부모 실행기일 수 있어 실제 작업 자식도 따로 찾았습니다. |
| `pgrep -P "$APP_PID" -x agent-leak-app` | 지정 부모의 자식 중 이름이 정확히 일치하는 프로세스를 찾습니다. | 부모가 작게 대기하는 동안 메모리를 쓰는 자식 PID의 변화를 놓치지 않기 위해서입니다. |
| `./monitor.sh "$APP_PID"` | 해당 PID를 인자로 넘겨 반복 조회합니다. | 실행 시점의 한 장면뿐 아니라 메모리 변화 추세를 수집합니다. 실제 수집에서는 발견한 작업 자식에도 별도 실행했습니다. |

`"$RUN_DIR"`처럼 큰따옴표로 변수를 감싸면 값이 하나의 경로로 전달됩니다. `$`는 변수 값을 읽고, `=`는 변수에 값을 저장합니다. `RUN_DIR`는 증거 저장 폴더이고 `APP_PID`는 프로세스 번호이므로 역할이 다릅니다. [환경변수](../glossary.md#environment-variable)와 [PID](../glossary.md#pid) 참조.

종료 상태 저장에 사용한 구문의 핵심은 다음과 같습니다. **앞에서 앱을 실행해 APP_PID와 RUN_DIR를 준비한 상황의 설명**이며, 지금 새 실행 없이 그대로 입력할 명령 묶음이 아닙니다.

```bash
wait "$APP_PID"
APP_EXIT=$?
printf '%s\n' "$APP_EXIT" > "$RUN_DIR/exit-code.txt"
```

`wait`는 현재 셸이 시작한 해당 자식 작업의 종료를 기다리고 종료 상태를 반환합니다. `$?`는 바로 직전 명령의 상태이므로 다른 명령을 끼우기 전에 저장했습니다. `printf '%s\n'`은 값을 문자열로 쓰고 줄바꿈합니다. 이번 두 파일의 값은 137이며 [종료 코드](../glossary.md#exit-code)만으로 종료 이유까지 확정하지는 않습니다.

### 관제 코드 해석: monitor.sh는 무엇을 추출하나요?

[monitor.sh 원문](../scripts/monitor.sh)의 핵심 조회는 다음과 같습니다. 앱 코드를 수정하는 스크립트가 아니라 프로세스 상태를 읽어 기록하는 스크립트입니다.

```bash
ps -p "$pid" -o pid=,ppid=,etimes=,pcpu=,pmem=,rss=,nlwp=,stat=
```

1. [ps](../glossary.md#ps)의 `-p`로 한 PID를 고릅니다. `-o`로 필요한 항목과 출력 순서를 지정합니다. 각 항목 끝 `=`는 제목을 생략해 데이터만 받게 합니다.
2. 파이프 `|`로 출력을 awk에 넘깁니다. awk의 `$1`부터 `$8`은 각각 PID, PPID, 경과 초, 평균 CPU, 메모리 비율, RSS, 스레드 수, 상태입니다. `printf`로 이 필드를 쉼표로 연결해 CSV 한 행을 만듭니다.
3. `$8 !~ /^Z/`는 상태가 Z(좀비)로 시작하는 행을 제외한다는 조건입니다. 대상 행이 없으면 반복을 끝냅니다.
4. `date -Iseconds`로 측정 시각을 앞에 붙이고 `sleep 1`로 다음 조회 전 약 1초 쉽니다. 조회 자체에도 시간이 걸리므로 정확히 1초 간격이라는 보장은 없습니다.
5. 일반 CSV는 표준 출력에, `Monitoring ended...`는 표준 오류에 보냅니다. 실제 실행의 `2>` 저장 파일은 CSV 숫자와 관제 종료 안내를 분리합니다.

자세한 뜻은 [monitor.sh 전체 코드 해설](../monitor-code-guide.md), [monitor.sh 용어](../glossary.md#monitor-sh), [로그](../glossary.md#log), [단위](../glossary.md#units)를 참고합니다. 여기의 `cpu_avg_pct`는 ps 평균값이므로 짧은 CPU 급상승 분석에서는 별도 top 기록을 사용했습니다.

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

#### 출력 해석: CSV 한 줄을 어떻게 읽나요?

`2026-11-10T19:36:50+09:00,11373,11329,14,0.9,1.8,146412,1,SN`은 다음 뜻입니다.

| 항목 | 값 | 읽는 방법 |
|---|---:|---|
| timestamp | 19:36:50 +09:00 | 한국 표준시의 측정 시각입니다. |
| pid / ppid | 11373 / 11329 | 작업 자식과 그 부모 프로세스 번호입니다. |
| elapsed_s | 14 | 이 PID가 시작한 뒤 약 14초가 지났습니다. 로그 기준 생존 시간 계산과는 기준·정밀도가 다릅니다. |
| cpu_avg_pct | 0.9 | 프로세스 실행 시간에 걸친 평균 CPU 사용률입니다. 현재 순간 CPU가 정확히 0.9%라는 뜻은 아닙니다. |
| mem_pct | 1.8 | ps가 보는 물리 메모리 대비 RSS 비율입니다. Windows PC Manager의 시스템 전체 비율과 다릅니다. |
| rss_kib | 146412 | 실제 메모리에 상주하는 양입니다. 1024로 나누면 약 142.98MiB입니다. 앱의 Heap 로그 값과 같은 값이어야 하는 것은 아닙니다. |
| threads | 1 | 해당 시점 ps가 관측한 스레드 수입니다. |
| state | SN | S는 인터럽트 가능한 대기, N은 낮은 우선순위입니다. 이 표시만으로 오류나 교착을 뜻하지 않습니다. |

처음에는 RSS가 18,392KiB였고 나중에는 146,412KiB였습니다. 값이 일정한 간격으로 증가했다가 여러 행 유지되는 계단 모양을 읽습니다. 이는 메모리 증가 증거이며, 종료 주체는 아래 로그에서 추가 확인해야 합니다. 자세한 [RSS 뜻](../glossary.md#rss)과 [KiB·MiB·MB 구분](../glossary.md#units)을 참고합니다.

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

#### 출력 해석: 종료 로그의 영어는 무슨 뜻인가요?

| 로그 문구 | 쉬운 해석 | 이 문구로 판단하는 범위 |
|---|---|---|
| `[INFO] [MemoryWorker] Current Heap: 150MB` | 메모리 작업 담당 부분이 현재 내부 메모리 값을 150MB로 기록했습니다. | 앱 내부 값의 증가입니다. 이 문구 하나가 OS의 RSS 또는 누수 위치를 확정하지는 않습니다. |
| `[CRITICAL] [MemoryGuard]` | 심각한 수준의 메시지를 메모리 보호 담당 부분이 기록했습니다. | 메시지 수준과 기록 주체를 읽습니다. Linux 커널 메시지라는 뜻은 아닙니다. |
| `Memory limit exceeded (150MB >= 128MB)` | 현재 값이 설정 한도 이상이라 한도를 넘었다고 앱이 판단했습니다. | 150이 128보다 크므로 보호 조건을 만족했다는 근거입니다. [한도 초과](../glossary.md#memory-limit-exceeded) 참조. |
| `Recommend Over 256MB` | 256MB보다 큰 값을 권고한다는 안내입니다. | 권고와 허용 범위 검사는 다릅니다. 256도 부팅은 통과했고 같은 경고가 남았습니다. |
| `Self-terminating process 11373...` | 시스템 불안정을 막기 위해 해당 프로세스를 스스로 종료하겠다고 기록했습니다. | 앞의 한도 초과, 같은 PID, 종료 후 조회와 연결해 [MemoryGuard](../glossary.md#memoryguard) 보호 종료로 판단합니다. |

After도 같은 구조로 읽습니다. `275MB >= 256MB`이므로 한도를 높여 더 오래 실행됐지만 다시 같은 보호 조건에 도달했습니다. 로그에 표시된 앱 값이 25MB 단위로 증가했으므로 128·256과 정확히 같은 값에서 종료할 필요는 없습니다.

두 실행의 종료 후 ps에는 제목만 남았습니다. 시작 시점에는 부모·자식 관계가 존재했습니다. [Before 시작 상태](../evidence/oom-128-20261110-193545/ps-start.txt), [Before 종료 후](../evidence/oom-128-20261110-193545/ps-after.txt), [After 종료 후](../evidence/oom-256-20261110-193915/ps-after.txt), [Before 종료 코드](../evidence/oom-128-20261110-193545/exit-code.txt), [After 종료 코드](../evidence/oom-256-20261110-193915/exit-code.txt).

### 증거 링크를 누르면 무엇을 보나요?

| 클릭할 증거 | 먼저 찾을 부분 | 왜 필요한가요? |
|---|---|---|
| settings.txt: [Before](../evidence/oom-128-20261110-193545/settings.txt) / [After](../evidence/oom-256-20261110-193915/settings.txt) | MEMORY_LIMIT 128/256, 나머지 100/false | 무엇을 바꾸고 무엇을 고정했는지 확인합니다. 앱의 부팅 로그와도 대조합니다. |
| 작업 자식 CSV: [Before 11373](../evidence/oom-128-20261110-193545/monitor-11373.csv) / [After 11834](../evidence/oom-256-20261110-193915/monitor-11834.csv) | 헤더의 rss_kib와 같은 PID의 시간 순서 | 실제 상주 메모리 증가를 확인합니다. 부모 CSV와 혼동하지 않습니다. |
| app.log: [Before](../evidence/oom-128-20261110-193545/app.log) / [After](../evidence/oom-256-20261110-193915/app.log) | Agent listening 시각, Heap 증가, MemoryGuard 두 종료 문구 | 현상, 종료 판단 주체, 시작~종료 요청 시간의 근거입니다. |
| ps-start.txt: [Before](../evidence/oom-128-20261110-193545/ps-start.txt) / [After](../evidence/oom-256-20261110-193915/ps-start.txt) | PID·PPID | 실행기와 작업 프로세스 관계를 확인합니다. |
| ps-after.txt: [Before](../evidence/oom-128-20261110-193545/ps-after.txt) / [After](../evidence/oom-256-20261110-193915/ps-after.txt) | 제목 아래 데이터 행의 부재 | 조회 시점에 해당 PID들이 더 이상 없음을 확인합니다. 시스템 전체 프로세스가 없다는 뜻은 아닙니다. |
| exit-code.txt: [Before](../evidence/oom-128-20261110-193545/exit-code.txt) / [After](../evidence/oom-256-20261110-193915/exit-code.txt) | 137 | 종료 상태의 보조 정보입니다. 커널 OOM 개입의 단독 증거로 사용하지 않습니다. |

이 표 안의 Before·After 링크를 직접 누르면 해당 원본이 열립니다. **CSV의 증가 → 같은 PID의 한도 초과·종료 로그 → 종료 후 PID 부재**를 연결하는 것이 발표의 판단 흐름입니다.

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
