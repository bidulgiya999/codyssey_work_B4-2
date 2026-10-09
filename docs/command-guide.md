# 명령어·실행 목적·실제 출력 해석 상세 기록

실제로 수행한 작업을 **입력 명령 → 목적·옵션 → 실제 출력 → 판단 → 과제 요구사항** 순서로 설명합니다. 반복 실행은 공통 절차로 묶고, 케이스별 설정·PID는 마지막 표에서 추적합니다. 예상 예시를 실제 측정값처럼 기록하지 않았습니다.

## 1. 환경과 사전 준비

실험일은 2026-10-09 KST, 환경은 Ubuntu 26.04.1 LTS / WSL2 / x86_64입니다. 최종 `nproc`는14, `free -h`는 Linux RAM 7.5GiB와 swap 2.0GiB를 표시했습니다. [환경 원본](../evidence/environment.txt)

Windows의 RAM, WSL에 보이는 RAM, 앱의 MEMORY_LIMIT은 서로 다른 값입니다. MEMORY_LIMIT은 애플리케이션에 전달한 보호 정책 설정입니다.

관리자 PowerShell에서:

```powershell
wsl --install -d Ubuntu
```

`--install`은 WSL·배포판을 설치하고 `-d Ubuntu`는 배포판을 선택합니다. 실제로 WSL3.0.1과 Ubuntu 설치가 완료됐습니다. Ubuntu 일반 계정 jae0608을 생성했습니다. 비밀번호는 기록하지 않습니다.

Ubuntu 창에서:

```bash
cd ~
whoami
id -u
uname -r
uname -m
```

| 명령 | 목적 | 실제 출력의 의미 |
|---|---|---|
| cd ~ | 현재 사용자의 Linux 홈으로 이동 | Windows System32에서 /home/jae0608로 이동 |
| whoami | 사용자 이름 확인 | jae0608 |
| id -u | 숫자 UID 확인 | 1000. root의 UID0이 아님 |
| uname -r | 커널 확인 | 6.18.40.1-microsoft-standard-WSL2 |
| uname -m | CPU 아키텍처 확인 | x86_64 |

`jae0608@HP:~$`는 입력할 코드가 아니라 프롬프트입니다. 사용자·호스트·현재 위치를 표시합니다. root가 아닌 계정 확인은 과제의 첫 실행 조건을 충족하는 증거입니다.

## 2. 제공 파일 선택과 실행 권한

```bash
file /mnt/c/Users/1234v/Downloads/agent-app-leak/agent-leak-app-*
mkdir -p ~/jae-test
cp /mnt/c/Users/1234v/Downloads/agent-app-leak/agent-leak-app-x86 \
  ~/jae-test/agent-leak-app
chmod u+x ~/jae-test/agent-leak-app
ls -lh ~/jae-test/agent-leak-app
```

| 명령·표시 | 목적과 의미 |
|---|---|
| /mnt/c | WSL에서 Windows C드라이브에 접근하는 경로 |
| file | 실행 파일 형식과 CPU 종류 확인. 코드 분석을 하지 않음 |
| * | 이름에 맞는 파일들을 셸이 선택 |
| ELF64 x86-64 | Linux64비트 x86 파일. 이번 머신과 호환되는 파일 형식 |
| ARM aarch64 | ARM용 파일. 이번 실행에서는 x86 파일을 선택 |
| dynamically linked | 동적 로더·라이브러리를 사용하는 파일 형식 |
| mkdir -p | 폴더 생성. 이미 존재해도 그 이유로 실패하지 않음 |
| cp | Windows 다운로드 파일을 Linux 작업 폴더에 복사 |
| chmod u+x | 소유자에게 실행 권한 추가 |
| ls -l / -h | 권한·소유자 등 상세 표시 / 사람이 읽기 쉬운 크기 |

실제 출력:

```text
-rwxr-xr-x 1 jae0608 jae0608 6.3M Oct 9 09:27 /home/jae0608/jae-test/agent-leak-app
```

