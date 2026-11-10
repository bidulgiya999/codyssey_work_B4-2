# [Bug] Deadlock - 반대 락 순서로 순환 대기, 동시 설정 false에서 작업 진행 확인

실험 환경: Ubuntu 26.04.1 LTS / WSL2 / x86_64 / 일반 사용자 jae0608(UID 1000). 커널은 6.18.58.1-microsoft-standard-WSL2입니다. 실험일은 **2026-11-10 KST(UTC+09:00)**입니다.

환경 출처는 [백업 시점 환경 기록](../environment-at-backup.txt)입니다. 이 파일은 20:16:42에 수집됐으므로 메모리 여유량 등을 장애 발생 순간의 값으로 인용하지 않습니다. 아래 수치는 10월 9일 기존 보고서와 구분한 이번 재실습의 값입니다. 바이너리 디컴파일·리버스 엔지니어링은 수행하지 않았습니다.

## 1. Description (현상 설명)

MEMORY_LIMIT=512와 CPU_MAX_OCCUPY=40을 유지하고 **MULTI_THREAD_ENABLE만 true→false**로 비교했습니다. true에서 작업 PID는 유지됐지만 로그와 메모리가 정체됐고 서로 반대의 자원 대기가 기록됐습니다. false에서는 두 스냅샷 사이에 작업 로그가 진행했습니다.

| 항목 | Before: true | After: false |
|---|---|---|
| 작업 PID | 15052 | 16896 |
| 관측 시각 | 19:53:43 / 19:53:53 | 19:58:58 / 19:59:08 |
| PID 존재 | 두 시점 존재 | 두 시점 존재 |
| RSS | 18,428→18,428KiB | 505,008→120,976KiB |
| 로그 크기 | 2,802→2,802바이트 | 8,778→9,439바이트 |
| 로그 수정 시각 | 19:53:12.458…로 유지 | 19:58:58.714…→19:59:06.014… |
| 스레드 대기 | 세 스레드 모두 futex | 메인 futex, 두 워커 poll 계열; 작업 진행 |
| 최종 종료 | 수동 SIGTERM, 143 | 수동 SIGTERM, 143 |

## 2. Evidence & Logs (증거 자료)

### 재현 및 같은 형식의 반복 관측

필수 부팅 조건을 확인하고 설정·증거 폴더를 분리해 PTY 실행과 PID별 monitor.sh를 시작했습니다. 부모 실행기와 작업 자식을 구분하고 같은 함수로 다음 명령을 10초 간격 두 번 수집했습니다. 아래는 이미 확인된 WORKER_PID·RUN_DIR를 전제로 한 조회 구문입니다.

```bash
ps -ef | grep '[a]gent-leak-app'
ps -L -p "$WORKER_PID" -o pid,tid,pcpu,rss,time,stat,wchan:32,comm
stat -c 'log_bytes=%s modified=%y' "$RUN_DIR/app.log"
tail -n 20 "$RUN_DIR/app.log"
```

ps -ef는 PID·부모 관계, ps -L은 대상 프로세스의 스레드 상태, stat은 로그 바이트 수·수정 시각, tail은 마지막 기록을 보여줍니다. 스냅샷 내부 명령은 순차 실행이므로 완전히 동일한 순간의 원자적 측정은 아닙니다.

원본: [true 설정](../evidence/deadlock-true-20261110-195228/settings.txt), [false 설정](../evidence/deadlock-false-20261110-195628/settings.txt), [Before 스냅샷1](../evidence/deadlock-true-20261110-195228/snapshot-1.txt), [Before 스냅샷2](../evidence/deadlock-true-20261110-195228/snapshot-2.txt), [After 스냅샷1](../evidence/deadlock-false-20261110-195628/snapshot-1.txt), [After 스냅샷2](../evidence/deadlock-false-20261110-195628/snapshot-2.txt).

### Before: PID 유지와 정체

두 번째 스냅샷의 PID·스레드·로그 상태를 원본 그대로 발췌했습니다.

