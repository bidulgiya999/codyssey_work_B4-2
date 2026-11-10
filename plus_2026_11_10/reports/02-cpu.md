# [Bug] CPU Latency - Watchdog 보호 종료 후 설정40에서 냉각·진행 확인, OS 구간 최대70% 관측

실험 환경: Ubuntu 26.04.1 LTS / WSL2 / x86_64 / 일반 사용자 jae0608(UID 1000). 커널은 6.18.58.1-microsoft-standard-WSL2입니다. 실험일은 **2026-11-10 KST(UTC+09:00)**입니다.

환경 출처는 [백업 시점 환경 기록](../environment-at-backup.txt)입니다. 이 파일은 20:16:42에 수집됐으므로 메모리 여유량 등을 장애 발생 순간의 값으로 인용하지 않습니다. 아래 수치는 10월 9일 기존 보고서와 구분한 이번 재실습의 값입니다. 바이너리 디컴파일·리버스 엔지니어링은 수행하지 않았습니다.

**처음 읽는 순서:** 비교 표 → 실행 코드와 **코드 해석** → 보호 종료·냉각·top의 **출력 해석** → 원인 → 검증입니다. 코드 상자는 입력 요약이고 출력 상자는 당시 기록입니다. [용어집](../glossary.md)의 [CPU_MAX_OCCUPY](../glossary.md#cpu-max-occupy), [Current Load](../glossary.md#current-load), [Watchdog](../glossary.md#watchdog), [SIGTERM](../glossary.md#sigterm), [top](../glossary.md#top)을 누르면 뜻을 확인할 수 있습니다.

## 1. Description (현상 설명)

MEMORY_LIMIT=512, MULTI_THREAD_ENABLE=false를 고정하고 **CPU_MAX_OCCUPY만80→40으로 변경**했습니다. 80조건에서는 내부 부하 상승 후 Watchdog가 SIGTERM을 요청했습니다. 40조건에서는 냉각·작업 진행과 경과86초 시점의 생존을 확인하고 실험자가 종료했습니다.

단, **OS의 top 구간 관측 최대는50.0→70.0%였습니다.** CPU설정40을 프로세스 전체40% 강제 제한으로 해석하거나 OS 최대가 감소했다고 보고하지 않습니다.

| 항목 | Before: CPU80 | After: CPU40 |
|---|---|---|
| 나머지 설정 | 512 / false | 512 / false |
| 작업 PID | 12479 | 13127 |
| 앱 시작 로그 | 19:42:29.310 | 19:45:58.827 |
| top 기록 시각 범위 | 19:42:29~19:44:14 | 19:45:59~19:48:26 |
| 전체 top 화면 수 | 1044 | 1464 |
| 최초 화면 제외 작업 PID 표본 수 | 359 | 1462 |
| OS 구간 CPU 관측 최대 | 50.0% | 70.0% |
| 앱 내부 지표 | 50.50%에서 위반 | 40.00%에서 냉각 |
| 결과 | 36.385초 후 보호 종료 요청 | 경과86초 시점 PID·진행 확인 |
| 최종 종료 | Watchdog SIGTERM | 19:48:26 수동 SIGTERM |
| 종료 코드 | 143 | 143 |

## 2. Evidence & Logs (증거 자료)

### 재현 및 수집 경로

실행별 설정을 저장하고 script의PTY에서 앱을 시작했습니다. 앱 PID를 별도로 찾아 각각 monitor.sh로 관제하고, top을0.1초 간격으로 기록했습니다. 앱 종료 확인 또는 실험자 정리 후 top도 종료했습니다.

아래 구문은 수집 절차 요약이며 RUN_DIR·TOP_PIDS가 준비된 상황을 전제로 합니다.

```bash
export MEMORY_LIMIT=512
export CPU_MAX_OCCUPY=80       # After에서는40
export MULTI_THREAD_ENABLE=false
script -q -e -f -c './agent-leak-app' "$RUN_DIR/app.log" \
  < /dev/null > "$RUN_DIR/console.log" 2>&1 &
SESSION_PID=$!
# 별도로 찾은 앱 부모·자식 PID를 TOP_PIDS에 쉼표로 연결했습니다.
LC_ALL=C top -b -d 0.1 -w 180 -p "$TOP_PIDS" \
  > "$RUN_DIR/top.log" 2> "$RUN_DIR/top-error.log" &
```

script는 가상 터미널 출력을 보존하며 -e는 실행 명령의 종료 상태 반영, -f는 기록을 즉시 반영, -c는 실행 명령 지정입니다. -b는 top 배치 출력, -d는 간격, -w는 폭, -p는 대상 PID입니다. script 세션과 작업 PID는 구분했습니다.

### 코드 해석 — 왜 이렇게 입력했나요?

| 코드·옵션 | 뜻 | 이번 실험에서의 목적 |
|---|---|---|
| `export MEMORY_LIMIT=512` | 앱에 메모리 설정 512MB를 전달합니다. | 허용 범위 50~512 안에서 한도를 높이고 두 CPU 실행에 같은 값을 유지했습니다. 메모리 코드 수정이나 호스트 RAM 증설이 아닙니다. |
| `export CPU_MAX_OCCUPY=80` | 앱의 CPU 관련 설정을 80으로 지정합니다. | 첫 실행의 비교 조건입니다. 두 번째만 40으로 바꿨습니다. 앱 설정과 OS가 강제하는 CPU 상한은 구분해야 합니다. |
| `export MULTI_THREAD_ENABLE=false` | 앱의 해당 동시 처리 설정을 끕니다. | 교착 재현 경로를 켜지 않은 같은 조건으로 비교합니다. 프로그램 전체 스레드 수가 반드시 하나라는 뜻은 아닙니다. |
| `script` | 명령을 가상 터미널(PTY) 안에서 실행하고 터미널 출력을 기록합니다. | 보호 종료 안내를 포함한 터미널 출력을 보존하기 위한 수집 방식입니다. 일반 리다이렉션과 실행 환경이 같다고 단정하지 않습니다. |
| `-q` | script의 시작·종료 알림을 표준 출력에서 줄이는 quiet 옵션입니다. | 콘솔의 불필요한 안내를 줄입니다. 기록 파일의 `Script started/done` 메타데이터와 구분합니다. |
| `-e` | 실행한 명령의 종료 상태를 script의 종료 상태에 반영합니다. | script가 끝났다는 사실 외에 명령의 실패·신호 종료도 확인합니다. |
| `-f` | 기록을 매번 flush하도록 요청합니다. | 실행 도중에도 새 로그를 읽어볼 수 있게 합니다. 저장 장치까지의 완전한 영구 저장을 보증한다는 뜻은 아닙니다. |
| `-c './agent-leak-app'` | PTY 안에서 실행할 명령을 지정합니다. | 현재 디렉터리의 앱을 실행합니다. |
| `"$RUN_DIR/app.log"` | script가 저장할 터미널 기록 파일입니다. | 부팅·앱 메시지와 script 메타데이터를 실행별로 보존합니다. |
| `< /dev/null` | 표준 입력을 빈 입력 소스로 바꿉니다. | 백그라운드 기록 작업이 이 터미널의 입력을 기다리지 않게 합니다. |
| `> console.log 2>&1 &` | script 자체의 표준 출력·오류를 파일로 보낸 뒤 백그라운드로 시작합니다. | 앱 실행 중 관제를 병행하고 콘솔 기록도 보존합니다. `>`는 덮어쓰기이므로 실행별 새 폴더를 썼습니다. |
| `SESSION_PID=$!` | 방금 백그라운드로 시작한 script 작업의 PID를 저장합니다. | 앱의 작업 PID와 구분해 종료 상태를 기다립니다. 이 PID를 앱 CPU 측정 대상으로 혼동하지 않습니다. |
| `LC_ALL=C` | 이 명령의 로케일을 C로 맞춥니다. | 소수점·문구 형식을 일정하게 해 자동 추출 조건을 맞춥니다. |
| `top -b` | 대화형 화면 대신 연속 텍스트로 출력합니다. | 파일에 여러 화면을 기록합니다. |
| `-d 0.1` | top 갱신 간격을 0.1초로 요청합니다. | 짧은 CPU 상승을 1초 관제보다 자주 관측합니다. 실제 간격은 스케줄링 등에 영향을 받을 수 있습니다. |
| `-w 180` | 출력 폭을 180열로 지정합니다. | 명령 이름 등 열이 잘리는 것을 줄입니다. |
| `-p "$TOP_PIDS"` | 쉼표로 연결된 PID 목록을 선택합니다. | 실행기와 작업 프로세스를 구분해 관측합니다. 시스템 전체 CPU·메모리 요약은 별도 항목입니다. |
| `2> top-error.log` | top의 표준 오류를 별도 파일로 저장합니다. | 숫자가 없는 이유가 수집 오류인지 함께 확인합니다. 빈 파일은 수집 오류 메시지가 기록되지 않았다는 뜻입니다. |

줄 끝 `\`는 다음 줄까지 같은 명령으로 이어 쓴다는 뜻입니다. `#` 뒤는 설명용 주석입니다. [환경변수](../glossary.md#environment-variable), [PID](../glossary.md#pid), [monitor.sh 전체 해설](../monitor-code-guide.md)도 함께 볼 수 있습니다.

### 코드 해석 — top에서 PID별 최대를 어떻게 추출했나요?

아래는 저장된 `top.log`를 읽는 분석 구문입니다. 앱을 새로 실행하거나 CPU 설정을 바꾸지 않습니다. 실행하려면 기존 증거 폴더를 가리키는 `CASE_DIR`가 준비돼 있어야 합니다.

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
}' "$CASE_DIR/top.log"
```

1. `/^top -/`는 `top -`로 시작하는 화면 제목을 찾습니다. 화면마다 `frame`을 1 늘리고 그 제목 줄은 건너뜁니다.
2. `frame > 1`은 첫 화면을 제외합니다. 첫 화면은 후속 갱신 구간과 CPU 산정 기준이 달라 비교에서 뺐습니다.
3. `$1`이 숫자인 행, 마지막 필드 `$NF`가 앱 이름인 행만 선택해 제목·시스템 요약을 제외합니다.
4. 이번 고정 출력 형식에서 `$1`은 PID, `$9`는 %CPU입니다. `+0`은 숫자로 취급하게 합니다. top 설정이나 열 순서가 바뀌면 그대로 재사용하지 않고 헤더부터 확인해야 합니다.
5. `peak[p]`에는 해당 PID에서 본 최대, `n[p]`에는 선택된 데이터 행 수를 저장합니다. 마지막 `END`에서 결과를 출력합니다. PID 출력 순서는 중요하지 않습니다.

예를 들어 `PID=13127 MAX_CPU=70.0% SAMPLES=1462`는 **그 PID의 선택된 1,462개 표본 중 최대가 70.0%**였다는 뜻입니다. 70%가 계속 유지됐다는 뜻도, 앱 내부 설정이 70이었다는 뜻도 아닙니다. 첫 화면을 제외하고 해당 PID가 실제 표시된 행만 세므로 전체 화면 수와 다릅니다. 특히 Before는 앱 종료 뒤에도 top이 기록돼 차이가 큽니다.

원본: [Before 설정](../evidence/cpu-80-pty-20261110-194141/settings.txt), [After 설정](../evidence/cpu-40-pty-20261110-194524/settings.txt), [Before top](../evidence/cpu-80-pty-20261110-194141/top.log), [After top](../evidence/cpu-40-pty-20261110-194524/top.log), [Before 수집 범위](../evidence/cpu-80-pty-20261110-194141/top-coverage.txt), [After 수집 범위](../evidence/cpu-40-pty-20261110-194524/top-coverage.txt).

### Before: CPU 상승과 Watchdog 종료

원본에서 시작·종료 직전 핵심 문장만 발췌했습니다. 생략한 중간 로그는 원본을 확인합니다.

```text
2026-11-10 19:42:29,310 [INFO] Agent listening at port 15034
2026-11-10 19:42:31,321 [INFO] [CpuWorker] Current Load: 5.00%
2026-11-10 19:43:05,594 [INFO] [CpuWorker] Current Load: 50.50%
2026-11-10 19:43:05,695 [CRITICAL] [CpuWorker] CPU Threshold Violated! (50.5%).
>>> [SYSTEM] WATCHDOG: INITIATING EMERGENCY ABORT (SIGTERM) <<<
Script done on 2026-11-10 19:43:05+09:00 [COMMAND_EXIT_CODE="143"]
```

[Before 앱 로그](../evidence/cpu-80-pty-20261110-194141/app.log)와 [Before CPU 집계](../evidence/cpu-80-pty-20261110-194141/top-summary.txt)에서 작업 PID12479의top 최대50.0%와 내부50.50%를 별개로 확인했습니다. [종료 후 ps](../evidence/cpu-80-pty-20261110-194141/ps-check.txt)에는 제목만 있습니다.

#### 출력 해석 — 보호 종료 문장은 무엇을 의미하나요?

| 실제 문구 | 뜻 | 판단의 주의점 |
|---|---|---|
| `Agent listening at port 15034` | 앱이 해당 포트에서 수신을 시작했다고 기록했습니다. | 이 로그 시각을 생존 시간 계산의 시작으로 사용했습니다. 모든 기능의 정상 응답을 검증한 것은 아닙니다. |
| `Current Load: 5.00%` → `50.50%` | 앱의 CPU 담당 부분이 내부 부하 값을 증가시키며 기록했습니다. | [Current Load](../glossary.md#current-load)는 top과 별도 지표입니다. |
| `CPU Threshold Violated! (50.5%)` | 앱이 자신의 보호 기준을 위반했다고 판단했습니다. | 설정은 80이므로 “OS CPU가 80%를 넘어서 종료됐다”라고 읽으면 실제 로그와 맞지 않습니다. 정확한 내부 판단식은 확인하지 못했습니다. |
| `WATCHDOG ... EMERGENCY ABORT (SIGTERM)` | 보호 감시 기능이 긴급 종료 요청을 시작했습니다. | [Watchdog](../glossary.md#watchdog)의 보호 조치라는 직접 근거입니다. |
| `COMMAND_EXIT_CODE="143"` | 실행 명령의 종료 상태를 script가 기록했습니다. | 143은 SIGTERM(15) 종료 해석과 부합합니다. 요청자가 누구인지는 앞의 로그와 함께 판단합니다. |

CPU를 많이 쓰는 작업은 같은 CPU를 공유하는 다른 작업과 실행 시간을 경쟁하므로 응답 지연을 유발할 수 있습니다. 하지만 이 실험에서 실제 요청 지연을 측정한 것은 아니므로 보호 종료와 부하 관측을 보고합니다.

### After: 냉각과 생존

최초 냉각 사이클의 실제 핵심 문장입니다.

```text
2026-11-10 19:46:38,023 [INFO] [CpuWorker] Peak reached (40.00%). Starting cooldown...
2026-11-10 19:46:56,719 [INFO] [CpuWorker] Cooldown complete (5.00%). Resuming load increase...
```

```text
    PID    PPID ELAPSED %CPU %MEM   RSS NLWP STAT
  13103   13100      86  0.0  0.0  2248    1 Ss+
  13127   13103      86  1.4  2.5 197864   3 SNl+