첫 `-`는 일반 파일입니다. 뒤9글자는 소유자·그룹·기타의 `r` 읽기, `w` 쓰기, `x` 실행 권한입니다. 소유자 jae0608에게 실행 권한이 있음을 확인했습니다.

## 3. 환경변수·필수 디렉터리·키 파일

실제로 저장한 설정 파일:

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

파일 작성에는 아래 형태의 here-document를 사용했습니다.

```bash
cat > ~/jae-test/env.sh <<'EOF'
# 이 사이에 위 export 명령들을 넣었다.
EOF
```

`cat`이 EOF까지의 입력을 파일에 씁니다. `'EOF'`처럼 구분자를 따옴표로 감싸면 파일을 만드는 시점에 `$HOME`을 확장하지 않고 글자 그대로 보관합니다. 이후 source할 때 해당 사용자의 값으로 확장됩니다.

설정 적용:

```bash
source ~/jae-test/env.sh
mkdir -p "$AGENT_UPLOAD_DIR" "$AGENT_KEY_PATH" "$AGENT_LOG_DIR"
printf '%s' 'agent_api_key_test' > "$AGENT_KEY_PATH/secret.key"
chmod 600 "$AGENT_KEY_PATH/secret.key"
```

- `source`는 현재 셸에서 설정을 실행합니다. 파일을 저장한 것만으로 환경변수가 적용되지는 않습니다.
- `export`는 자식 프로그램에도 값을 전달합니다.
- `$HOME`은 사용자 홈이며, 큰따옴표는 경로를 하나의 인자로 전달합니다.
- `printf '%s'`는 문자열을 쓰며 개행을 추가하지 않습니다. 실제 key 파일은18바이트였습니다.
- `>`는 출력 파일을 생성하거나 기존 내용을 덮어씁니다.
- `600`은 소유자 읽기·쓰기만 허용합니다.

검증 명령:

```bash
printenv AGENT_HOME AGENT_PORT AGENT_UPLOAD_DIR AGENT_KEY_PATH AGENT_LOG_DIR \
  MEMORY_LIMIT CPU_MAX_OCCUPY MULTI_THREAD_ENABLE
ls -ld "$AGENT_UPLOAD_DIR" "$AGENT_KEY_PATH" "$AGENT_LOG_DIR"
ls -l "$AGENT_KEY_PATH/secret.key"
```

`printenv`는 요청한 순서로 값만 표시했습니다. 실제 값은 홈 경로,15034,세 디렉터리 경로,128,100,false였습니다. `ls -d`는 디렉터리 자체를 표시합니다. 세 폴더의 소유자와 쓰기 권한, key 파일의 `-rw-------`·18바이트를 확인했습니다.

과제 범위는 MEMORY_LIMIT 50~512 정수, CPU_MAX_OCCUPY10~100 정수, MULTI_THREAD_ENABLE 참/거짓입니다. 설정 파일은 초기 실험값이며 다음 케이스에서는 export로 덮어썼습니다.

## 4. 포트와 부팅 출력

```bash
ss -ltn 'sport = :15034'
```

`ss`는 소켓 상태 조회입니다. `-l`은 대기 중인 소켓, `-t`는 TCP, `-n`은 숫자 표시입니다. 필터는 로컬 포트15034만 선택합니다. 실제로 제목 행만 출력돼 현재 해당 TCP 포트에 대기 서비스가 없음을 확인했습니다.

앱 부팅 로그는 계정·환경변수·파일·포트·로그 권한·미션 설정의 6개 검사에 모두 `[OK]`, 마지막에 `All Boot Checks Passed! / Agent READY`를 표시했습니다.

`Recommend Over 256MB / Recommend Under 50%`는 권장값 안내였습니다. 부팅 검사는 통과했으므로 이를 부팅 실패로 기록하지 않았습니다.

## 5. 증거 폴더와 백그라운드 실행

```bash
RUN_DIR="$AGENT_HOME/evidence/oom-128-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$RUN_DIR"
printf 'MEMORY_LIMIT=%s\nCPU_MAX_OCCUPY=%s\nMULTI_THREAD_ENABLE=%s\n' \
  "$MEMORY_LIMIT" "$CPU_MAX_OCCUPY" "$MULTI_THREAD_ENABLE" \
  > "$RUN_DIR/settings.txt"
date -Iseconds > "$RUN_DIR/started_at.txt"
./agent-leak-app > "$RUN_DIR/app.log" 2>&1 &
APP_PID=$!
```

