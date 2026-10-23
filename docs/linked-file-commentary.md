# 링크로 연 코드·출력물 상세 해석

작성일: 2026-10-23. 대상은 [발표 대본](presentation-walkthrough.md)에서 연결한 **32종 파일**입니다. 원본은2026-10-09 실험이며 이 문서를 작성하며 프로그램을 새로 실행하지 않았습니다.

**사용 방법:** 발표 대본의 원본 링크 바로 옆 **코드·출력 해석**을 누르면 해당 파일의 절로 이동합니다. 원본 로그를 열면 당시의 내용이 보이고, 이 해설에서는 그 내용을 만드는 명령과 숫자의 의미를 설명합니다. 원본 증거 파일에는 설명 문장을 끼워 넣지 않았습니다.

**코드와 출력 구분:** 원본 코드 블록은 읽는 자료입니다. 아직 실습 경로·설정·살아 있는 PID를 준비하지 않았다면 구문 예시를 그대로 실행하지 않습니다. 출력 블록의 시각·PID·수치를 명령으로 입력하지 않습니다. 발췌는 CRLF를 LF로 정규화했으며 실제 내용과 대조했습니다.

## 파일 찾기

| 해설 | 실제 파일 경로 | 내용 |
|---|---|---|
| [01](#해설-01) | `docs/evidence-reading-guide.md` | 문서 구성과 읽는 방법 |
| [02](#해설-02) | `README.md` | 문서 구성과 읽는 방법 |
| [03](#해설-03) | `evidence/environment.txt` | 실제 출력과 판단 근거 |
| [04](#해설-04) | `scripts/env.sh` | 코드와 구문 |
| [05](#해설-05) | `evidence/oom-128-20261009-113259/app.log` | 실제 출력과 판단 근거 |
| [06](#해설-06) | `scripts/monitor.sh` | 코드와 구문 |
| [07](#해설-07) | `evidence/oom-128-20261009-113259/monitor-962.csv` | 실제 출력과 판단 근거 |
| [08](#해설-08) | `docs/complete-course.md` | 문서 구성과 읽는 방법 |
| [09](#해설-09) | `evidence/oom-128-20261009-113259/settings.txt` | 실제 출력과 판단 근거 |
| [10](#해설-10) | `evidence/oom-256-20261009-113740/settings.txt` | 실제 출력과 판단 근거 |
| [11](#해설-11) | `reports/01-oom.md` | 문서 구성과 읽는 방법 |
| [12](#해설-12) | `evidence/oom-256-20261009-113740/app.log` | 실제 출력과 판단 근거 |
| [13](#해설-13) | `reports/02-cpu.md` | 문서 구성과 읽는 방법 |
| [14](#해설-14) | `evidence/cpu-80-pty-20261009-115744/app.log` | 실제 출력과 판단 근거 |
| [15](#해설-15) | `evidence/cpu-80-pty-20261009-115744/top.log` | 실제 출력과 판단 근거 |
| [16](#해설-16) | `evidence/cpu-40-pty-20261009-122044/app.log` | 실제 출력과 판단 근거 |
| [17](#해설-17) | `evidence/cpu-40-pty-20261009-122044/top.log` | 실제 출력과 판단 근거 |
| [18](#해설-18) | `evidence/cpu-40-pty-20261009-122044/ps-check.txt` | 실제 출력과 판단 근거 |
| [19](#해설-19) | `reports/03-deadlock.md` | 문서 구성과 읽는 방법 |
| [20](#해설-20) | `evidence/deadlock-true-20261009-125943/snapshot-1.txt` | 실제 출력과 판단 근거 |
| [21](#해설-21) | `evidence/deadlock-true-20261009-125943/snapshot-2.txt` | 실제 출력과 판단 근거 |
| [22](#해설-22) | `evidence/deadlock-true-20261009-125943/app.log` | 실제 출력과 판단 근거 |
| [23](#해설-23) | `evidence/deadlock-false-20261009-130309/snapshot-1.txt` | 실제 출력과 판단 근거 |
| [24](#해설-24) | `evidence/deadlock-false-20261009-130309/snapshot-2.txt` | 실제 출력과 판단 근거 |
| [25](#해설-25) | `evidence/cpu-40-pty-20261009-122044/cleanup.log` | 실제 출력과 판단 근거 |
| [26](#해설-26) | `evidence/deadlock-true-20261009-125943/cleanup.log` | 실제 출력과 판단 근거 |
| [27](#해설-27) | `evidence/oom-128-20261009-113259/exit-code.txt` | 실제 출력과 판단 근거 |
| [28](#해설-28) | `evidence/cpu-80-pty-20261009-115744/exit-code.txt` | 실제 출력과 판단 근거 |
| [29](#해설-29) | `evidence/cpu-40-pty-20261009-122044/ps-after-cleanup.txt` | 실제 출력과 판단 근거 |
| [30](#해설-30) | `templates/issue-report-template.md` | 문서 구성과 읽는 방법 |
| [31](#해설-31) | `templates/learning-record-template.md` | 문서 구성과 읽는 방법 |
| [32](#해설-32) | `docs/guided-learning.md` | 문서 구성과 읽는 방법 |

## 해설 01

**대상: docs/evidence-reading-guide.md**

[원본 evidence-reading-guide.md 열기](../docs/evidence-reading-guide.md) · [발표 대본으로 돌아가기](presentation-walkthrough.md)

**문서의 역할:** 원본 증거98개의 수집 이유와 읽는 방법을 안내하는 목록입니다. 파일 이름을 클릭하면 저장 당시 내용이 열립니다.

**읽는 순서:** 같은 실험 폴더에서 settings → app.log → monitor/top/snapshot → exit-code/cleanup을 연결합니다. 빈 top-error.log는 기록된 표준 오류 문장이 없다는 뜻이며, 충분한 기간 관제를 했다는 증거는 아닙니다.

**이 문서와의 차이:** 증거 목록은 모든 파일을 찾는 색인이고, 현재 해설은 발표 대본에서 실제로 누르는32종 파일에 대해 코드·출력의 구체적 항목을 설명합니다. 원본 파일을 수정해 설명을 끼워 넣지는 않았습니다.

## 해설 02

**대상: README.md**

[원본 README.md 열기](../README.md) · [발표 대본으로 돌아가기](presentation-walkthrough.md)

**문서의 역할:** 저장소 전체의 목적, 실험 환경, 전후 비교 결과, 보고서·교안으로 가는 길을 제공합니다. 프로그램의 표준 출력이 아닙니다.

**표를 읽는 법:** OOM 행은 MEMORY_LIMIT 128→256, CPU 행은 CPU_MAX_OCCUPY 80→40, Deadlock 행은 MULTI_THREAD_ENABLE true→false 비교입니다. 한 행의 Before와 After를 같은 지표·단위로 비교합니다. 서로 다른 행의 실험은 조건이 다르므로 단일 변수 비교로 합치지 않습니다.

**숫자를 말하는 방법:** 17.202/32.363초는 지정한 앱 시작 로그부터 종료 요청까지의 차이, CPU50.0/40.0%는 최초 프레임 제외 top 표본 최대, Deadlock의10초는 두 스냅샷 간격입니다. 모두 분모와 시간 범위를 함께 말합니다.

**왜 링크를 두었나:** 결론만 제시하지 않고 원본과 판단 경로를 다시 확인할 수 있도록 했습니다. README의 표는 요약이고 정확한 근거는 해당 로그·CSV·스냅샷입니다.

## 해설 03

**대상: evidence/environment.txt**

[원본 environment.txt 열기](../evidence/environment.txt) · [발표 대본으로 돌아가기](presentation-walkthrough.md)

**이 파일은 무엇인가:** 여러 환경 확인 명령의 결과를 순서대로 모은 기록입니다. 한 명령이 전부 출력한 것이 아닙니다. 아래는 2026-10-09 13:08:15에 저장한 환경이며 모든 실험 순간의 자원 상태와 동일하다는 의미는 아닙니다.

**원본 출력·저장 내용 발췌 — 이 블록을 실행하지 않습니다.**

```text
2026-10-09T13:08:15+09:00
Linux HP 6.18.40.1-microsoft-standard-WSL2 #1 SMP PREEMPT_DYNAMIC Fri Jul 31 22:12:15 UTC 2026 x86_64 GNU/Linux
uid=1000(jae0608) gid=1000(jae0608) groups=1000(jae0608),4(adm),24(cdrom),27(sudo),30(dip),46(plugdev),100(users)
PRETTY_NAME="Ubuntu 26.04.1 LTS"
NAME="Ubuntu"
VERSION_ID="26.04"
VERSION="26.04.1 LTS (Resolute Raccoon)"
VERSION_CODENAME=resolute
ID=ubuntu
ID_LIKE=debian
HOME_URL="https://www.ubuntu.com/"
SUPPORT_URL="https://help.ubuntu.com/"
BUG_REPORT_URL="https://bugs.launchpad.net/ubuntu/"
PRIVACY_POLICY_URL="https://www.ubuntu.com/legal/terms-and-policies/privacy-policy"
UBUNTU_CODENAME=resolute
LOGO=ubuntu-logo
14
               total        used        free      shared  buff/cache   available
Mem:           7.5Gi       553Mi       6.7Gi       4.1Mi       345Mi       6.9Gi
Swap:          2.0Gi          0B       2.0Gi
```

[원본 1~20행](../evidence/environment.txt#L1-L20)


| 원본에서 보이는 값 | 어떤 명령·항목인가 | 정확한 해석 |
|---|---|---|
| 2026-10-09T13:08:15+09:00 | date -Iseconds | 기록 시각. +09:00은 UTC보다9시간 빠른 시간대입니다. |
| Linux HP ... microsoft-standard-WSL2 ... x86_64 | uname -a | Linux 커널, 호스트명HP, WSL2 커널 릴리스, 아키텍처 등을 한 줄로 표시합니다. Ubuntu 배포판 버전은 별도 항목입니다. |
| uid=1000(jae0608) gid=1000 ... groups=... | id | 실제 사용자·기본 그룹·보조 그룹입니다. sudo그룹 소속이어도 현재 UID가0이라는 뜻은 아닙니다. |
| PRETTY_NAME="Ubuntu 26.04.1 LTS" | cat /etc/os-release | 배포판의 사람이 읽기 쉬운 이름입니다. 아래 URL들은 OS 배포판 메타데이터입니다. |
| 14 | nproc | 이 실행 환경에서 프로세스가 사용할 수 있는 처리 단위 수입니다. RAM14GB나CPU14%가 아닙니다. |
| Mem: total7.5Gi / used553Mi / free6.7Gi | free -h | WSL이 보는 메모리의 총량·사용량·비어 있는 양입니다. Gi/Mi는 이진 단위입니다. |
| buff/cache345Mi / available6.9Gi | free -h | 캐시 등과 새 앱에 제공 가능할 것으로 추정하는 양입니다. 캐시 전부를 누수로 분류하지 않습니다. |
| Swap: total2.0Gi / used0B | free -h | 설정된 스왑과 당시 사용량입니다. 0B는 그 관측 시점에 스왑 사용이 없다는 뜻입니다. |

**이 출력으로 내릴 판단:** 실행 환경과 사용자 조건을 설명할 수 있습니다. 별도 시점에 발생한 보호 종료의 원인을 free 한 장만으로 확정하지 않습니다.

## 해설 04

**대상: scripts/env.sh**

[원본 env.sh 열기](../scripts/env.sh) · [발표 대본으로 돌아가기](presentation-walkthrough.md)

**이 파일은 무엇인가:** 앱을 시작하기 전에 적용하는 Bash 설정 코드입니다. 파일을 보는 것과 설정을 적용하는 것은 다릅니다. `source ./env.sh`는 현재 셸에서 이 줄들을 실행합니다.

**원본 코드 발췌 — 이 블록을 실행하지 않습니다.**

```bash
export AGENT_HOME="$HOME/jae-test"
export AGENT_PORT=15034
export AGENT_UPLOAD_DIR="$AGENT_HOME/upload_files"
export AGENT_KEY_PATH="$AGENT_HOME/api_keys"
export AGENT_LOG_DIR="$AGENT_HOME/logs"
export MEMORY_LIMIT=128
export CPU_MAX_OCCUPY=100
export MULTI_THREAD_ENABLE=false
```

[원본 1~8행](../scripts/env.sh#L1-L8)


| 코드 | 왜 이렇게 입력했는가 | 앱에 전달되는 의미 |
|---|---|---|
| export AGENT_HOME="$HOME/jae-test" | 사용자 홈 아래의 실험 경로를 기준으로 설정 | $HOME은 현재 사용자 홈으로 확장됩니다. 원본은 예전 jae-test경로이므로 새 실습 경로와 구분합니다. |
| export AGENT_PORT=15034 | 과제가 고정한 통신 포트 | 환경변수를 지정한다고 포트가 즉시 열리지는 않습니다. 앱이 실행해 바인딩해야 합니다. |
| export AGENT_UPLOAD_DIR="$AGENT_HOME/upload_files" | 업로드 폴더 위치 전달 | 이 줄은 폴더를 만들지 않습니다. mkdir와 존재 검사가 별도입니다. |
| export AGENT_KEY_PATH="$AGENT_HOME/api_keys" | 키가 들어 있는 디렉터리 전달 | secret.key 파일 자체의 경로가 아니라 디렉터리입니다. |
| export AGENT_LOG_DIR="$AGENT_HOME/logs" | 로그 기록 위치 전달 | 디렉터리 존재·접근·쓰기 권한을 따로 확인합니다. |
| export MEMORY_LIMIT=128 | 낮은 한도에서 메모리 증가·보호 종료 관측 | 단위는 과제 표기의MB. OS의 RSS 강제 제한 명령이나 RAM 예약이 아닙니다. |
| export CPU_MAX_OCCUPY=100 | 초기 OOM 비교에서 CPU 조건을 동일하게 유지 | CPU를 항상100% 사용하거나 보호를 끄도록 확인한 설정은 아닙니다. |
| export MULTI_THREAD_ENABLE=false | 초기 비교에서 동시 트랜잭션 경로를 끔 | 앱 전체의 스레드 수를1로 만드는 의미로 단정하지 않습니다. |

**공통 구문:** export는 이후 자식에게 값을 전달하고, 큰따옴표는 변수 확장을 허용하면서 경로의 공백 등을 보호합니다. `=` 앞뒤에 공백을 넣지 않습니다. source·export는 보통 성공 문장을 출력하지 않으므로 printenv와 앱 부팅 로그로 확인합니다. 이후 터미널에서 export로 바꾼 값은 이 파일 내용을 자동 수정하지 않습니다.

## 해설 05

**대상: evidence/oom-128-20261009-113259/app.log**

[원본 app.log 열기](../evidence/oom-128-20261009-113259/app.log) · [발표 대본으로 돌아가기](presentation-walkthrough.md)

**구성:** 처음은 6가지 부팅 검사, 다음은 실행 시작·자원 상태, 마지막은 MemoryWorker 증가와 MemoryGuard 종료 로그입니다.

**원본 출력·저장 내용 발췌 — 이 블록을 실행하지 않습니다.**

```text
2026-10-09 11:33:01,997 [INFO] [MemoryWorker] Current Heap: 25MB
2026-10-09 11:33:05,029 [INFO] [MemoryWorker] Current Heap: 50MB
2026-10-09 11:33:08,063 [INFO] [MemoryWorker] Current Heap: 75MB
2026-10-09 11:33:11,096 [INFO] [MemoryWorker] Current Heap: 100MB
2026-10-09 11:33:14,130 [INFO] [MemoryWorker] Current Heap: 125MB
2026-10-09 11:33:17,169 [INFO] [MemoryWorker] Current Heap: 150MB
2026-10-09 11:33:17,169 [CRITICAL] [MemoryGuard] Memory limit exceeded (150MB >= 128MB) / (Recommend Over 256MB)
2026-10-09 11:33:17,169 [CRITICAL] [MemoryGuard] Self-terminating process 962 to prevent system instability.
```

[원본 30~37행](../evidence/oom-128-20261009-113259/app.log#L30-L37)


| 출력 문장·기호 | 해석 | 왜 이런 결과인가 |
|---|---|---|
| 시각 뒤 [INFO] [MemoryWorker] | 시각·로그 등급·기록 모듈 순서 | 앱 로거가 메시지에 접두사를 붙였기 때문 |
| Current Heap: 25MB → ... | 앱이 기록한 내부 메모리 값 | 약 3초 간격 25MB 단위 증가가 관측됨 |
| 125MB → 150MB | 한도 바로 아래 단계에서 다음 단계로 증가 | 정확히128을 찍는 단계가 없어 한도를 넘겨 관측 |
| [CRITICAL] [MemoryGuard] Memory limit exceeded | 앱 메모리 보호 정책이 초과를 기록 | OS의free 결과가 아니라 앱 내부 비교 |
| 150MB >= 128MB | 현재 내부 값이 설정 한도 이상 | 부등호 >=는 이상을 뜻함 |
| Recommend Over 256MB | 256보다 큰 값을 권장하는 안내 | 256 자체는 초과가 아니므로 256 실험에도 경고가 남음 |
| Self-terminating process 962 | 해당 프로세스의 자체 종료 요청 | 정확한 내부 종료 구현은 확인하지 않았으며 이 문장이 종료 주체의 근거 |

**생존 시간:** 시작 로그11:32:59.967부터 종료 요청11:33:17.169까지17.202초입니다. 첫 25MB 로그부터 계산하지 않았습니다. 256 실험의 32.363초와 비교할 기준입니다.

**판단 한계:** 메모리 누적·보호 종료는 확인했습니다. 특정 자료구조의 누수 위치나 커널 OOM Killer의 개입은 이 로그로 확정하지 않습니다.

### 부팅 출력도 읽기

- Checking User Account: 현재 계정이 root가 아닌지 검사한 결과입니다.
- Verifying Environment Variables: 필수 환경변수의 존재·형식을 확인합니다.
- Checking Required Files: 키 파일 존재와 테스트 문자열을 확인합니다.
- Checking Port Availability: 고정 포트15034의 사용 가능 여부를 확인합니다.
- Verifying Log Permission: 로그 디렉터리에 기록 가능한지 확인합니다.
- Verifying Mission Environment: 메모리·CPU·동시 설정이 허용 조건인지 확인하고 실제 읽은 값을 표시합니다.
- All Boot Checks Passed / Agent READY: 준비 검사를 통과한 상태입니다. 작업 중 장애가 없다는 보장은 아닙니다.
- SafetyGuard Process priority lowered (nice=10): 앱이 자신의 스케줄링 우선순위를 낮췄다는 로그입니다. CPU가 항상10%라는 의미는 아닙니다.
- Agent listening at port15034: 앱이 리스닝을 시작했다고 기록한 시각이며 이 보고서의 생존 시간 계산 시작점입니다.

## 해설 06

**대상: scripts/monitor.sh**

[원본 monitor.sh 열기](../scripts/monitor.sh) · [발표 대본으로 돌아가기](presentation-walkthrough.md)

**이 파일은 무엇인가:** 대상 PID를 인자로 받아 ps의 자원 사용량을 반복 기록하는 관제 코드입니다. 앱 내부 코드가 아닙니다.

**원본 코드 발췌 — 이 블록을 실행하지 않습니다.**

```bash
#!/usr/bin/env bash
export LC_ALL=C

if [[ $# -ne 1 || ! $1 =~ ^[1-9][0-9]*$ ]]; then
    echo "Usage: $0 PID" >&2
    exit 1
fi

pid="$1"
echo "timestamp,pid,ppid,elapsed_s,cpu_avg_pct,mem_pct,rss_kib,threads,state"

while true; do
    row=$(ps -p "$pid" \
        -o pid=,ppid=,etimes=,pcpu=,pmem=,rss=,nlwp=,stat= \
        2>/dev/null |
        awk '$8 !~ /^Z/ {
            printf "%s,%s,%s,%s,%s,%s,%s,%s", \
                $1,$2,$3,$4,$5,$6,$7,$8
        }')

    [[ -n "$row" ]] || break
    printf '%s,%s\n' "$(date -Iseconds)" "$row"
    sleep 1
done

echo "Monitoring ended: PID $pid is no longer running." >&2
```

[원본 1~26행](../scripts/monitor.sh#L1-L26)


| 코드·행 | 실행 순서와 이유 | 출력 또는 종료 조건 |
|---|---|---|
| 1행 #!/usr/bin/env bash | 실행 시 PATH에서 Bash를 찾아 스크립트를 해석 | chmod 실행 권한과 함께 ./monitor.sh PID로 시작 가능 |
| 2행 export LC_ALL=C | ps 등의 지역화 형식을 고정 | 소수점·문자 형식을 일관되게 읽기 위함 |
| 4~7행 인자 검사 | $#는 인자 개수, $1은 첫 인자. 하나의 양의 정수 PID만 허용 | 없거나 0·음수·문자·선행 0 등 형식에 맞지 않으면 Usage를 표준 오류로 표시하고 1로 종료 |
| if 안의 \|\| / ! / =~ | \|\|는 둘 중 조건 만족, !는 부정, =~는 정규식 검사 | 인자 수 오류 또는 PID 형식 오류를 검사 |
| pid="$1" | 검증한 인자를 변수에 보관 | 여기서 PID를 찾는 것이 아니라 사용자가 넘긴 번호를 사용 |
| echo timestamp,... | 열 이름을 먼저 출력 | CSV 첫 줄이 제목인 이유 |
| while true; do | 반복 수집 시작 | 아래 break 조건 전까지 실행 |
| row=$(ps ... \| awk ...) | 조회 결과를 awk로 변환해 변수에 저장 | $()는 명령 치환. 파이프로 앞의 출력을 뒤 명령의 입력에 전달 |
| ps -p "$pid" | 한 프로세스 번호를 조회 | 모든 프로세스를 합산하지 않음 |
| -o pid=,ppid=,... | 지정한 순서대로 출력하고 =로 제목을 숨김 | awk가 데이터 행만 읽도록 함 |
| 2>/dev/null | ps 표준 오류를 버림 | 오류가 기록되지 않을 수 있으므로 결과가 비면 조회 실패 가능성도 있음 |
| awk의 $8 !~ /^Z/ | 8번째 상태 열이 Z로 시작하면 제외 | 좀비를 수집 대상으로 남기지 않음 |
| printf와 $1~$8 | 각 필드를 쉼표로 이어 한 행 생성 | awk의 $1은 ps의 1열이며 Bash 인자 $1과 역할이 다름 |
| [[ -n "$row" ]] \|\| break | row가 비지 않았는지 검사 | 비면 반복 종료. 프로세스 부재·좀비 제외·조회 오류 등을 구분해야 함 |
| date -Iseconds / printf | 관측 시각과 데이터 행을 출력 | timestamp가 첫 열에 추가됨 |
| sleep 1 | 반복 사이 1초 대기 | 명령 수행 시간도 있어 정확한 고정 1초 타이머는 아님 |
| 마지막 echo ... >&2 | 관제 종료 알림을 표준 오류로 보냄 | CSV와 관제 알림 파일을 분리할 수 있음. 종료 원인을 알려주는 문장은 아님 |

**왜 이 코드만으로 장애 원인을 알 수 없나:** 자원 사용·프로세스 존재를 기록할 뿐 메모리 할당 위치나 락 소유를 직접 분석하지 않습니다. 앱 로그와 연결해야 합니다. 짧은 구간 변화가 표본 사이에 있을 수 있으며 ps CPU는 누적 평균입니다. `bash -n`은 문법 검사이고 실제 수집 검증과 다릅니다.

## 해설 07

**대상: evidence/oom-128-20261009-113259/monitor-962.csv**

[원본 monitor-962.csv 열기](../evidence/oom-128-20261009-113259/monitor-962.csv) · [발표 대본으로 돌아가기](presentation-walkthrough.md)

**생성 방법:** `./monitor.sh 962`의 표준 출력을 파일로 저장한 기록입니다. 파일명962는 당시 관측 PID이며 새 실습에서는 달라집니다.

**원본 출력·저장 내용 발췌 — 이 블록을 실행하지 않습니다.**

```text
timestamp,pid,ppid,elapsed_s,cpu_avg_pct,mem_pct,rss_kib,threads,state
2026-10-09T11:33:01+09:00,962,954,1,2.0,0.2,18356,1,SN
2026-10-09T11:33:02+09:00,962,954,2,2.0,0.5,43960,1,SN
2026-10-09T11:33:03+09:00,962,954,3,1.5,0.5,43960,1,SN
2026-10-09T11:33:04+09:00,962,954,4,1.2,0.5,43960,1,SN
```

[원본 1~5행](../evidence/oom-128-20261009-113259/monitor-962.csv#L1-L5)


| 열 | 첫 표본 또는 예 | 값이 뜻하는 것 |
|---|---|---|
| timestamp | 2026-10-09T11:33:01+09:00 | ps조회 직후에 붙인 시각입니다. |
| pid / ppid | 962 / 954 | 작업 프로세스와 그 부모 번호입니다. |
| elapsed_s | 1 | 그 프로세스 경과 초입니다. 폴더 생성 이후 시간이 아닙니다. |
| cpu_avg_pct | 2.0 | 프로세스 수명에 대한 ps의CPU 평균입니다. |
| mem_pct | 0.2 | OS가 보는 물리 메모리 대비RSS 비율입니다. |
| rss_kib | 18356 | 상주량18356KiB, 약17.926MiB입니다. |
| threads | 1 | 현재 스레드 수입니다. |
| state | SN | S는수면, N은낮은 우선순위입니다. |

**시간 변화를 읽기:** 아래 행으로 내려가면 rss_kib가69564,120772,146376KiB로 증가합니다. 같은 값이 반복되는 것은 그 사이 표본에서 RSS가 같았다는 뜻이지 수집이 실패했다는 뜻이 아닙니다. 마지막 관측은17초·RSS146376KiB입니다. 내부Heap150MB 로그와 범위·시각이 달라 숫자가 같을 필요가 없습니다.

## 해설 08

**대상: docs/complete-course.md**

[원본 complete-course.md 열기](../docs/complete-course.md) · [발표 대본으로 돌아가기](presentation-walkthrough.md)

**문서의 역할:** 명령의 목적·출력 해석·6회 비교 실습·평가 질문·용어를 담은 교안입니다. 상단의 설정값 설명 링크는 그중 “실험 설정값은 왜 이렇게 골랐는가” 위치로 이동합니다.

**설정값 해석:** 메모리50~512와 CPU10~100은 허용 범위입니다. 앱의256초과/50미만 권고는 별개입니다. 128/256은 한도 상향 효과 비교,512는 다른 실험의 높은 메모리 설정 고정,80/40은 보호 종료와 냉각 비교, true/false는 동시 경로 비교 목적입니다.

**코드 블록 구분:** “입력할 명령”과 “예전 실제 출력”을 구분합니다. 실습 함수는 이후 명령을 묶은 교안용 코드이고 제공 바이너리의 소스가 아닙니다. 정의만 해서는 앱이 시작되지 않습니다.

**읽고 실습할 때:** 긴 문서를 통째로 실행하지 않습니다. 원본 수치는2026-10-09이고 새 실행 시각·PID·수치는 새로 기록합니다. 교안 작성 중 새 바이너리 실행을 검증한 자료로 해석하지 않습니다.

## 해설 09

**대상: evidence/oom-128-20261009-113259/settings.txt**

[원본 settings.txt 열기](../evidence/oom-128-20261009-113259/settings.txt) · [발표 대본으로 돌아가기](presentation-walkthrough.md)

**생성 방법:** 앱 실행 전에 printf 등으로 현재 설정을 저장한 텍스트입니다. 앱이 자동 생성한 성능 측정값이 아닙니다.

**원본 출력·저장 내용 발췌 — 이 블록을 실행하지 않습니다.**

```text
MEMORY_LIMIT=128
CPU_MAX_OCCUPY=100
MULTI_THREAD_ENABLE=false
```

[원본 1~3행](../evidence/oom-128-20261009-113259/settings.txt#L1-L3)


**줄별 해석:** 1줄은 메모리 한도128MB,2줄은CPU 설정100,3줄은동시 트랜잭션false입니다. 128과256 폴더 사이에서1줄만 바뀌는지 확인합니다. 설정 파일 저장과 앱에 적용된 상태는 부팅 로그를 대조해 확인합니다. 이는 새 실습의 권장 기본값을 자동 적용하는 파일이 아닙니다.

## 해설 10

**대상: evidence/oom-256-20261009-113740/settings.txt**

[원본 settings.txt 열기](../evidence/oom-256-20261009-113740/settings.txt) · [발표 대본으로 돌아가기](presentation-walkthrough.md)

**생성 방법:** 앱 실행 전에 printf 등으로 현재 설정을 저장한 텍스트입니다. 앱이 자동 생성한 성능 측정값이 아닙니다.

**원본 출력·저장 내용 발췌 — 이 블록을 실행하지 않습니다.**

```text
MEMORY_LIMIT=256
CPU_MAX_OCCUPY=100
MULTI_THREAD_ENABLE=false
```

[원본 1~3행](../evidence/oom-256-20261009-113740/settings.txt#L1-L3)


**줄별 해석:** 1줄은 메모리 한도256MB,2줄은CPU 설정100,3줄은동시 트랜잭션false입니다. 128과256 폴더 사이에서1줄만 바뀌는지 확인합니다. 설정 파일 저장과 앱에 적용된 상태는 부팅 로그를 대조해 확인합니다. 이는 새 실습의 권장 기본값을 자동 적용하는 파일이 아닙니다.

## 해설 11

**대상: reports/01-oom.md**

[원본 01-oom.md 열기](../reports/01-oom.md) · [발표 대본으로 돌아가기](presentation-walkthrough.md)

**문서의 역할:** OOM 장애를 GitHub Issue 구조의 Markdown으로 정리한 보고서입니다. RSS 증가와 MemoryGuard 자체 종료를 연결하고 메모리 한도 변경의 효과를 비교합니다.

| 구성 | 질문 | 코드와 출력의 해석 |
|---|---|---|
| Description | 어떤 조건에서 무엇이 관측됐나? | 설정·PID·시각·증상의 표를 먼저 읽습니다. |
| Evidence & Logs | 무슨 파일로 판단했나? | 재현 코드와 실제 출력을 구분합니다. bash 블록의 예전 구문은 준비된 변수·PID를 전제로 합니다. |
| Root Cause Analysis | 증거가 어떤 원리를 가리키나? | 관측 사실과 추론을 나눕니다. 내부 코드 위치·측정하지 않은 지표는 단정하지 않습니다. |
| Workaround & Verification | 무엇을 바꿨고 결과는? | 변경 변수와 고정 변수를 확인하고 동일 지표로 비교합니다. 수동 정리도 표시합니다. |

**코드에서 보이는 기호:** `source`는 현재 셸 설정 적용, `export`는 자식에게 환경 전달, `&`는 백그라운드 실행, `$!`는 직전 작업 PID, `>`는 파일 저장, `2>&1`은 표준 오류를 현재 표준 출력 대상으로 보냅니다. 코드를 읽는 것만으로 과거 실행을 다시 수행한 것은 아닙니다.

**원본 숫자와 함께 볼 점:** 17.202→32.363초는 종료가 늦어진 결과이며 메모리 누적이 해결된 증거가 아닙니다.

## 해설 12

**대상: evidence/oom-256-20261009-113740/app.log**

[원본 app.log 열기](../evidence/oom-256-20261009-113740/app.log) · [발표 대본으로 돌아가기](presentation-walkthrough.md)

**구성:** 처음은 6가지 부팅 검사, 다음은 실행 시작·자원 상태, 마지막은 MemoryWorker 증가와 MemoryGuard 종료 로그입니다.

**원본 출력·저장 내용 발췌 — 이 블록을 실행하지 않습니다.**

```text
2026-10-09 11:37:42,837 [INFO] [MemoryWorker] Current Heap: 25MB
2026-10-09 11:37:45,870 [INFO] [MemoryWorker] Current Heap: 50MB
2026-10-09 11:37:48,907 [INFO] [MemoryWorker] Current Heap: 75MB
2026-10-09 11:37:51,940 [INFO] [MemoryWorker] Current Heap: 100MB
2026-10-09 11:37:54,973 [INFO] [MemoryWorker] Current Heap: 125MB
2026-10-09 11:37:58,006 [INFO] [MemoryWorker] Current Heap: 150MB
2026-10-09 11:38:01,039 [INFO] [MemoryWorker] Current Heap: 175MB
2026-10-09 11:38:04,071 [INFO] [MemoryWorker] Current Heap: 200MB
2026-10-09 11:38:07,104 [INFO] [MemoryWorker] Current Heap: 225MB
2026-10-09 11:38:10,138 [INFO] [MemoryWorker] Current Heap: 250MB
2026-10-09 11:38:13,171 [INFO] [MemoryWorker] Current Heap: 275MB
2026-10-09 11:38:13,172 [CRITICAL] [MemoryGuard] Memory limit exceeded (275MB >= 256MB) / (Recommend Over 256MB)
2026-10-09 11:38:13,172 [CRITICAL] [MemoryGuard] Self-terminating process 1156 to prevent system instability.
```

[원본 30~42행](../evidence/oom-256-20261009-113740/app.log#L30-L42)


| 출력 문장·기호 | 해석 | 왜 이런 결과인가 |
|---|---|---|
| 시각 뒤 [INFO] [MemoryWorker] | 시각·로그 등급·기록 모듈 순서 | 앱 로거가 메시지에 접두사를 붙였기 때문 |
| Current Heap: 25MB → ... | 앱이 기록한 내부 메모리 값 | 약 3초 간격 25MB 단위 증가가 관측됨 |
| 250MB → 275MB | 한도 바로 아래 단계에서 다음 단계로 증가 | 정확히256을 찍는 단계가 없어 한도를 넘겨 관측 |
| [CRITICAL] [MemoryGuard] Memory limit exceeded | 앱 메모리 보호 정책이 초과를 기록 | OS의free 결과가 아니라 앱 내부 비교 |
| 275MB >= 256MB | 현재 내부 값이 설정 한도 이상 | 부등호 >=는 이상을 뜻함 |
| Recommend Over 256MB | 256보다 큰 값을 권장하는 안내 | 256 자체는 초과가 아니므로 256 실험에도 경고가 남음 |
| Self-terminating process 1156 | 해당 프로세스의 자체 종료 요청 | 정확한 내부 종료 구현은 확인하지 않았으며 이 문장이 종료 주체의 근거 |

**생존 시간:** 시작 로그11:37:40.809부터 종료 요청11:38:13.172까지32.363초입니다. 첫 25MB 로그부터 계산하지 않았습니다. 128 실험 17.202초보다 15.161초 늘었지만 같은 종료가 반복됐으므로 임시 조치입니다.

**판단 한계:** 메모리 누적·보호 종료는 확인했습니다. 특정 자료구조의 누수 위치나 커널 OOM Killer의 개입은 이 로그로 확정하지 않습니다.

## 해설 13

**대상: reports/02-cpu.md**

[원본 02-cpu.md 열기](../reports/02-cpu.md) · [발표 대본으로 돌아가기](presentation-walkthrough.md)

**문서의 역할:** CPU 장애를 GitHub Issue 구조의 Markdown으로 정리한 보고서입니다. top의 특정 PID 부하, 앱의 Watchdog SIGTERM,40설정의 냉각과 관측 시점 생존을 비교합니다.

| 구성 | 질문 | 코드와 출력의 해석 |
|---|---|---|
| Description | 어떤 조건에서 무엇이 관측됐나? | 설정·PID·시각·증상의 표를 먼저 읽습니다. |
| Evidence & Logs | 무슨 파일로 판단했나? | 재현 코드와 실제 출력을 구분합니다. bash 블록의 예전 구문은 준비된 변수·PID를 전제로 합니다. |
| Root Cause Analysis | 증거가 어떤 원리를 가리키나? | 관측 사실과 추론을 나눕니다. 내부 코드 위치·측정하지 않은 지표는 단정하지 않습니다. |
| Workaround & Verification | 무엇을 바꿨고 결과는? | 변경 변수와 고정 변수를 확인하고 동일 지표로 비교합니다. 수동 정리도 표시합니다. |

**코드에서 보이는 기호:** `source`는 현재 셸 설정 적용, `export`는 자식에게 환경 전달, `&`는 백그라운드 실행, `$!`는 직전 작업 PID, `>`는 파일 저장, `2>&1`은 표준 오류를 현재 표준 출력 대상으로 보냅니다. 코드를 읽는 것만으로 과거 실행을 다시 수행한 것은 아닙니다.

**원본 숫자와 함께 볼 점:** top50.0/40.0%와 앱 내부53.11%는 서로 다른 지표입니다. 전체 서비스 지연을 측정한 것은 아닙니다.

## 해설 14

**대상: evidence/cpu-80-pty-20261009-115744/app.log**

[원본 app.log 열기](../evidence/cpu-80-pty-20261009-115744/app.log) · [발표 대본으로 돌아가기](presentation-walkthrough.md)

**생성 방법:** script가 PTY에서 앱을 실행하며 터미널 내용을 기록했습니다. 앱 메시지와 script가 붙인 기록 표지가 함께 들어 있습니다.

**원본 출력·저장 내용 발췌 — 이 블록을 실행하지 않습니다.**

```text
2026-10-09 11:58:17,438 [INFO] [CpuWorker] Current Load: 48.93%
2026-10-09 11:58:20,549 [INFO] [CpuWorker] Current Load: 53.11%
2026-10-09 11:58:20,649 [CRITICAL] [CpuWorker] CPU Threshold Violated! (53.11%).

>>> [SYSTEM] WATCHDOG: INITIATING EMERGENCY ABORT (SIGTERM) <<<


Script done on 2026-10-09 11:58:20+09:00 [COMMAND_EXIT_CODE="143"]
```

[원본 42~49행](../evidence/cpu-80-pty-20261009-115744/app.log#L42-L49)


| 출력 | 해석 | 주의점 |
|---|---|---|
| Script started ... COMMAND=... | script가 명령 기록을 시작 | 앱 자체 로그와 구분 |
| <not executed on terminal> | script를 호출한 쪽의 입력이 원래 터미널이 아님을 나타내는 기록 표지 | 앱이 실행되지 않았다는 뜻이 아님. 실제 부팅·작업 로그가 이어짐 |
| Maximum CPU Limit: 80% | 앱이 읽은 CPU 설정 표시 | OS가 80%로 CPU를 강제 제한한다는 증거가 아님 |
| Current Load: 48.93% → 53.11% | 앱 내부 부하 값 상승 | top 구간 사용률과 다른 지표 |
| CPU Threshold Violated! (53.11%). | 앱이 과점유 위반을 기록 | 80설정과실제 내부보호 기준 대응은 미확인 |
| WATCHDOG: ... EMERGENCY ABORT (SIGTERM) | 보호 감시가 긴급 종료 요청 | 정책에 따른 종료라고 판단한 핵심 로그 |
| Script done ... COMMAND_EXIT_CODE="143" | 기록 명령의 종료 상태143 | 128+15의SIGTERM해석과 일치. 주체는 Watchdog 문장으로 확인 |

**왜 ps와 값이 다른가:** ps는 프로세스 수명 평균, top은 갱신 구간, 앱 내부 값은 구현에 따른 별도 값입니다. 설정 80인데 53.11에서 왜 판정했는지 내부 계산식은 확인하지 않았으므로 추정값을 정답처럼 설명하지 않습니다.

## 해설 15

**대상: evidence/cpu-80-pty-20261009-115744/top.log**

[원본 top.log 열기](../evidence/cpu-80-pty-20261009-115744/top.log) · [발표 대본으로 돌아가기](presentation-walkthrough.md)

**생성 방법:** CPU 실험의 `LC_ALL=C top -b -d 0.1 -n 450 -w 180 -p "$TOP_PIDS"` 결과를 저장했습니다. 아래는 첫 프레임을 제외한 최대50.0%가 처음 나타나는 실제 화면입니다.

**원본 출력·저장 내용 발췌 — 이 블록을 실행하지 않습니다.**

```text
top - 11:58:11 up  1:15,  1 user,  load average: 0.00, 0.01, 0.01
Tasks:   2 total,   0 running,   2 sleeping,   0 stopped,   0 zombie
%Cpu(s):  0.0 us,  0.0 sy,  3.5 ni, 96.5 id,  0.0 wa,  0.0 hi,  0.0 si,  0.0 st 
MiB Mem :   7639.0 total,   6903.2 free,    573.4 used,    324.7 buff/cache     
MiB Swap:   2048.0 total,   2048.0 free,      0.0 used.   7065.7 avail Mem 

    PID USER      PR  NI    VIRT    RES    SHR S  %CPU  %MEM     TIME+ COMMAND
   1921 jae0608   30  10   24404  18452  10112 S  50.0   0.2   0:00.29 agent-leak-app
   1920 jae0608   20   0    3000   2244   2024 S   0.0   0.0   0:00.06 agent-leak-app

```

[원본 2481~2490행](../evidence/cpu-80-pty-20261009-115744/top.log#L2481-L2490)


| 옵션 | 목적 | 출력과의 관계 |
|---|---|---|
| LC_ALL=C | 표시 언어·지역 형식 통일 | 영문 열 제목과 소수점 파싱 |
| -b | 배치모드 | 키보드로 조작하는 화면 대신 텍스트 반복 출력 |
| -d 0.1 | 갱신 간격 지정 | 짧은 부하를 0.1초 간격으로 관측. 정확한 실측 간격과 완전히 같다고 보장하지 않음 |
| -n 450 | 반복 450회 후 top 종료 | 앱이 종료돼서 top이 끝난 것인지 별도 확인 필요 |
| -w 180 | 출력 폭 180열 | 명령 이름 등의 잘림 감소 |
| -p "$TOP_PIDS" | 쉼표로 연결한 PID 목록만 관제 | 이 화면은 특정 앱 대상 |

| 화면의항목 | 뜻 | 해석 |
|---|---|---|
| top - 시각 / up / user | 조회 시각·시스템 가동 시간·로그인 사용자 수 | up은 해당 앱 생존 시간이 아님 |
| load average 세값 | 일반적으로 1·5·15분 시스템 부하 평균 | CPU%아님 |
| Tasks: 2 total ... | PID 필터에 따른 화면의 작업 수·상태 | 노트북 전체 프로세스가 2개라는 뜻으로 읽지 않음 |
| %Cpu(s): us/sy/ni/id/wa/hi/si/st | 사용자/커널/nice사용자/유휴/I/O대기/하드웨어IRQ/소프트웨어IRQ/도난시간등 | 시스템 전체 요약. 아래 PID별 %CPU와 분모가 다름 |
| MiB Mem/Swap | 시스템 RAM·스왑 요약 | 프로세스별 메모리 한도 설정과 다름 |
| PID / USER | 프로세스 번호/소유 사용자 | 작업자와 실행기를 분리해 읽음 |
| PR / NI | 스케줄링 우선순위 표시/nice 조정값 | NI 10은 기본 0보다 낮은 우선순위의 조정값 |
| VIRT / RES / SHR | 가상 메모리/상주 메모리/공유 가능 메모리 표시 | 표시 기본 단위와 접미사를 확인. 세 값을 합산하지 않음 |
| S | 표본 순간 프로세스 상태 | S는 수면. R은 실행·실행 가능. 구간 CPU가 있어도 마지막 순간 S일 수 있음 |
| %CPU | 해당 PID의 갱신 구간 CPU 사용률 | 기본 Irix 모드에서 100은 논리 CPU 하나 기준 |
| %MEM | 프로세스 상주 메모리 비율 | 앱 MEMORY_LIMIT 대비 비율이 아님 |
| TIME+ | 누적 CPU 사용 시간 | 벽시계 경과 시간과 다름 |
| COMMAND | 명령 이름 | 동일 이름의 부모·자식은 PID/PPID 로그와 대조 |

**이 화면의 두 행:** PID1921는 작업 프로세스이며 구간 CPU50.0%입니다. PID1920는 실행기로0.0%입니다. 같은 이름을 합쳐 노트북 전체 CPU로 설명하지 않습니다. 첫 프레임을 빼는 이유는 이후 갱신 구간과 측정 기준이 다르기 때문입니다.

**집계 코드도 읽기:** awk에서 `/^top -/`는 화면 시작 행을 찾고 frame을 늘립니다. `frame > 1`은 첫 화면 제외, 숫자 PID 검사는 헤더 제외,`$NF == "agent-leak-app"`는 명령 이름 확인입니다. `p=$1; c=$9+0`는 PID와 %CPU를 숫자로 읽고,`peak[p]`는 PID별 최대,`n[p]++`는 대상 행 개수를 셉니다. MAX_CPU는 관측 표본의 최대이고 SAMPLES는 유효 행 수입니다. 화면 열이 바뀌면 $9 파싱도 확인해야 합니다.

**판단 범위:** 이 한 화면은 구간 상승을 보여줍니다. 전체 top 로그의 시작·끝·표본 수와 앱 보호 로그를 함께 읽어야 종료와 관련지을 수 있습니다.

## 해설 16

**대상: evidence/cpu-40-pty-20261009-122044/app.log**

[원본 app.log 열기](../evidence/cpu-40-pty-20261009-122044/app.log) · [발표 대본으로 돌아가기](presentation-walkthrough.md)

**파일의역할:** CPU 40 조건에서 작업이 진행하고 냉각하는 앱 기록입니다. 길이가 길어 필요 구간별로 읽습니다.

**원본 출력·저장 내용 발췌 — 이 블록을 실행하지 않습니다.**

```text
2026-10-09 12:21:06,415 [INFO] [CpuWorker] Current Load: 38.47%
2026-10-09 12:21:08,526 [INFO] [CpuWorker] Peak reached (40.00%). Starting cooldown...
2026-10-09 12:21:08,953 [INFO] [MemoryWorker] Current Heap: 200MB
2026-10-09 12:21:09,526 [INFO] [CpuWorker] Current Load: 40.00%
2026-10-09 12:21:11,987 [INFO] [MemoryWorker] Current Heap: 225MB
2026-10-09 12:21:12,642 [INFO] [CpuWorker] Current Load: 32.54%
```

[원본 68~73행](../evidence/cpu-40-pty-20261009-122044/app.log#L68-L73)


**원본 출력·저장 내용 발췌 — 이 블록을 실행하지 않습니다.**

```text
2026-10-09 12:21:33,450 [INFO] [CpuWorker] Cooldown complete (5.00%). Resuming load increase...
2026-10-09 12:21:34,456 [INFO] [CpuWorker] Current Load: 5.00%
```

[원본 87~88행](../evidence/cpu-40-pty-20261009-122044/app.log#L87-L88)


| 문장 | 뜻 | 이렇게읽는이유 |
|---|---|---|
| Started. Maximum CPU Limit: 40% | 앱이 40 설정을 읽고 CPU 작업 시작 | 환경 설정과 부팅 조건 대조 |
| Peak reached (40.00%). Starting cooldown... | 내부 부하가 40에 도달해 냉각 전환 | 강제 종료 문구와 다른 동작 |
| Current Load: 40.00% → 32.54% | 부하가 낮아지는 구간 | 실제 시간이 진행하는 로그로 확인 |
| Cooldown complete (5.00%). Resuming load increase... | 5까지 낮춘 뒤 재상승 전환 | 주기적인 동작이지 로그 정체가 아님 |
| MemoryWorker Current Heap... | 같은 정상 진행 경로의 메모리 작업 | 메모리 증가 한 줄만 보고 모든 경로를 누수로 확정하지 않음 |
| Memory Cache Flushed / MEMORY RECOVERED | 별도 메모리 회수 로그 | 실제 해당 구간을 열어 확인. OOM 128/256 단일 변수 비교에 섞지 않음 |
| 마지막 Script done ... 143 | 기록 세션의 종료 상태 | 해당 실행의 cleanup.log와 대조해 수동 정리 구분 |

**무엇을 확인했나:** 55초 시점 생존·진행과 냉각을 확인했습니다. 파일 끝 시각만으로 전체 기간 연속 관제나 서비스 응답 개선을 보장하지 않습니다.

## 해설 17

**대상: evidence/cpu-40-pty-20261009-122044/top.log**

[원본 top.log 열기](../evidence/cpu-40-pty-20261009-122044/top.log) · [발표 대본으로 돌아가기](presentation-walkthrough.md)

**생성 방법:** CPU 실험의 `LC_ALL=C top -b -d 0.1 -n 450 -w 180 -p "$TOP_PIDS"` 결과를 저장했습니다. 아래는 첫 프레임을 제외한 최대40.0%가 처음 나타나는 실제 화면입니다.

**원본 출력·저장 내용 발췌 — 이 블록을 실행하지 않습니다.**

```text
top - 12:21:06 up  1:38,  1 user,  load average: 0.04, 0.04, 0.00
Tasks:   2 total,   0 running,   2 sleeping,   0 stopped,   0 zombie
%Cpu(s):  0.0 us,  0.0 sy,  2.1 ni, 97.9 id,  0.0 wa,  0.0 hi,  0.0 si,  0.0 st 
MiB Mem :   7639.0 total,   6750.5 free,    725.6 used,    325.3 buff/cache     
MiB Swap:   2048.0 total,   2048.0 free,      0.0 used.   6913.4 avail Mem 

    PID USER      PR  NI    VIRT    RES    SHR S  %CPU  %MEM     TIME+ COMMAND
   2359 jae0608   30  10  351096 197776  10124 S  40.0   2.5   0:00.35 agent-leak-app
   2358 jae0608   20   0    3000   2248   2020 S   0.0   0.0   0:00.07 agent-leak-app

```

[원본 1941~1950행](../evidence/cpu-40-pty-20261009-122044/top.log#L1941-L1950)


| 옵션 | 목적 | 출력과의 관계 |
|---|---|---|
| LC_ALL=C | 표시 언어·지역 형식 통일 | 영문 열 제목과 소수점 파싱 |
| -b | 배치모드 | 키보드로 조작하는 화면 대신 텍스트 반복 출력 |
| -d 0.1 | 갱신 간격 지정 | 짧은 부하를 0.1초 간격으로 관측. 정확한 실측 간격과 완전히 같다고 보장하지 않음 |
| -n 450 | 반복 450회 후 top 종료 | 앱이 종료돼서 top이 끝난 것인지 별도 확인 필요 |
| -w 180 | 출력 폭 180열 | 명령 이름 등의 잘림 감소 |
| -p "$TOP_PIDS" | 쉼표로 연결한 PID 목록만 관제 | 이 화면은 특정 앱 대상 |

| 화면의항목 | 뜻 | 해석 |
|---|---|---|
| top - 시각 / up / user | 조회 시각·시스템 가동 시간·로그인 사용자 수 | up은 해당 앱 생존 시간이 아님 |
| load average 세값 | 일반적으로 1·5·15분 시스템 부하 평균 | CPU%아님 |
| Tasks: 2 total ... | PID 필터에 따른 화면의 작업 수·상태 | 노트북 전체 프로세스가 2개라는 뜻으로 읽지 않음 |
| %Cpu(s): us/sy/ni/id/wa/hi/si/st | 사용자/커널/nice사용자/유휴/I/O대기/하드웨어IRQ/소프트웨어IRQ/도난시간등 | 시스템 전체 요약. 아래 PID별 %CPU와 분모가 다름 |
| MiB Mem/Swap | 시스템 RAM·스왑 요약 | 프로세스별 메모리 한도 설정과 다름 |
| PID / USER | 프로세스 번호/소유 사용자 | 작업자와 실행기를 분리해 읽음 |
| PR / NI | 스케줄링 우선순위 표시/nice 조정값 | NI 10은 기본 0보다 낮은 우선순위의 조정값 |
| VIRT / RES / SHR | 가상 메모리/상주 메모리/공유 가능 메모리 표시 | 표시 기본 단위와 접미사를 확인. 세 값을 합산하지 않음 |
| S | 표본 순간 프로세스 상태 | S는 수면. R은 실행·실행 가능. 구간 CPU가 있어도 마지막 순간 S일 수 있음 |
| %CPU | 해당 PID의 갱신 구간 CPU 사용률 | 기본 Irix 모드에서 100은 논리 CPU 하나 기준 |
| %MEM | 프로세스 상주 메모리 비율 | 앱 MEMORY_LIMIT 대비 비율이 아님 |
| TIME+ | 누적 CPU 사용 시간 | 벽시계 경과 시간과 다름 |
| COMMAND | 명령 이름 | 동일 이름의 부모·자식은 PID/PPID 로그와 대조 |

**이 화면의 두 행:** PID2359는 작업 프로세스이며 구간 CPU40.0%입니다. PID2358는 실행기로0.0%입니다. 같은 이름을 합쳐 노트북 전체 CPU로 설명하지 않습니다. 첫 프레임을 빼는 이유는 이후 갱신 구간과 측정 기준이 다르기 때문입니다.

**집계 코드도 읽기:** awk에서 `/^top -/`는 화면 시작 행을 찾고 frame을 늘립니다. `frame > 1`은 첫 화면 제외, 숫자 PID 검사는 헤더 제외,`$NF == "agent-leak-app"`는 명령 이름 확인입니다. `p=$1; c=$9+0`는 PID와 %CPU를 숫자로 읽고,`peak[p]`는 PID별 최대,`n[p]++`는 대상 행 개수를 셉니다. MAX_CPU는 관측 표본의 최대이고 SAMPLES는 유효 행 수입니다. 화면 열이 바뀌면 $9 파싱도 확인해야 합니다.

**판단 범위:** 이 한 화면은 구간 상승을 보여줍니다. 전체 top 로그의 시작·끝·표본 수와 앱 보호 로그를 함께 읽어야 종료와 관련지을 수 있습니다.

## 해설 18

**대상: evidence/cpu-40-pty-20261009-122044/ps-check.txt**

[원본 ps-check.txt 열기](../evidence/cpu-40-pty-20261009-122044/ps-check.txt) · [발표 대본으로 돌아가기](presentation-walkthrough.md)

**조회 구문:** `ps -p "$TOP_PIDS" -o pid,ppid,etimes,pcpu,pmem,rss,nlwp,stat`처럼대상을 지정하고 필요 열을 골라 저장한 결과입니다. 이 설명은 과거 구문 해설이며 새 PID 변수가 준비되지 않았다면 그대로 실행하지 않습니다.

**원본 출력·저장 내용 발췌 — 이 블록을 실행하지 않습니다.**

```text
    PID    PPID ELAPSED %CPU %MEM   RSS NLWP STAT
   2358    2356      55  0.1  0.0  2248    1 Ss+
   2359    2358      55  1.4  6.1 479420   3 SNl+
```

[원본 1~3행](../evidence/cpu-40-pty-20261009-122044/ps-check.txt#L1-L3)


| 열 | PID2359행값 | 해석 |
|---|---|---|
| PID / PPID | 2359 / 2358 | 작업 프로세스와 실행 부모 |
| ELAPSED | 55 | 해당 프로세스가 시작된 뒤 경과 초 |
| %CPU | 1.4 | ps 누적 평균. top 최대 40과 다른 기간 |
| %MEM | 6.1 | Linux 물리 메모리 대비 상주 비율 |
| RSS | 479420 | KiB 단위 상주량. 약468.184MiB |
| NLWP | 3 | 스레드 3개 존재. false라고 1개로 단정할 수 없는 실제 자료 |
| STAT | SNl+ | 수면·낮은 우선순위·멀티스레드·터미널 전경 그룹 |
| PID2358의RSS2248 | 실행기 행 | 작업자 행의 자원 사용과 구분 |

**결론:** 55초 관측 시점에 프로세스가 존재합니다. 실제 진행 여부는 앞의 냉각·작업 로그와 함께 확인합니다.

## 해설 19

**대상: reports/03-deadlock.md**

[원본 03-deadlock.md 열기](../reports/03-deadlock.md) · [발표 대본으로 돌아가기](presentation-walkthrough.md)

**문서의 역할:** Deadlock 장애를 GitHub Issue 구조의 Markdown으로 정리한 보고서입니다. PID 유지와 정체, 락 보유·추가 요청의 순환 관계, false설정의 작업 진행을 연결합니다.

| 구성 | 질문 | 코드와 출력의 해석 |
|---|---|---|
| Description | 어떤 조건에서 무엇이 관측됐나? | 설정·PID·시각·증상의 표를 먼저 읽습니다. |
| Evidence & Logs | 무슨 파일로 판단했나? | 재현 코드와 실제 출력을 구분합니다. bash 블록의 예전 구문은 준비된 변수·PID를 전제로 합니다. |
| Root Cause Analysis | 증거가 어떤 원리를 가리키나? | 관측 사실과 추론을 나눕니다. 내부 코드 위치·측정하지 않은 지표는 단정하지 않습니다. |
| Workaround & Verification | 무엇을 바꿨고 결과는? | 변경 변수와 고정 변수를 확인하고 동일 지표로 비교합니다. 수동 정리도 표시합니다. |

**코드에서 보이는 기호:** `source`는 현재 셸 설정 적용, `export`는 자식에게 환경 전달, `&`는 백그라운드 실행, `$!`는 직전 작업 PID, `>`는 파일 저장, `2>&1`은 표준 오류를 현재 표준 출력 대상으로 보냅니다. 코드를 읽는 것만으로 과거 실행을 다시 수행한 것은 아닙니다.

**원본 숫자와 함께 볼 점:** RSS와 로그 크기를 두 시점에서 비교합니다. futex 단독으로 교착을 확정하지 않고 순환 대기 로그를 함께 봅니다.

## 해설 20

**대상: evidence/deadlock-true-20261009-125943/snapshot-1.txt**

[원본 snapshot-1.txt 열기](../evidence/deadlock-true-20261009-125943/snapshot-1.txt) · [발표 대본으로 돌아가기](presentation-walkthrough.md)

**생성 순서:** date → ps -ef 필터 → ps -L → stat → tail의 결과를 하나로 묶은 스냅샷입니다. 각 명령은 순차 조회이므로 하나의 원자적 동일 순간은 아닙니다.

**원본 출력·저장 내용 발췌 — 이 블록을 실행하지 않습니다.**

```text
2026-10-09T12:59:55+09:00
jae0608     9223     437  0 12:59 pts/0    00:00:00 script -q -e -f -c ./agent-leak-app /home/jae0608/jae-test/evidence/deadlock-true-20261009-125943/app.log
jae0608     9225    9223  0 12:59 pts/2    00:00:00 ./agent-leak-app
jae0608     9226    9225  0 12:59 pts/2    00:00:00 ./agent-leak-app
    PID     TID %CPU   RSS     TIME STAT WCHAN                            COMMAND
   9226    9226  0.3 18512 00:00:00 SNl+ futex_do_wait                    agent-leak-app
   9226    9297  0.0 18512 00:00:00 SNl+ futex_do_wait                    agent-leak-app
   9226    9298  0.0 18512 00:00:00 SNl+ futex_do_wait                    agent-leak-app
log_bytes=2792 modified=2026-10-09 12:59:52.286312863 +0900
```

[원본 1~9행](../evidence/deadlock-true-20261009-125943/snapshot-1.txt#L1-L9)


| 화면 구성 | 어떻게 생겼나 | 해석 |
|---|---|---|
| 첫 행 | 날짜·시각·+09:00 | 스냅샷 시작 시각입니다. |
| 다음 ps -ef 행 | 사용자 PID PPID C STIME TTY TIME CMD | 계정·프로세스·부모·CPU 활용 지표·시작 시각·터미널·누적 CPU 시간·명령 순입니다. C열을 top 구간 %CPU로 읽지 않습니다. |
| script행 / 앱 두 행 | 세션→실행기→작업자 | 보이는 각 번호를 독립 장애 3건으로 해석하지 않습니다. |
| ps -L -p ... -o ... | PID TID %CPU RSS TIME STAT WCHAN COMMAND | 지정 프로세스 안의 스레드별 상태입니다. |
| PID와TID | 같은 PID/여러 TID | 같은 주소 공간을 공유하는 스레드입니다. 로그의 Worker 이름과 개별 TID 대응은 미확인입니다. |
| RSS 반복 | 각 스레드 행에 같은 값 | 행별로 더하면 메모리를 중복 계산합니다. |
| TIME 00:00:00 | 표시 정밀도에서 누적 CPU 시간이 아주 작음 | 오래 살아 있지 않았다는 뜻이나 절대 CPU 0이라는 뜻은 아닙니다. |
| futex_do_wait | 커널 동기화 대기 위치 | 정상 대기도 가능하므로 이 항목 단독 확정 금지 |
| poll_schedule_timeout... | 이벤트/타임아웃 대기 계열 위치 | false 워커의 정상 작업 사이 대기일 수 있으며 로그 진행과 대조 |
| log_bytes / modified | stat의 파일 크기 바이트·수정 시각 | 조회 시각이 아닌 파일의 마지막 수정 시각입니다. 다음 스냅샷과 비교 |

**이 파일의 비교 위치:** 첫 관측12:59:55입니다. 다음 관측13:00:05와비교합니다.

**전후 결과:** RSS18512→18512KiB,로그 2792→2792바이트이고수정 시각도 유지됐습니다. CPU 평균 0.3→0.1은 평균 분모 변화일 수 있으며 작업 재개 증거가 아닙니다. 마지막 로그의 서로 반대인 락 대기와 결합해 정체를 진단합니다.

### 스냅샷을 만드는 명령의 옵션

- `ps -ef`: 전체 프로세스를 자세한 형식으로 조회합니다. `grep '[a]gent-leak-app'`는 앱 이름을 찾으면서 grep 자신의 명령행이 검색되는 현상을 피하는 표현입니다.
- `ps -L -p "$WORKER_PID"`: 대상 PID의 스레드별 행을 봅니다. `-o pid,tid,pcpu,rss,time,stat,wchan:32,comm`는 출력 열과 순서를 지정하며 `wchan:32`는 대기 위치 표시 폭을32자로 지정합니다.
- `stat -c 'log_bytes=%s modified=%y' "$RUN_DIR/app.log"`: `-c`로 출력 형식을 지정합니다. stat의 `%s`는 바이트 크기, `%y`는 수정 시각입니다. printf의 `%s`와는 도구가 다른 형식 기호입니다.
- `tail -n 20 "$RUN_DIR/app.log"`: 파일의 마지막20줄을 봅니다. 수집 코드에 지정한 줄 수만 발췌하므로 파일 전체가 아닐 수 있습니다.
- `{ ...; } | tee 파일`: 묶은 명령의 표준 출력을 화면과 파일 양쪽에 보냅니다. 이 구문 자체가 모든 명령의 성공을 보장하지는 않습니다.

## 해설 21

**대상: evidence/deadlock-true-20261009-125943/snapshot-2.txt**

[원본 snapshot-2.txt 열기](../evidence/deadlock-true-20261009-125943/snapshot-2.txt) · [발표 대본으로 돌아가기](presentation-walkthrough.md)

**생성 순서:** date → ps -ef 필터 → ps -L → stat → tail의 결과를 하나로 묶은 스냅샷입니다. 각 명령은 순차 조회이므로 하나의 원자적 동일 순간은 아닙니다.

**원본 출력·저장 내용 발췌 — 이 블록을 실행하지 않습니다.**

```text
2026-10-09T13:00:05+09:00
jae0608     9223     437  0 12:59 pts/0    00:00:00 script -q -e -f -c ./agent-leak-app /home/jae0608/jae-test/evidence/deadlock-true-20261009-125943/app.log
jae0608     9225    9223  0 12:59 pts/2    00:00:00 ./agent-leak-app
jae0608     9226    9225  0 12:59 pts/2    00:00:00 ./agent-leak-app
    PID     TID %CPU   RSS     TIME STAT WCHAN                            COMMAND
   9226    9226  0.1 18512 00:00:00 SNl+ futex_do_wait                    agent-leak-app
   9226    9297  0.0 18512 00:00:00 SNl+ futex_do_wait                    agent-leak-app
   9226    9298  0.0 18512 00:00:00 SNl+ futex_do_wait                    agent-leak-app
log_bytes=2792 modified=2026-10-09 12:59:52.286312863 +0900
```

[원본 1~9행](../evidence/deadlock-true-20261009-125943/snapshot-2.txt#L1-L9)


| 화면 구성 | 어떻게 생겼나 | 해석 |
|---|---|---|
| 첫 행 | 날짜·시각·+09:00 | 스냅샷 시작 시각입니다. |
| 다음 ps -ef 행 | 사용자 PID PPID C STIME TTY TIME CMD | 계정·프로세스·부모·CPU 활용 지표·시작 시각·터미널·누적 CPU 시간·명령 순입니다. C열을 top 구간 %CPU로 읽지 않습니다. |
| script행 / 앱 두 행 | 세션→실행기→작업자 | 보이는 각 번호를 독립 장애 3건으로 해석하지 않습니다. |
| ps -L -p ... -o ... | PID TID %CPU RSS TIME STAT WCHAN COMMAND | 지정 프로세스 안의 스레드별 상태입니다. |
| PID와TID | 같은 PID/여러 TID | 같은 주소 공간을 공유하는 스레드입니다. 로그의 Worker 이름과 개별 TID 대응은 미확인입니다. |
| RSS 반복 | 각 스레드 행에 같은 값 | 행별로 더하면 메모리를 중복 계산합니다. |
| TIME 00:00:00 | 표시 정밀도에서 누적 CPU 시간이 아주 작음 | 오래 살아 있지 않았다는 뜻이나 절대 CPU 0이라는 뜻은 아닙니다. |
| futex_do_wait | 커널 동기화 대기 위치 | 정상 대기도 가능하므로 이 항목 단독 확정 금지 |
| poll_schedule_timeout... | 이벤트/타임아웃 대기 계열 위치 | false 워커의 정상 작업 사이 대기일 수 있으며 로그 진행과 대조 |
| log_bytes / modified | stat의 파일 크기 바이트·수정 시각 | 조회 시각이 아닌 파일의 마지막 수정 시각입니다. 다음 스냅샷과 비교 |

**이 파일의 비교 위치:** 두 번째 관측13:00:05입니다. 첫 관측12:59:55와비교합니다.

**전후 결과:** RSS18512→18512KiB,로그 2792→2792바이트이고수정 시각도 유지됐습니다. CPU 평균 0.3→0.1은 평균 분모 변화일 수 있으며 작업 재개 증거가 아닙니다. 마지막 로그의 서로 반대인 락 대기와 결합해 정체를 진단합니다.

### 스냅샷을 만드는 명령의 옵션

- `ps -ef`: 전체 프로세스를 자세한 형식으로 조회합니다. `grep '[a]gent-leak-app'`는 앱 이름을 찾으면서 grep 자신의 명령행이 검색되는 현상을 피하는 표현입니다.
- `ps -L -p "$WORKER_PID"`: 대상 PID의 스레드별 행을 봅니다. `-o pid,tid,pcpu,rss,time,stat,wchan:32,comm`는 출력 열과 순서를 지정하며 `wchan:32`는 대기 위치 표시 폭을32자로 지정합니다.
- `stat -c 'log_bytes=%s modified=%y' "$RUN_DIR/app.log"`: `-c`로 출력 형식을 지정합니다. stat의 `%s`는 바이트 크기, `%y`는 수정 시각입니다. printf의 `%s`와는 도구가 다른 형식 기호입니다.
- `tail -n 20 "$RUN_DIR/app.log"`: 파일의 마지막20줄을 봅니다. 수집 코드에 지정한 줄 수만 발췌하므로 파일 전체가 아닐 수 있습니다.
- `{ ...; } | tee 파일`: 묶은 명령의 표준 출력을 화면과 파일 양쪽에 보냅니다. 이 구문 자체가 모든 명령의 성공을 보장하지는 않습니다.

## 해설 22

**대상: evidence/deadlock-true-20261009-125943/app.log**

[원본 app.log 열기](../evidence/deadlock-true-20261009-125943/app.log) · [발표 대본으로 돌아가기](presentation-walkthrough.md)

**읽는 순서:** 부팅 검사 → 동시 모드 경고 → 워커 자원 획득 → 상대 자원 요청 → 마지막 BLOCKED 순서입니다. 경고 문구만으로 교착을 판정하지 않습니다.

**원본 출력·저장 내용 발췌 — 이 블록을 실행하지 않습니다.**

```text
2026-10-09 12:59:50,274 [INFO] [AgentWorker][Worker-Thread-1] LOCK ACQUIRED: [Shared_Memory_A]. (Holding...)
2026-10-09 12:59:50,275 [INFO] [AgentWorker][Worker-Thread-2] LOCK ACQUIRED: [Socket_Pool_B]. (Holding...)
2026-10-09 12:59:50,275 [INFO] [AgentWorker][Worker-Thread-1] Processing critical data in Memory A...
2026-10-09 12:59:50,275 [INFO] [AgentWorker][Worker-Thread-2] Establishing network connections in Pool B...
2026-10-09 12:59:52,284 [INFO] [AgentWorker][Worker-Thread-2] Need resource [Shared_Memory_A] to write logs.
2026-10-09 12:59:52,284 [INFO] [AgentWorker][Worker-Thread-2] WAITING for [Shared_Memory_A]... (Status: BLOCKED)
2026-10-09 12:59:52,286 [INFO] [AgentWorker][Worker-Thread-1] Need resource [Socket_Pool_B] to finish job.
2026-10-09 12:59:52,286 [INFO] [AgentWorker][Worker-Thread-1] WAITING for [Socket_Pool_B]... (Status: BLOCKED)
```

[원본 36~43행](../evidence/deadlock-true-20261009-125943/app.log#L36-L43)


| 로그 | 뜻 | 대기관계 |
|---|---|---|
| Thread-1 LOCK ACQUIRED Shared_Memory_A (Holding...) | T1이 A 자원을 획득하고 보유 | A 소유자는 T1 |
| Thread-2 LOCK ACQUIRED Socket_Pool_B (Holding...) | T2가 B 자원을 획득하고 보유 | B 소유자는 T2 |
| Thread-2 Need/WAITING Shared_Memory_A | T2가 A를 요청하지만 대기 | T2 → A(T1보유) |
| Thread-1 Need/WAITING Socket_Pool_B | T1이 B를 요청하지만 대기 | T1 → B(T2보유) |
| Status: BLOCKED | 앱이 표현한 자원 대기 상태 | OS의 STAT 열 B 같은 코드로 오해하지 않음 |
| Waiting for worker threads to complete | 메인도 워커 완료를 기다리는 설명 | 실제 스레드 WCHAN과 대조 |

**왜 이 상태에서 끝나지 않나:** T1이 진행하려면 T2가 B를 놓아야 하고 T2가 진행하려면 T1이 A를 놓아야 하는 순환 관계입니다. 타임아웃·해제의 내부 구현은 확인하지 않았습니다. 반복 스냅샷의 정체와 함께 교착으로 판단합니다.

## 해설 23

**대상: evidence/deadlock-false-20261009-130309/snapshot-1.txt**

[원본 snapshot-1.txt 열기](../evidence/deadlock-false-20261009-130309/snapshot-1.txt) · [발표 대본으로 돌아가기](presentation-walkthrough.md)

**생성 순서:** date → ps -ef 필터 → ps -L → stat → tail의 결과를 하나로 묶은 스냅샷입니다. 각 명령은 순차 조회이므로 하나의 원자적 동일 순간은 아닙니다.

**원본 출력·저장 내용 발췌 — 이 블록을 실행하지 않습니다.**

```text
2026-10-09T13:03:21+09:00
jae0608    11291     437  0 13:03 pts/0    00:00:00 script -q -e -f -c ./agent-leak-app /home/jae0608/jae-test/evidence/deadlock-false-20261009-130309/app.log
jae0608    11293   11291  0 13:03 pts/2    00:00:00 ./agent-leak-app
jae0608    11294   11293  1 13:03 pts/2    00:00:00 ./agent-leak-app
    PID     TID %CPU   RSS     TIME STAT WCHAN                            COMMAND
  11294   11294  0.3 121000 00:00:00 SNl+ futex_do_wait                   agent-leak-app
  11294   11314  0.6 121000 00:00:00 SNl+ poll_schedule_timeout.constprop. agent-leak-app
  11294   11315  0.4 121000 00:00:00 SNl+ poll_schedule_timeout.constprop. agent-leak-app
log_bytes=3474 modified=2026-10-09 13:03:21.368107854 +0900
```

[원본 1~9행](../evidence/deadlock-false-20261009-130309/snapshot-1.txt#L1-L9)


| 화면 구성 | 어떻게 생겼나 | 해석 |
|---|---|---|
| 첫 행 | 날짜·시각·+09:00 | 스냅샷 시작 시각입니다. |
| 다음 ps -ef 행 | 사용자 PID PPID C STIME TTY TIME CMD | 계정·프로세스·부모·CPU 활용 지표·시작 시각·터미널·누적 CPU 시간·명령 순입니다. C열을 top 구간 %CPU로 읽지 않습니다. |
| script행 / 앱 두 행 | 세션→실행기→작업자 | 보이는 각 번호를 독립 장애 3건으로 해석하지 않습니다. |
| ps -L -p ... -o ... | PID TID %CPU RSS TIME STAT WCHAN COMMAND | 지정 프로세스 안의 스레드별 상태입니다. |
| PID와TID | 같은 PID/여러 TID | 같은 주소 공간을 공유하는 스레드입니다. 로그의 Worker 이름과 개별 TID 대응은 미확인입니다. |
| RSS 반복 | 각 스레드 행에 같은 값 | 행별로 더하면 메모리를 중복 계산합니다. |
| TIME 00:00:00 | 표시 정밀도에서 누적 CPU 시간이 아주 작음 | 오래 살아 있지 않았다는 뜻이나 절대 CPU 0이라는 뜻은 아닙니다. |
| futex_do_wait | 커널 동기화 대기 위치 | 정상 대기도 가능하므로 이 항목 단독 확정 금지 |
| poll_schedule_timeout... | 이벤트/타임아웃 대기 계열 위치 | false 워커의 정상 작업 사이 대기일 수 있으며 로그 진행과 대조 |
| log_bytes / modified | stat의 파일 크기 바이트·수정 시각 | 조회 시각이 아닌 파일의 마지막 수정 시각입니다. 다음 스냅샷과 비교 |

**이 파일의 비교 위치:** 첫 관측13:03:21입니다. 다음 관측13:03:31과비교합니다.

**전후 결과:** RSS121000→197812KiB,로그3474→3870바이트로 396바이트 증가했습니다. 파일의 뒤쪽 MemoryWorker/CpuWorker 로그도 실제 진행합니다. 값 증가만으로 정상이라고 판정하지 않고 진행 로그와 함께 관측 구간 회피를 판단합니다.

### 스냅샷을 만드는 명령의 옵션

- `ps -ef`: 전체 프로세스를 자세한 형식으로 조회합니다. `grep '[a]gent-leak-app'`는 앱 이름을 찾으면서 grep 자신의 명령행이 검색되는 현상을 피하는 표현입니다.
- `ps -L -p "$WORKER_PID"`: 대상 PID의 스레드별 행을 봅니다. `-o pid,tid,pcpu,rss,time,stat,wchan:32,comm`는 출력 열과 순서를 지정하며 `wchan:32`는 대기 위치 표시 폭을32자로 지정합니다.
- `stat -c 'log_bytes=%s modified=%y' "$RUN_DIR/app.log"`: `-c`로 출력 형식을 지정합니다. stat의 `%s`는 바이트 크기, `%y`는 수정 시각입니다. printf의 `%s`와는 도구가 다른 형식 기호입니다.
- `tail -n 20 "$RUN_DIR/app.log"`: 파일의 마지막20줄을 봅니다. 수집 코드에 지정한 줄 수만 발췌하므로 파일 전체가 아닐 수 있습니다.
- `{ ...; } | tee 파일`: 묶은 명령의 표준 출력을 화면과 파일 양쪽에 보냅니다. 이 구문 자체가 모든 명령의 성공을 보장하지는 않습니다.

## 해설 24

**대상: evidence/deadlock-false-20261009-130309/snapshot-2.txt**

[원본 snapshot-2.txt 열기](../evidence/deadlock-false-20261009-130309/snapshot-2.txt) · [발표 대본으로 돌아가기](presentation-walkthrough.md)

**생성 순서:** date → ps -ef 필터 → ps -L → stat → tail의 결과를 하나로 묶은 스냅샷입니다. 각 명령은 순차 조회이므로 하나의 원자적 동일 순간은 아닙니다.

**원본 출력·저장 내용 발췌 — 이 블록을 실행하지 않습니다.**

```text
2026-10-09T13:03:31+09:00
jae0608    11291     437  0 13:03 pts/0    00:00:00 script -q -e -f -c ./agent-leak-app /home/jae0608/jae-test/evidence/deadlock-false-20261009-130309/app.log
jae0608    11293   11291  0 13:03 pts/2    00:00:00 ./agent-leak-app
jae0608    11294   11293  1 13:03 pts/2    00:00:00 ./agent-leak-app
    PID     TID %CPU   RSS     TIME STAT WCHAN                            COMMAND
  11294   11294  0.2 197812 00:00:00 SNl+ futex_do_wait                   agent-leak-app
  11294   11314  0.5 197812 00:00:00 SNl+ poll_schedule_timeout.constprop. agent-leak-app
  11294   11315  0.7 197812 00:00:00 SNl+ poll_schedule_timeout.constprop. agent-leak-app
log_bytes=3870 modified=2026-10-09 13:03:30.720105197 +0900
```

[원본 1~9행](../evidence/deadlock-false-20261009-130309/snapshot-2.txt#L1-L9)


| 화면 구성 | 어떻게 생겼나 | 해석 |
|---|---|---|
| 첫 행 | 날짜·시각·+09:00 | 스냅샷 시작 시각입니다. |
| 다음 ps -ef 행 | 사용자 PID PPID C STIME TTY TIME CMD | 계정·프로세스·부모·CPU 활용 지표·시작 시각·터미널·누적 CPU 시간·명령 순입니다. C열을 top 구간 %CPU로 읽지 않습니다. |
| script행 / 앱 두 행 | 세션→실행기→작업자 | 보이는 각 번호를 독립 장애 3건으로 해석하지 않습니다. |
| ps -L -p ... -o ... | PID TID %CPU RSS TIME STAT WCHAN COMMAND | 지정 프로세스 안의 스레드별 상태입니다. |
| PID와TID | 같은 PID/여러 TID | 같은 주소 공간을 공유하는 스레드입니다. 로그의 Worker 이름과 개별 TID 대응은 미확인입니다. |
| RSS 반복 | 각 스레드 행에 같은 값 | 행별로 더하면 메모리를 중복 계산합니다. |
| TIME 00:00:00 | 표시 정밀도에서 누적 CPU 시간이 아주 작음 | 오래 살아 있지 않았다는 뜻이나 절대 CPU 0이라는 뜻은 아닙니다. |
| futex_do_wait | 커널 동기화 대기 위치 | 정상 대기도 가능하므로 이 항목 단독 확정 금지 |
| poll_schedule_timeout... | 이벤트/타임아웃 대기 계열 위치 | false 워커의 정상 작업 사이 대기일 수 있으며 로그 진행과 대조 |
| log_bytes / modified | stat의 파일 크기 바이트·수정 시각 | 조회 시각이 아닌 파일의 마지막 수정 시각입니다. 다음 스냅샷과 비교 |

**이 파일의 비교 위치:** 두 번째 관측13:03:31입니다. 첫 관측13:03:21과비교합니다.

**전후 결과:** RSS121000→197812KiB,로그3474→3870바이트로 396바이트 증가했습니다. 파일의 뒤쪽 MemoryWorker/CpuWorker 로그도 실제 진행합니다. 값 증가만으로 정상이라고 판정하지 않고 진행 로그와 함께 관측 구간 회피를 판단합니다.

### 스냅샷을 만드는 명령의 옵션

- `ps -ef`: 전체 프로세스를 자세한 형식으로 조회합니다. `grep '[a]gent-leak-app'`는 앱 이름을 찾으면서 grep 자신의 명령행이 검색되는 현상을 피하는 표현입니다.
- `ps -L -p "$WORKER_PID"`: 대상 PID의 스레드별 행을 봅니다. `-o pid,tid,pcpu,rss,time,stat,wchan:32,comm`는 출력 열과 순서를 지정하며 `wchan:32`는 대기 위치 표시 폭을32자로 지정합니다.
- `stat -c 'log_bytes=%s modified=%y' "$RUN_DIR/app.log"`: `-c`로 출력 형식을 지정합니다. stat의 `%s`는 바이트 크기, `%y`는 수정 시각입니다. printf의 `%s`와는 도구가 다른 형식 기호입니다.
- `tail -n 20 "$RUN_DIR/app.log"`: 파일의 마지막20줄을 봅니다. 수집 코드에 지정한 줄 수만 발췌하므로 파일 전체가 아닐 수 있습니다.
- `{ ...; } | tee 파일`: 묶은 명령의 표준 출력을 화면과 파일 양쪽에 보냅니다. 이 구문 자체가 모든 명령의 성공을 보장하지는 않습니다.

## 해설 25

**대상: evidence/cpu-40-pty-20261009-122044/cleanup.log**

[원본 cleanup.log 열기](../evidence/cpu-40-pty-20261009-122044/cleanup.log) · [발표 대본으로 돌아가기](presentation-walkthrough.md)

**생성 구문:** 셸 반복문에서 살아 있는 대상과 명령 이름을 확인한 뒤 `printf ... >> "$RUN_DIR/cleanup.log"`로 기록하고 `kill -TERM "$PID"`를 보냈습니다. `>>`는 덮어쓰지 않고 끝에 추가,`-TERM`은 종료 요청 시그널 지정입니다.

**원본 출력·저장 내용 발췌 — 이 블록을 실행하지 않습니다.**

```text
2026-10-09T12:46:44+09:00 manual SIGTERM PID=2358
2026-10-09T12:46:44+09:00 manual SIGTERM PID=2359
```

[원본 1~2행](../evidence/cpu-40-pty-20261009-122044/cleanup.log#L1-L2)


**각 부분 해석:** 첫 부분은 요청 시각,`manual`은 실험자 조치,`SIGTERM`은 시그널 종류,`PID=`뒤는 대상 번호입니다. 이 문장은 운영체제가 자동 생성한 장애 원인 로그가 아니라 정리 명령에 넣은 추적 기록입니다.

**왜 행 개수가 다를 수 있나:** 부모를 종료한 후 자식도 사라지면 다음 반복의 프로세스 확인 조건이 거짓이 되어 자식 행을 기록하지 않을 수 있습니다. 특히 Deadlock 원본에는 부모 PID 9225 한 행만 있습니다. 기록 없는 자식에 직접 시그널을 보냈다고 주장하지 않습니다. 실제 종료 확인은 ps와 wait를 함께 봅니다.

## 해설 26

**대상: evidence/deadlock-true-20261009-125943/cleanup.log**

[원본 cleanup.log 열기](../evidence/deadlock-true-20261009-125943/cleanup.log) · [발표 대본으로 돌아가기](presentation-walkthrough.md)

**생성 구문:** 셸 반복문에서 살아 있는 대상과 명령 이름을 확인한 뒤 `printf ... >> "$RUN_DIR/cleanup.log"`로 기록하고 `kill -TERM "$PID"`를 보냈습니다. `>>`는 덮어쓰지 않고 끝에 추가,`-TERM`은 종료 요청 시그널 지정입니다.

**원본 출력·저장 내용 발췌 — 이 블록을 실행하지 않습니다.**

```text
2026-10-09T13:03:05+09:00 manual SIGTERM PID=9225
```

[원본 1~1행](../evidence/deadlock-true-20261009-125943/cleanup.log#L1-L1)


**각 부분 해석:** 첫 부분은 요청 시각,`manual`은 실험자 조치,`SIGTERM`은 시그널 종류,`PID=`뒤는 대상 번호입니다. 이 문장은 운영체제가 자동 생성한 장애 원인 로그가 아니라 정리 명령에 넣은 추적 기록입니다.

**왜 행 개수가 다를 수 있나:** 부모를 종료한 후 자식도 사라지면 다음 반복의 프로세스 확인 조건이 거짓이 되어 자식 행을 기록하지 않을 수 있습니다. 특히 Deadlock 원본에는 부모 PID 9225 한 행만 있습니다. 기록 없는 자식에 직접 시그널을 보냈다고 주장하지 않습니다. 실제 종료 확인은 ps와 wait를 함께 봅니다.

## 해설 27

**대상: evidence/oom-128-20261009-113259/exit-code.txt**

[원본 exit-code.txt 열기](../evidence/oom-128-20261009-113259/exit-code.txt) · [발표 대본으로 돌아가기](presentation-walkthrough.md)

**생성 순서:** `wait "$APP_PID"` 또는PTY실행의 `wait "$SESSION_PID"`가 돌아오면 즉시 `$?`를 변수에 저장한 뒤 파일로 썼습니다. 대상이 앱 실행기인지 script 세션인지 구분하며 기록을 읽습니다.

**원본 출력·저장 내용 발췌 — 이 블록을 실행하지 않습니다.**

```text
137
```

[원본 1~1행](../evidence/oom-128-20261009-113259/exit-code.txt#L1-L1)


**해석:** 137은 Bash의 128+시그널 번호 규칙에서SIGKILL(9)해석과 일치합니다. 숫자 하나인 것은 종료 상태 한 값만 printf로 저장했기 때문입니다. 이 경우 앱 MemoryGuard 로그와 함께 읽습니다. 커널 OOM Killer가 종료했다는 단독 증거는 아닙니다.

**실수 방지:** wait 다음에 echo나 date를 실행하고 나중에 $?를 저장하면 그 명령의 상태를 저장할 수 있습니다. 예전 터미널이 닫히면 새 셸은 기존 작업의 부모가 아니므로 같은 wait를 그대로 재현할 수 없습니다.

## 해설 28

**대상: evidence/cpu-80-pty-20261009-115744/exit-code.txt**

[원본 exit-code.txt 열기](../evidence/cpu-80-pty-20261009-115744/exit-code.txt) · [발표 대본으로 돌아가기](presentation-walkthrough.md)

**생성 순서:** `wait "$APP_PID"` 또는PTY실행의 `wait "$SESSION_PID"`가 돌아오면 즉시 `$?`를 변수에 저장한 뒤 파일로 썼습니다. 대상이 앱 실행기인지 script 세션인지 구분하며 기록을 읽습니다.

**원본 출력·저장 내용 발췌 — 이 블록을 실행하지 않습니다.**

```text
143
```

[원본 1~1행](../evidence/cpu-80-pty-20261009-115744/exit-code.txt#L1-L1)


**해석:** 143은 Bash의 128+시그널 번호 규칙에서SIGTERM(15)해석과 일치합니다. 숫자 하나인 것은 종료 상태 한 값만 printf로 저장했기 때문입니다. 이 경우 앱의 명시적 WATCHDOG/SIGTERM 문장과 함께 읽습니다. 수동 SIGTERM도 143일 수 있으므로 숫자만으로 Watchdog라고 판단하지 않습니다.

**실수 방지:** wait 다음에 echo나 date를 실행하고 나중에 $?를 저장하면 그 명령의 상태를 저장할 수 있습니다. 예전 터미널이 닫히면 새 셸은 기존 작업의 부모가 아니므로 같은 wait를 그대로 재현할 수 없습니다.

## 해설 29

**대상: evidence/cpu-40-pty-20261009-122044/ps-after-cleanup.txt**

[원본 ps-after-cleanup.txt 열기](../evidence/cpu-40-pty-20261009-122044/ps-after-cleanup.txt) · [발표 대본으로 돌아가기](presentation-walkthrough.md)

**조회 구문:** 기록된 PID를 대상으로 ps를 조회해 정리 후 상태를 보존했습니다.

**원본 출력·저장 내용 발췌 — 이 블록을 실행하지 않습니다.**

```text
    PID    PPID ELAPSED %CPU %MEM   RSS NLWP STAT
```

[원본 1~1행](../evidence/cpu-40-pty-20261009-122044/ps-after-cleanup.txt#L1-L1)


**왜 제목만 나왔나:** pid,ppid,etimes,pcpu,pmem,rss,nlwp,stat열을 요청했으나 그 시점 조회 조건에 맞는 데이터 행이 없었습니다. 컬럼 제목의 메모리 값이 0인 행이라는 뜻은 아닙니다. PID 목록과 명령 오류 여부가 맞는지 확인한 뒤 정리 완료의 근거로 사용합니다. 이 파일만으로 이전 종료 원인이 Watchdog인지 수동인지 판정하지 않습니다.

## 해설 30

**대상: templates/issue-report-template.md**

[원본 issue-report-template.md 열기](../templates/issue-report-template.md) · [발표 대본으로 돌아가기](presentation-walkthrough.md)

**파일의 역할:** 새 보고서를 쓸 때 채우는 빈 양식입니다. 중괄호의 {값}, 비어 있는 비교 표와 체크박스는 과거 실행 출력이 아닙니다.

**칸별 의미:** 날짜·시간대는 사건 시각, 환경은 OS·사용자·한도, 폴더/PID는 추적 대상, Before/After는 비교 조건입니다. Description에는 증상, Evidence에는 실제 명령·출력·원본 링크, Root Cause에는 사실·추론·미확인, Workaround에는 변경·결과·한계를 기록합니다.

**코드와 출력 구분:** bash 블록의 주석은 실제 명령을 넣으라는 안내입니다. text 블록의 {날짜·PID·단위가 있는 원본 발췌}는 실제 로그로 교체할 자리입니다. 이를 명령으로 실행하지 않습니다. Markdown의 `- [ ]`는 미체크 항목이며 검증을 마친 뒤 체크합니다.

**이유:** 형식을 통일하면 동료가 현상과 원인 추론, 조치 결과를 빠르게 대조할 수 있습니다. 칸을 채우는 것만으로 미확인 사실이 입증되지는 않습니다.

## 해설 31

**대상: templates/learning-record-template.md**

[원본 learning-record-template.md 열기](../templates/learning-record-template.md) · [발표 대본으로 돌아가기](presentation-walkthrough.md)

**파일의 역할:** 학습자가 새 실습을 하며 직접 작성하는 빈 기록지입니다.

**입력할 내용:** 목적 → 예상 → 실제 명령 → 실제 출력 → 항목별 의미 → 판단 → 미확인 순서입니다. “입력한 명령”에는 코드를, “실제 출력”에는 실행 결과를 넣습니다. 날짜·PID·단위를 기록하며 예전 출력으로 채우지 않습니다.

**수행 상태:** 미실행/실행 확인/출력 해석 가능/본인 설명 가능은 단계별 학습 상태입니다. 스크립트가 자동 판정한 등급이 아닙니다. 설명할 수 없으면 모르는 점을 적습니다.

**비교 표:** Before와 After의 폴더·설정·기간·RSS·CPU·종료 근거를 같은 단위로 적습니다. 비어 있는 표는 오류 출력이 아니라 아직 작성하지 않은 양식입니다.

## 해설 32

**대상: docs/guided-learning.md**

[원본 guided-learning.md 열기](../docs/guided-learning.md) · [발표 대본으로 돌아가기](presentation-walkthrough.md)

**문서의 역할:** 학습을 함께 진행하는 순서입니다. 프로그램 출력이나 실행 스크립트가 아닙니다.

**절차:** 목적과 명령을 읽고 → 직접 한 단계 입력하고 → 실제 출력을 공유하고 → 값과 단위를 해석하고 → 이해 질문에 답한 뒤 → 다음으로 진행합니다.

**예시 해석:** whoami의 jae0608은 현재 사용자 이름, id -u의1000은 사용자 식별자입니다. CPU100%나 메모리1000MB가 아닙니다. 이 답변은 계정 조건만 확인하며 바이너리 호환·포트·키 등 다른 조건까지 보장하지 않습니다.

**필요한 이유:** 잘못된 출력 예시를 명령으로 입력하거나 이해하지 못한 채 다음 실험으로 넘어가는 일을 줄이고, 본인 말로 평가에 답할 수 있도록 돕습니다.