```text
2026-11-10T19:53:53+09:00
jae0608    15018    8678  0 19:53 pts/3    00:00:00 script -q -e -f -c ./agent-leak-app /home/jae0608/agent-b42-practice/evidence/deadlock-true-20261110-195228/app.log
jae0608    15021   15018  0 19:53 pts/4    00:00:00 ./agent-leak-app
jae0608    15052   15021  0 19:53 pts/4    00:00:00 ./agent-leak-app
    PID     TID %CPU   RSS     TIME STAT WCHAN                            COMMAND
  15052   15052  0.0 18428 00:00:00 SNl+ futex_do_wait                    agent-leak-app
  15052   15174  0.0 18428 00:00:00 SNl+ futex_do_wait                    agent-leak-app
  15052   15175  0.0 18428 00:00:00 SNl+ futex_do_wait                    agent-leak-app
log_bytes=2802 modified=2026-11-10 19:53:12.458559161 +0900
```

첫 스냅샷과 RSS·로그 크기·수정 시각이 같습니다. CPU 누적 평균 0.1→0.0은 작업 진행의 증거가 아닙니다. [Before 연속 관제](../evidence/deadlock-true-20261110-195228/monitor-15052.csv)도 보존했습니다.

### 마지막 로그의 자원 보유와 추가 요청

아래는 원본 중 보유·대기를 설명하는 행을 발췌한 것이며 날짜·모듈은 수정하지 않았습니다. 중간 처리 행은 생략했습니다.

```text
2026-11-10 19:53:10,426 [INFO] [AgentWorker][Worker-Thread-1] LOCK ACQUIRED: [Shared_Memory_A]. (Holding...)
2026-11-10 19:53:10,426 [INFO] [AgentWorker] Waiting for worker threads to complete transactions...
2026-11-10 19:53:10,445 [INFO] [AgentWorker][Worker-Thread-2] LOCK ACQUIRED: [Socket_Pool_B]. (Holding...)
2026-11-10 19:53:12,458 [INFO] [AgentWorker][Worker-Thread-1] WAITING for [Socket_Pool_B]... (Status: BLOCKED)
2026-11-10 19:53:12,458 [INFO] [AgentWorker][Worker-Thread-2] WAITING for [Shared_Memory_A]... (Status: BLOCKED)
```

[Before 전체 앱 로그](../evidence/deadlock-true-20261110-195228/app.log)에서 T1은 A 보유 후 B 요청, T2는 B 보유 후 A 요청이라는 관계를 확인했습니다. POTENTIAL DEADLOCK 경고만으로 판정하지 않고 실제 자원 관계와 정체를 함께 봤습니다.

### After: 진행과 메모리 정리

```text
>>> [SYSTEM] MEMORY RECOVERED (Cache Cleared) <<<
2026-11-10 19:59:01,893 [INFO] [CpuWorker] Peak reached (40.00%). Starting cooldown...
2026-11-10 19:59:04,765 [INFO] [MemoryWorker] Current Heap: 525MB
2026-11-10 19:59:04,766 [WARNING] [MemoryWorker] Memory Usage Reached Limit (525MB). Starting cleanup...
2026-11-10 19:59:04,781 [INFO] [System] Memory Cache Flushed. Process Stabilized.
>>> [SYSTEM] MEMORY RECOVERED (Cache Cleared) <<<
2026-11-10 19:59:06,014 [INFO] [CpuWorker] Current Load: 37.21%
>>> [SYSTEM] MEMORY RECOVERED (Cache Cleared) <<<
>>> [SYSTEM] MEMORY RECOVERED (Cache Cleared) <<<
>>> [SYSTEM] MEMORY RECOVERED (Cache Cleared) <<<
```

두 관측 사이에 새 로그 661바이트가 추가됐으며 CPU 냉각·메모리 정리 후 작업 로그가 계속됐습니다. RSS도 384,032KiB 감소해 정리 로그와 부합합니다. 값이 바뀌었다는 사실 하나만으로 정상 판정하지 않고 실제 작업 진행을 연결했습니다. [After 전체 앱 로그](../evidence/deadlock-false-20261110-195628/app.log), [After 연속 관제](../evidence/deadlock-false-20261110-195628/monitor-16896.csv).