| 구문 | 의미 |
|---|---|
| RUN_DIR= | 이번 실행의 증거 경로 저장 |
| $(date ...) | 명령 출력으로 날짜·시간을 경로에 포함 |
| %Y%m%d-%H%M%S | 연월일-시분초 형식 |
| settings.txt | 실행 당시 환경변수의 실제 값 보존 |
| date -Iseconds | 시간대가 포함된 ISO 시각 |
| ./ | 현재 폴더의 실행 파일 지정 |
| > app.log | 표준 출력(FD1) 저장 |
| 2>&1 | 오류 출력(FD2)을 현재 표준 출력과 같은 곳에 연결 |
| & | 백그라운드 실행. 다음 명령 입력 가능 |
| $! | 직전 백그라운드 작업의 PID |
| [1] 954 | 작업 번호1, 시작 PID954라는 셸 알림 |

출력 연결은 왼쪽부터 적용하므로 `> file 2>&1` 순서로 사용했습니다. 새로운 증거 경로가 실험 간 덮어쓰기를 막습니다.

실제로 실행 파일은 부모와 작업 자식을 만들었습니다. 부모만 관제하면 자식의 메모리 상승을 놓칠 수 있어 둘 다 관제했습니다.

```bash
pgrep -P "$APP_PID"
pgrep -x agent-leak-app
```

`-P`는 지정 부모의 자식을, `-x`는 정확한 이름을 찾습니다. 일반 실행의 APP_PID와 PTY 실행의 SESSION_PID는 의미가 다릅니다.

## 6. 변수별 역할

| 변수 | 역할 |
|---|---|
| AGENT_HOME | 필수 파일·로그·실행 파일의 기준 경로 |
| RUN_DIR | 한 번의 실행 증거 폴더 |
| APP_PID | 일반 실행에서 시작한 앱 부모 PID |
| SESSION_PID | script로 시작한 PTY 세션 PID |
| APP_PARENT_PID | 별도로 찾아낸 앱 부모 PID |
| WORKER_PID | 실제 작업 자식 PID |
| PID / CHILD_PID | 반복문에서 현재 관제·정리하는 PID |
| TOP_PIDS | top에 전달할 쉼표로 연결된 PID 목록 |
| BEFORE_DIR 등 | 비교 전 증거 폴더를 보존하는 경로 변수 |

PID·경로를 `launcher.pid`, `session.pid`, `worker.pid`, `observed-pids.txt` 등에도 저장했습니다. 셸 변수가 없어져도 원본 파일을 추적할 수 있습니다.

## 7. monitor.sh: 코드의 목적과 CSV 해석

제공 폴더에는 monitor.sh가 없어 직접 작성했습니다. [사용한 원문](../scripts/monitor.sh)

1. `LC_ALL=C`로 숫자·출력 형식을 통일합니다.
2. 인자가 하나이고 양의 정수 PID인지 검사합니다. `$#`는 인자 수, `$1`은 첫 인자입니다.
3. CSV 열 이름을 출력합니다.
4. `ps -p "$pid"`로 대상 PID만 조회합니다.
5. `-o pid=,...`로 필요한 필드를 선택하고 `=`로 ps 제목을 숨깁니다.
6. `awk`는 열을 쉼표로 연결하고 좀비 상태 `Z`를 제외합니다.
7. 결과가 비면 `break`로 끝냅니다.
8. 날짜와 값을 출력하고 `sleep 1` 후 반복합니다.

```text
timestamp,pid,ppid,elapsed_s,cpu_avg_pct,mem_pct,rss_kib,threads,state
```