```

위ELAPSED86은 확인 시점의 프로세스 경과 초입니다. 명령의sleep55는 추가 대기일 뿐 실제 생존 시간이55초였다는 뜻은 아닙니다. %CPU1.4는ps의 누적 평균이며 top 구간 최대와 다릅니다. [After 앱 로그](../evidence/cpu-40-pty-20261110-194524/app.log), [86초 확인](../evidence/cpu-40-pty-20261110-194524/ps-check.txt), [확인 시각](../evidence/cpu-40-pty-20261110-194524/observed_at.txt).

#### 출력 해석 — 냉각과 ps는 무엇을 의미하나요?

- `Peak reached (40.00%)`는 앱 내부 값이 설정 40에 도달했다는 기록입니다. `Starting cooldown`은 부하를 낮추는 냉각 단계를 시작한다는 뜻입니다.
- `Cooldown complete (5.00%)`와 `Resuming load increase`는 낮아진 값에서 부하 증가를 다시 시작한다는 뜻입니다. 종료된 것이 아니라 작업 단계가 전환됐다는 근거입니다.
- `PID 13127 / PPID 13103`은 작업 프로세스와 그 실행기의 관계입니다. 두 행이 같은 일을 하는 프로세스라는 뜻은 아닙니다.
- `RSS 197864`는 약 193.23MiB의 상주 메모리, `NLWP 3`은 관측된 스레드 세 개입니다. `SNl+`에서 S는 대기, N은 낮은 우선순위, l은 여러 스레드, +는 전경 프로세스 그룹을 뜻합니다.
- PID 존재 하나만으로 정상이라고 하지 않았습니다. 냉각 완료·새 부하 로그가 이어진 점을 함께 확인해 관측 구간의 진행으로 판단했습니다.

### 예상과 달랐던70% 구간

집계값을 원본 화면과 대조했습니다.

```text
----- 높은 CPU가 관측된 화면 -----
top - 19:47:16 up  2:11,  1 user,  load average: 0.04, 0.07, 0.06
Tasks:   2 total,   0 running,   2 sleeping,   0 stopped,   0 zombie
%Cpu(s):  0.0 us,  1.4 sy,  3.5 ni, 95.1 id,  0.0 wa,  0.0 hi,  0.0 si,  0.0 st 
MiB Mem :   7638.3 total,   5774.6 free,    882.3 used,   1157.5 buff/cache     
MiB Swap:   2048.0 total,   2048.0 free,      0.0 used.   6756.0 avail Mem 

    PID USER      PR  NI    VIRT    RES    SHR S  %CPU  %MEM     TIME+ COMMAND
  13127 jae0608   30  10  237404 121056  10220 S  70.0   1.5   0:01.12 agent-leak-app
  13103 jae0608   20   0    3000   2248   2024 S   0.0   0.0   0:00.06 agent-leak-app