## 3. Root Cause Analysis (원인 분석)

**순환 대기:** T1 → B(T2 보유) → T2 → A(T1 보유) → T1 관계입니다. 각 워커가 하나를 가진 채 상대가 가진 추가 자원을 기다려 앞으로 나아가지 못합니다. 메인도 워커 완료를 기다리는 로그와 futex 대기가 관측됐습니다.

| 교착 조건 | 뜻 | 이번 증거와 연결 |
|---|---|---|
| 상호 배제 | 자원에 배타적 접근 | A와 B 각각의 LOCK ACQUIRED |
| 점유 대기 | 가진 채 추가 자원을 기다림 | Holding 후 상대 자원 WAITING |
| 비선점 | 대기자가 상대 락을 강제로 회수 못함 | 대기 중 반환·자동 회수 없음과 일반 락 모델로 추론 |
| 순환 대기 | 대기 관계가 고리를 형성 | T1은 B, T2는 A를 기다림 |

**OS 측정 해석:** futex_do_wait는 동기화 대기 위치이며 정상 대기도 가능합니다. 이 값 하나만으로 교착을 확정하지 않았습니다. 같은 PID의 TID 행은 주소 공간을 공유하므로 RSS를 행 수만큼 합산하지 않습니다. TID 15174/15175와 로그 Worker-Thread-1/2의 개별 대응, 락 종류·타임아웃 구현은 미확인입니다.

**false의 의미:** After에도 3개 스레드와 메인 futex 대기가 남았지만 워커 작업은 진행했습니다. 따라서 false를 앱 전체 단일 스레드 전환으로 설명하지 않고, 관측한 동시 트랜잭션 교착 경로의 회피로 설명합니다.

## 4. Workaround & Verification (조치 및 검증)

MULTI_THREAD_ENABLE만 false로 변경한 뒤 같은 형식의 10초 간격 관측을 반복했습니다. PID 유지와 함께 로그 크기 8778→9439바이트, 수정 시각 변경, 냉각·메모리 정리와 후속 작업을 확인해 **관측 구간에서 해당 교착 경로가 회피됐다고 판단**했습니다. 무한 시간의 안정성이나 모든 요청의 응답을 측정한 것은 아닙니다.

두 실행은 관측 후 수동 SIGTERM으로 정리했습니다. Before는 교착 중 스스로 종료된 것이 아닙니다.

Before 정리 기록:

```text
2026-11-10T19:55:33+09:00 manual SIGTERM PID=15052
```

After 정리 기록:

```text
2026-11-10T20:02:55+09:00 manual SIGTERM PID=16896
2026-11-10T20:02:55+09:00 manual SIGTERM PID=16865
```

Before에는 작업 자식 15052 한 행만 기록됐습니다. 자식 종료 후 실행기도 이미 사라진 상황과 부합하며, 기록 없는 부모에 직접 신호를 보냈다고 주장하지 않습니다. After에는 16896·16865가 각각 기록됐습니다. 두 실행의 143은 수동 정리 결과입니다.

원본: [Before 수동 정리](../evidence/deadlock-true-20261110-195228/cleanup.log), [After 수동 정리](../evidence/deadlock-false-20261110-195628/cleanup.log), [Before 종료 코드](../evidence/deadlock-true-20261110-195228/exit-code.txt), [After 종료 코드](../evidence/deadlock-false-20261110-195628/exit-code.txt), [Before 정리 후 ps](../evidence/deadlock-true-20261110-195228/ps-after-cleanup.txt), [After 정리 후 ps](../evidence/deadlock-false-20261110-195628/ps-after-cleanup.txt).

근본 수정은 모든 경로의 락 획득 순서를 A→B처럼 통일하고, 중첩 락 축소·타임아웃/롤백·예외 시 해제 보장을 검토하는 것입니다. 실제 소스 수정과 검증은 별도 작업입니다.

### 평가 설명 문장

“true에서 PID는 남았지만 로그와 메모리가 정체됐고 두 워커의 순환 대기를 확인했습니다. false에서는 로그와 작업이 진행해 관측 구간에서 교착 경로가 회피됐다고 판단했습니다.”