| 열 | 의미와 주의 |
|---|---|
| timestamp | 실제 수집 시각·시간대 |
| pid / ppid | 프로세스 / 부모 ID |
| elapsed_s | 프로세스 경과 초 |
| cpu_avg_pct | ps의 실행 이후 평균 CPU. 순간 값 아님 |
| mem_pct | RSS를 Linux 전체 물리 메모리로 나눈 비율 |
| rss_kib | 물리 메모리 상주량. KiB |
| threads | NLWP, 스레드 수 |
| state | 상태·부가 플래그 |

조회·파일 쓰기 시간이 들기 때문에 표본은 정확히 매1.000초가 아닙니다. 실제 수집 시각을 사용합니다. 단위 환산은 `MiB=KiB/1024`입니다. 146376KiB는142.945MiB입니다. 앱 내부 MB 표기와 RSS를 동일한 측정값으로 간주하지 않습니다.

`S`는 대기/수면, `N`은 낮은 우선순위, `l`은 멀티스레드, `s`는 세션 리더, `+`는 터미널 전경 프로세스 그룹 표시입니다. 상태 플래그 하나만으로 장애를 판정하지 않습니다.

## 8. OOM 명령과 실제 판단

```bash
source ./env.sh
export MEMORY_LIMIT=256
ps -C agent-leak-app -o pid,ppid,etimes,pcpu,pmem,rss,nlwp,stat
tail -n 80 "$RUN_DIR/app.log"
tail -n 20 "$RUN_DIR/monitor-962.csv"
```

`ps -C`는 이름으로 프로세스를 선택하고 `-o`는 출력 열을 선택합니다. `tail -n N`은 마지막 N줄입니다. CSV 이름의 PID는 실제 케이스에 맞춰야 합니다.

실제 Before Heap는25→50→75→100→125→150MB였고 `150MB >= 128MB`에서 종료했습니다. After는275MB에서256MB를 초과했습니다. 한 번에25MB씩 증가하므로 설정값을 정확히 찍지 않을 수 있습니다.

RSS의 마지막 관측142.945MiB와 앱 종료 값150MB는 측정 대상·기본 런타임 메모리·간격이 달라 일치할 필요가 없습니다. 마지막 할당 직후의 강제 종료는 관제가 놓칠 수 있습니다.

`%MEM=1.8`의 분모는 앱 한도128MB가 아니라 Linux 전체 RAM입니다. 전체 RAM이 거의 찬 상태가 아니어도 앱 정책 한도를 넘으면 종료할 수 있습니다. 과제 예시의96%를 실제 값처럼 복사하지 않았습니다.

종료 후 ps 제목만 남은 것은 조회 시점에 이름이 일치하는 PID가 없다는 뜻입니다. MemoryGuard 로그와 함께 종료를 확인했습니다. 한도 상향으로17.202→32.363초 생존했지만 상승과 종료가 계속돼 임시 조치로 분류합니다.

## 9. 종료 코드 저장과 의미

```bash
wait "$APP_PID"
printf '%s\n' "$?" > "$RUN_DIR/exit-code.txt"
```

`wait`는 현재 셸의 자식 작업 종료를 기다리고 상태를 반환합니다. `$?`는 직전 명령의 종료 상태입니다. 다른 명령을 먼저 실행하면 값이 바뀌므로 바로 저장했습니다.

| 기록 | 해석 |
|---|---|
| 137 | Bash128+9와 일치. MemoryGuard 로그와 결합해 판단 |
| 143 + WATCHDOG/SIGTERM | CPU 보호 종료 |
| 143 + cleanup.log | 실험자 수동 종료 |
| PID 존재 + 정체 | 종료와 다름. Deadlock에서는 락·스레드 근거 추가 필요 |