```

같은 초 주변 앱 로그 발췌입니다. 앞의110~114는grep -n으로 붙인 원본 줄 번호입니다.

```text
110:2026-11-10 19:47:16,451 [INFO] [CpuWorker] Current Load: 39.53%
111:2026-11-10 19:47:16,451 [INFO] [MemoryWorker] Current Heap: 100MB
112:2026-11-10 19:47:18,562 [INFO] [CpuWorker] Peak reached (40.00%). Starting cooldown...
113:2026-11-10 19:47:19,496 [INFO] [MemoryWorker] Current Heap: 125MB
114:2026-11-10 19:47:19,568 [INFO] [CpuWorker] Current Load: 40.00%
```

원본: [After CPU 집계](../evidence/cpu-40-pty-20261110-194524/top-summary.txt), [70% 실제 화면](../evidence/cpu-40-pty-20261110-194524/top-high-frames.txt), [주변 앱 로그](../evidence/cpu-40-pty-20261110-194524/top-high-app-context.txt).

#### 출력 해석 — top 화면의 각 항목은 무엇인가요?

| 화면 항목 | 이번 화면에서 읽는 의미 |
|---|---|
| `top - 19:47:16` | 이 화면의 시각입니다. 원본 앱 로그와 시간대를 맞춰 찾았습니다. |
| `up 2:11` | 시스템 가동 시간입니다. 앱이 2시간 11분 실행됐다는 뜻은 아닙니다. |
| `load average: 0.04, 0.07, 0.06` | 시스템의 최근 1·5·15분 부하 평균입니다. 단순 CPU 백분율이 아닙니다. |
| `Tasks: 2 total` | PID로 선택된 표시 대상 두 개입니다. 이 화면에서 시스템 전체 프로세스가 두 개라고 해석하지 않습니다. |
| `%Cpu(s) ... 95.1 id` | 시스템 전체 CPU 요약에서 idle, 즉 쉬는 시간이 95.1%였다는 뜻입니다. 프로세스 행의 70%와 분모·집계 범위가 다릅니다. |
| `MiB Mem ... buff/cache ... avail Mem` | 시스템 메모리 요약입니다. free는 완전히 비어 있는 양, available은 회수 가능한 캐시 등을 고려한 사용 가능 추정치입니다. |
| `MiB Swap ... 0.0 used` | 이 화면의 스왑 사용량입니다. 다른 시점의 메모리 압박까지 없었다는 뜻은 아닙니다. |
| `PID / USER` | 프로세스 번호와 실행 사용자입니다. |
| `PR 30 / NI 10` | 스케줄링 우선순위 표시와 nice 값입니다. 앱의 낮은 우선순위 설정과 부합합니다. |
| `VIRT / RES / SHR` | 가상 주소 공간 규모, 상주 메모리, 공유 가능 상주 메모리 항목입니다. VIRT 전체가 실제 RAM에 사용 중이라는 뜻은 아닙니다. |
| `S` | 조회 시점의 프로세스 상태가 대기라는 뜻입니다. 직전 측정 구간에는 CPU를 사용했을 수 있어 %CPU 70과 모순되지 않습니다. |
| `%CPU 70.0 / %MEM 1.5` | 작업 PID 전체의 구간 CPU 사용률과 물리 메모리 대비 비율입니다. 앱 설정 40과 같은 값이 아닙니다. |
| `TIME+ 0:01.12` | 누적 CPU 시간입니다. 실제 경과 시간과 다릅니다. |

주변 로그의 `110:`은 `grep -n`이 붙인 **원본 줄 번호**이지 CPU 값이나 오류 번호가 아닙니다. `grep -E`는 여러 패턴을 `|`로 연결하는 확장 정규식을 사용합니다. 예를 들어 `WATCHDOG|CPU Threshold Violated`는 둘 중 하나가 들어간 행을 찾습니다. 검색 결과가 없으면 그 문구가 없는 것이지 모든 장애가 없다는 뜻은 아닙니다.

## 3. Root Cause Analysis (원인 분석)

**직접 종료 원인:** Before에서 CPU Threshold Violated와 WATCHDOG/SIGTERM이 기록되고 세션이 143으로 종료됐습니다. 따라서 앱의 과점유 보호 정책에 따른 종료로 판단했습니다. 내부 보호 기준의 정확한 구현은 확인하지 않았습니다. 설정은 80인데 내부 50.50%에서 종료됐으므로 80을 정확한 OS 임계치로 설명하지 않습니다.

**CPU 지표 구분:** ps는 프로세스 수명에 대한 평균, top은 갱신 구간의 프로세스 전체 사용률, Current Load는 앱 내부 지표입니다. After의 19:47:16에 top 70%와 내부 39.53%, MemoryWorker 100MB가 함께 관측됐습니다. 여러 스레드·메모리 작업 등이 프로세스 CPU에 기여할 수 있지만, 같은 초의 로그만으로 70%를 특정 할당/정리 작업 탓으로 확정하지 않습니다. 일반적인 top 기본 Irix 표시의 100%는 논리 CPU 하나 기준이므로 시스템 전체 %Cpu(s)와도 구분합니다.

**관측 범위의 한계:** 두 실행의 유효 표본 수와 기간이 다릅니다. 관측 최대 하나만으로 전체 부하의 개선·악화를 결론내리지 않습니다. Before는 19:43:05.695에 종료를 요청했지만 top은 19:44:14까지 남아 있어 전체 화면 1044와 PID 표본 359가 다릅니다. 같은 방식으로 최초 프레임을 제외하고 기본 top 열의 PID/$1, CPU/$9, 명령 이름/$NF를 읽었습니다.

**OS 원리:** CPU를 사용하는 실행 가능 작업은 같은 CPU의 다른 작업과 실행 시간을 경쟁해 응답 지연을 유발할 수 있습니다. 다만 이번에는 요청 응답 시간·P99·시스템 전체 CPU 포화를 측정하지 않았습니다.

## 4. Workaround & Verification (조치 및 검증)

앱 권고인 50미만의 비교값 40으로 낮췄습니다. After에서 냉각·로그 진행과 경과 86초 시점 생존이 확인됐고, 전체 After 로그에서 WATCHDOG/CPU Threshold Violated/Memory limit exceeded/Self-terminating 문구는 검색되지 않았습니다. 이는 지정 문구의 부재이지 모든 오류 부재나 영구 안정성을 보장하지 않습니다.

수집 종료 후 실험자가 부모·자식에 SIGTERM을 요청했습니다.

```text
2026-11-10T19:48:26+09:00 manual SIGTERM PID=13103
2026-11-10T19:48:26+09:00 manual SIGTERM PID=13127
```

[수동 정리 로그](../evidence/cpu-40-pty-20261110-194524/cleanup.log), [After 종료 코드](../evidence/cpu-40-pty-20261110-194524/exit-code.txt), [정리 후 ps](../evidence/cpu-40-pty-20261110-194524/ps-after-cleanup.txt)를 함께 제시합니다. 두 실행의143은 같아도 종료 주체가 다릅니다.

### 코드·출력 해석 — 수동 종료와 보호 종료를 어떻게 구분하나요?

수동 정리에서는 관측 대상인지 확인한 PID에 `kill -TERM "$PID"`로 SIGTERM을 요청하고 그 시각·대상을 `cleanup.log`에 남겼습니다. `kill`은 이름과 달리 신호를 보내는 명령이며, `TERM`은 종료 요청입니다. 종료 후 `wait "$SESSION_PID"`의 상태를 바로 저장했습니다. `wait`는 script 세션의 종료 상태를 받으며 `-e` 옵션 때문에 명령의 신호 종료 상태와 연결됩니다.

Before의 143은 앱의 Watchdog 로그와 연결되고, After의 143은 `manual SIGTERM` 두 행과 연결됩니다. 같은 [종료 코드](../glossary.md#exit-code)라도 원인은 다를 수 있으므로 종료 코드를 단독 결론으로 삼지 않았습니다.

### 증거 링크를 누르면 무엇을 보나요?

| 클릭할 증거 | 먼저 볼 부분 | 이 증거로 확인하는 내용 |
|---|---|---|
| settings.txt: [Before](../evidence/cpu-80-pty-20261110-194141/settings.txt) / [After](../evidence/cpu-40-pty-20261110-194524/settings.txt) | 512/80/false와 512/40/false | CPU 설정 하나만 바꾼 비교 조건입니다. |
| [Before app.log](../evidence/cpu-80-pty-20261110-194141/app.log) | 내부 부하 증가 → 임계치 위반 → Watchdog/SIGTERM | 앱 보호 종료 판단의 핵심입니다. |
| top-summary.txt: [Before](../evidence/cpu-80-pty-20261110-194141/top-summary.txt) / [After](../evidence/cpu-40-pty-20261110-194524/top-summary.txt) | 작업 PID와 MAX_CPU·SAMPLES | OS 구간 최대와 선택 표본 수입니다. 결과가 예상과 달라도 실제 값을 사용합니다. |
| top-coverage.txt: [Before](../evidence/cpu-80-pty-20261110-194141/top-coverage.txt) / [After](../evidence/cpu-40-pty-20261110-194524/top-coverage.txt) | 첫·마지막 화면 시각과 전체 화면 수 | 어느 기간까지 관측했는지 확인합니다. PID가 없어진 뒤의 화면도 포함됩니다. |
| [After ps-check.txt](../evidence/cpu-40-pty-20261110-194524/ps-check.txt) | 작업 PID 13127, ELAPSED 86 | 확인 시점에 프로세스가 존재했다는 증거입니다. 진행 여부는 앱 로그로 보완합니다. |
| [After app.log](../evidence/cpu-40-pty-20261110-194524/app.log) | Peak reached·Cooldown complete·뒤따르는 작업 | 설정 변경 후 냉각과 작업 진행입니다. |
| [After top-high-frames.txt](../evidence/cpu-40-pty-20261110-194524/top-high-frames.txt) | 19:47:16, PID 13127, %CPU 70.0 | 집계 최대가 실제 원본 화면에도 존재하는지 확인합니다. |
| [After top-high-app-context.txt](../evidence/cpu-40-pty-20261110-194524/top-high-app-context.txt) | 39.53%와 40% 냉각 로그 | 앱 내부 값과 OS 측정을 구분합니다. 같은 초의 메모리 로그가 70%의 원인이라고 확정하지 않습니다. |
| After [cleanup.log](../evidence/cpu-40-pty-20261110-194524/cleanup.log) · [exit-code.txt](../evidence/cpu-40-pty-20261110-194524/exit-code.txt) · [ps-after-cleanup.txt](../evidence/cpu-40-pty-20261110-194524/ps-after-cleanup.txt) | 수동 요청 시각, 143, 대상 PID 행 부재 | 실험 종료와 장애에 따른 자동 종료를 구분합니다. |

표 안의 파일 링크를 직접 누르면 원본이 열립니다. 전체 top 파일은 길어서 보고서의 발췌와 집계를 먼저 보여주고, 질문받으면 원본에서 같은 시각·PID를 찾습니다. 파일 전체가 길다는 이유로 출력 해석을 생략하지 않습니다.

**검증 결론:** 이번 조치는 관측 구간의 보호 종료 회피와 내부 냉각·진행으로 설명합니다. **top 최대는 70.0%이므로 OS CPU 최대 감소나 40% 강제 제한을 주장하지 않습니다.** 앱 설정은 OS의 CPU quota 명령이 아닙니다. 근본 대응으로 작업량·동시성·배치 크기 조절, 작업별 프로파일링, 실제 서비스 지연 측정을 제안합니다.

### 평가 설명 문장

“80 설정은 Watchdog로 종료됐고 40 설정은 냉각과 86초 시점 진행을 확인했습니다. 다만 top 최대 70%를 관측했으므로 앱 설정과 OS 측정을 구분해 보고했습니다.”
