# [Bug] CPU Latency - Watchdog 보호 종료 후 설정40에서 냉각·진행 확인, OS 구간 최대70% 관측

실험 환경: Ubuntu 26.04.1 LTS / WSL2 / x86_64 / 일반 사용자 jae0608(UID 1000). 커널은 6.18.58.1-microsoft-standard-WSL2입니다. 실험일은 **2026-11-10 KST(UTC+09:00)**입니다.

환경 출처는 [백업 시점 환경 기록](../environment-at-backup.txt)입니다. 이 파일은 20:16:42에 수집됐으므로 메모리 여유량 등을 장애 발생 순간의 값으로 인용하지 않습니다. 아래 수치는 10월 9일 기존 보고서와 구분한 이번 재실습의 값입니다. 바이너리 디컴파일·리버스 엔지니어링은 수행하지 않았습니다.

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

**검증 결론:** 이번 조치는 관측 구간의 보호 종료 회피와 내부 냉각·진행으로 설명합니다. **top 최대는 70.0%이므로 OS CPU 최대 감소나 40% 강제 제한을 주장하지 않습니다.** 앱 설정은 OS의 CPU quota 명령이 아닙니다. 근본 대응으로 작업량·동시성·배치 크기 조절, 작업별 프로파일링, 실제 서비스 지연 측정을 제안합니다.

### 평가 설명 문장

“80 설정은 Watchdog로 종료됐고 40 설정은 냉각과 86초 시점 진행을 확인했습니다. 다만 top 최대 70%를 관측했으므로 앱 설정과 OS 측정을 구분해 보고했습니다.”