`Killed`와 `Terminated`는 셸 알림입니다. 코드나 알림만으로 커널 OOM·Watchdog를 확정하지 않았습니다. [Bash 문서](https://www.gnu.org/s/bash/manual/html_node/Exit-Status.html)

## 10. CPU: PTY·짧은 간격 관제가 필요한 이유

초기1초 관제 최대는4%였지만 앱 내부 값은53.01%였습니다. 기록 종료가11:48:00, 앱 종료가11:48:05.646이라 마지막 구간도 빠졌습니다. 이 차이를 숨기지 않고 추가 관측했습니다.

```bash
script -q -e -f -c './agent-leak-app' "$RUN_DIR/app.log" \
  < /dev/null > "$RUN_DIR/console.log" 2>&1 &
SESSION_PID=$!
TOP_PIDS=$(pgrep -x agent-leak-app | paste -sd, -)
LC_ALL=C top -b -d 0.1 -n 450 -w 180 -p "$TOP_PIDS" \
  > "$RUN_DIR/top.log" 2> "$RUN_DIR/top-error.log" &
```

| 옵션 | 목적 |
|---|---|
| script | 가상 터미널에서 실행하고 출력 기록 |
| -q / -e / -f | 콘솔 안내 축소 / 자식 종료 코드 반영 / 자주 flush |
| -c | 실행 명령 지정 |
| < /dev/null | 백그라운드에서 사용자 터미널 입력을 읽지 않게 연결 |
| console.log | script의 출력·오류도 별도 보존 |
| paste -sd, - | PID를 쉼표 목록으로 연결 |
| top -b | 파일 저장용 배치 모드 |
| -d 0.1 | 갱신 간격0.1초 설정 |
| -n 450 | 최대450회 후 top 종료 |
| -w 180 | 출력 폭 지정 |
| -p | 해당 앱 PID만 조회 |

Python 표준 출력은 터미널에서 줄 버퍼링, 일반 파일에서는 보통 블록 버퍼링합니다. 강제 종료 직전 print가 남지 않을 가능성을 PTY로 보완했고 실제 Watchdog 문구를 확보했습니다. 버퍼링만이 유일한 원인이라고 확정하지는 않았습니다. [Python 출력](https://docs.python.org/3/library/sys.html#sys.stdout), [script](https://man7.org/linux/man-pages/man1/script.1.html)

`Script started ... <not executed on terminal>`은 script 입력이 사용자 터미널이 아니었다는 안내입니다. 앱이 실행되지 않았다는 뜻이 아닙니다.

top 최초 프레임은 안정적인 이전 갱신 구간이 없어 제외했습니다. 이후 최대는 PID1921에서50.0%, 비교 PID2359에서40.0%였습니다. 일반적인 top 기본 표시는 논리 CPU 하나의100%를 기준으로 하므로 전체 CPU 요약과 구분합니다. 실제 응답 지연·전체 CPU 포화는 측정하지 않았습니다. [top 문서](https://man7.org/linux/man-pages/man1/top.1.html)

## 11. CPU 최대값 집계 코드

```bash
awk '
/^top -/ {frame++; next}
frame > 1 && $1 ~ /^[0-9]+$/ && $NF == "agent-leak-app" {
    p=$1
    c=$9+0
    if (!(p in peak) || c > peak[p]) peak[p]=c
    n[p]++
}
END {
    for (p in peak)
        printf "PID=%s MAX_CPU=%.1f%% SAMPLES=%d\n", p, peak[p], n[p]
}' "$RUN_DIR/top.log"
```

`/^top -/`는 화면 갱신을 세고 `frame>1`은 첫 프레임을 제외합니다. `$1`은 기본 출력의 PID, `$9`는 %CPU, `$NF`는 마지막 명령 열입니다. 숫자 PID와 앱 이름이 맞는 행만 선택합니다.

`+0`은 숫자 변환, `peak[p]`는 PID별 최대값, `n[p]`는 기록 수입니다. `END`에서 요약합니다. 사용자 정의 top 열 순서가 바뀌면9번째 열이라는 가정도 수정해야 합니다.

실제 Before의 부모1920 최대0%, 작업1921 최대50%, 각341표본입니다. After의 부모2358 최대0%, 작업2359 최대40%, 각449표본입니다. Before 종료 뒤의 PID 없음 구간을 CPU0으로 채우지 않았습니다.

## 12. CPU 조치의 검증 범위

80 설정은 내부5→53.11% 뒤 Watchdog SIGTERM, 40 설정은 `Peak reached (40.00%). Starting cooldown...`과 `Cooldown complete (5.00%)`를 기록했습니다. After는55초 시점에 PID·진행 로그가 유지됐습니다.

환경변수80을 “OS CPU80%를 넘으면 종료”로 가정하지 않았습니다. 종료 시 내부 값은53.11%, 외부 구간 최대는50%였습니다. 앱 내부 지표, ps 평균, top 구간 값을 각각 보고했습니다.

정상 시나리오는 Heap525MB에서 `Starting cleanup / Memory Cache Flushed / MEMORY RECOVERED`도 기록했습니다. 초기 상승만으로 전체 정상 시나리오를 누수라고 판정하지 않았습니다.

## 13. Deadlock 스냅샷 함수와 옵션

```bash
capture_agent_state() {
  date -Iseconds
  ps -ef | grep '[a]gent-leak-app'
  ps -L -p "$WORKER_PID" \
    -o pid,tid,pcpu,rss,time,stat,wchan:32,comm
  stat -c 'log_bytes=%s modified=%y' "$RUN_DIR/app.log"
  tail -n 20 "$RUN_DIR/app.log"
}
sleep 8
capture_agent_state | tee "$RUN_DIR/snapshot-1.txt"
sleep 10
capture_agent_state | tee "$RUN_DIR/snapshot-2.txt"
```

| 구문·필드 | 의미 |
|---|---|
| 함수 | 같은 조회를 반복해 비교 조건 유지 |
| ps -e / -f | 전체 선택 / UID·PID·PPID 등 상세 형식 |
| grep '[a]...' | 앱 이름 검색, grep 패턴 자체는 동일 이름으로 매치되지 않게 작성 |
| -L / -p | 스레드 단위 / 작업 PID 선택 |
| tid | 스레드 ID. 메인 TID는 PID와 동일 |
| time | 누적 CPU 시간 |
| wchan:32 | 커널 대기 위치 이름을 폭32로 표시 |
| stat -c | 파일 크기·mtime을 지정 형식으로 조회 |
| %s / %y | 파일 바이트 크기 / 마지막 수정 시각 |
| sleep | 지정한 초 동안 기다림 |
| tee | 화면과 파일에 동시에 출력 |

ps·stat·tail은 순차 수집해 완전히 같은 순간의 원자적 스냅샷이 아닙니다. 10초 사이 진행 여부를 비교했습니다.

## 14. Deadlock 출력의 의미

Before(512/40/true)는 PID9226 유지, RSS18512KiB 고정, 세 TID 모두 `futex_do_wait`, 로그2792바이트·mtime 동일입니다.

T1은 A를 보유하며 B를 기다리고 T2는 B를 보유하며 A를 기다렸습니다. 이는 순환 대기입니다. futex 대기만이 아니라 락 보유·추가 요청·BLOCKED 로그와 진행 정체를 결합했습니다.

After(512/40/false)에서는 메인 futex 대기가 남아도 두 워커가 `poll_schedule_timeout.constprop.`였고 로그3474→3870바이트, Heap·CPU 로그가 진행됐습니다. 낮은 CPU나 대기 상태 자체만으로 장애를 판정하지 않습니다.

false에서도 스레드3개입니다. 이 설정은 교착 유발 경로를 회피한 것으로 분석하며 프로세스 전체의 단일 스레드 전환이라고 적지 않습니다. 스레드 행의 RSS는 공유 프로세스 값이므로 세 행을 더하지 않습니다. Worker 이름과 각 TID의 일대일 대응도 미확인입니다.

## 15. 수동 정리와 백업

```bash
for PID in $(cat "$RUN_DIR/observed-pids.txt"); do
  if [[ "$(ps -p "$PID" -o comm= 2>/dev/null)" == "agent-leak-app" ]]; then
    printf '%s manual SIGTERM PID=%s\n' "$(date -Iseconds)" "$PID" \
      >> "$RUN_DIR/cleanup.log"
    kill -TERM "$PID" 2>/dev/null
  fi
done
wait "$SESSION_PID"
printf '%s\n' "$?" > "$RUN_DIR/exit-code.txt"
```

저장한 PID만 순회하며 현재 이름이 맞는지 확인합니다. `kill -TERM`은 SIGTERM 전달, `>>`는 덧붙이기, `2>/dev/null`은 이미 종료된 PID의 오류 출력 생략입니다. 수동 요청 시각을 남겨 자동 Watchdog와 구분했습니다.

```bash
BACKUP_DIR="/mnt/c/Users/1234v/Downloads/agent-app-leak/results"
mkdir -p "$BACKUP_DIR/evidence"
cp -r "$AGENT_HOME/evidence/." "$BACKUP_DIR/evidence/"
cp "$AGENT_HOME/env.sh" "$AGENT_HOME/monitor.sh" "$BACKUP_DIR/"
{
  date -Iseconds
  uname -a
  id
  cat /etc/os-release
  nproc
  free -h
} > "$BACKUP_DIR/environment.txt"
```

`cp -r`는 하위 폴더 복사, `evidence/.`는 내용을 복사해 중첩 폴더를 피하는 형태입니다. `{ ... }`는 출력을 묶어 하나의 파일에 저장합니다. uname은 커널, id는 계정·그룹, os-release는 배포판, nproc는 CPU 수, free는 메모리·스왑을 기록합니다.

## 16. 실제 실행과 과제 요구사항 연결

| 폴더 | 메모리/CPU/멀티 | 작업 PID | 목적 |
|---|---|---|---|
| oom-128-20261009-113259 | 128/100/false | 962 | 메모리 상승·보호 종료 |
| oom-256-20261009-113740 | 256/100/false | 1156 | 한도 변경·생존 시간 비교 |
| cpu-80-20261009-114729 | 512/80/false | 1530 | 초기 관측의 한계 확인 |
| cpu-80-pty-20261009-115744 | 512/80/false | 1921 | 급상승·Watchdog 증거 |
| cpu-40-pty-20261009-122044 | 512/40/false | 2359 | CPU 상한·냉각 비교 |
| deadlock-true-20261009-125943 | 512/40/true | 9226 | PID·락 순환·정체 |
| deadlock-false-20261009-130309 | 512/40/false | 11294 | 로그·작업 진행 비교 |

각 보고서는 현상·증거·원인·조치의 필수4개 절을 갖추었습니다. MEMORY_LIMIT은2회, CPU_MAX_OCCUPY는동일 관측법2회, MULTI_THREAD_ENABLE은true/false2회로 비교했습니다.

## 17. 사실·추론·미확인

- 사실: 원본 PID·설정·로그·RSS·CPU 구간값·종료 코드·수동 조치.
- 추론: 낮은 메모리 설정의 회수 부족, 락 순서로 인한 순환 대기, 출력 버퍼링 영향.
- 미확인: 바이너리 코드 위치·정확한 보호 구현·실제 요청 지연·TID별 Worker 대응.
- 한계: 표본 사이 순간 최대를 놓칠 수 있고 장기 벽시계에는 공백이 있어 무중단 가동 시간을 확대해 주장하지 않음.

## 18. 터미널 종료 시 복구

파일로 저장한 로그·CSV·스크립트는 남습니다. 새 Ubuntu 셸에서 `cd ~/jae-test`와 `source ./env.sh`로 경로를 복원할 수 있지만 RUN_DIR·PID 변수·함수는 다시 지정해야 합니다.

새 셸은 이전 작업의 부모가 아니므로 wait로 과거 종료 코드를 임의로 복원하지 않습니다. 이미 저장된 exit-code와 로그를 확인합니다. 실행 중인 프로세스는 ps로 현재 상태를 확인하고 이전 PID 숫자만으로 종료하지 않습니다.

## 19. 참고 문서

- [WSL 설치](https://learn.microsoft.com/en-us/windows/wsl/install)
- [ps](https://man7.org/linux/man-pages/man1/ps.1.html)
- [top](https://man7.org/linux/man-pages/man1/top.1.html)
- [script](https://man7.org/linux/man-pages/man1/script.1.html)
- [Bash 종료 상태](https://www.gnu.org/s/bash/manual/html_node/Exit-Status.html)
- [Python 출력](https://docs.python.org/3/library/sys.html#sys.stdout)
- [futex](https://man7.org/linux/man-pages/man2/futex.2.html)
