# [Bug] Deadlock - 반대 락 순서로 순환 대기, 동시 설정 false에서 작업 진행 확인

실험 환경: Ubuntu 26.04.1 LTS / WSL2 / x86_64 / 일반 사용자 jae0608(UID 1000). 커널은 6.18.58.1-microsoft-standard-WSL2입니다. 실험일은 **2026-11-10 KST(UTC+09:00)**입니다.

환경 출처는 [백업 시점 환경 기록](../environment-at-backup.txt)입니다. 이 파일은 20:16:42에 수집됐으므로 메모리 여유량 등을 장애 발생 순간의 값으로 인용하지 않습니다. 아래 수치는 10월 9일 기존 보고서와 구분한 이번 재실습의 값입니다. 바이너리 디컴파일·리버스 엔지니어링은 수행하지 않았습니다.

**처음 읽는 순서:** 비교 표 → 조회 명령의 **코드 해석** → 정체된 스냅샷의 **출력 해석** → 자원 보유·대기 로그 → false 변경 후 진행입니다. [용어집](../glossary.md)의 [Deadlock](../glossary.md#deadlock), [PID](../glossary.md#pid), [스레드](../glossary.md#thread), [futex](../glossary.md#futex), [RSS](../glossary.md#rss)를 클릭해 뜻을 확인할 수 있습니다.

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

### 코드 해석 — 왜 이렇게 입력했나요?

| 입력 구문 | 뜻 | 이 순서로 확인한 이유 |
|---|---|---|
| `ps -ef` | 모든 프로세스를 전체 형식으로 조회합니다. `-e`는 전체 선택, `-f`는 부모 관계 등을 포함한 형식입니다. | 먼저 프로세스가 종료됐는지 남아 있는지 확인합니다. |
| `| grep '[a]gent-leak-app'` | 앞의 출력에서 앱 이름이 있는 행을 고릅니다. 파이프는 출력 전달, grep은 문자열·패턴 검색입니다. | script 세션·부모 실행기·작업 자식을 구분합니다. `[a]`는 a 한 글자와 일치하지만 grep 자신의 명령 문자열은 그대로 일치하지 않아 자기 자신이 결과에 섞이는 것을 줄입니다. |
| `ps -L` | 프로세스 내부의 스레드를 행별로 표시합니다. | 프로세스 존재 여부에서 한 단계 더 들어가 실행 흐름들의 대기를 봅니다. |
| `-p "$WORKER_PID"` | 확인한 작업 자식 PID 하나를 고릅니다. | 작은 부모 실행기만 보고 실제 작업이 정상이라고 오해하지 않기 위해서입니다. |
| `-o pid,tid,pcpu,rss,time,stat,wchan:32,comm` | 출력할 열과 순서를 지정합니다. `wchan:32`는 대기 지점 이름의 출력 폭입니다. | 어떤 스레드가 CPU를 쓰거나 어디서 대기하는지 같은 형식으로 비교합니다. |
| `stat -c 'log_bytes=%s modified=%y' ...` | 파일 크기와 마지막 내용 수정 시각을 지정 형식으로 출력합니다. `%s`는 바이트 수, `%y`는 수정 시각입니다. | 마지막 문장만 같은 것인지 파일 전체의 증가도 멈춘 것인지 비교합니다. |
| `tail -n 20 ...` | 파일의 마지막 20줄을 봅니다. | 방대한 로그 중 멈춘 지점과 직전 자원 관계를 찾습니다. |

`"$WORKER_PID"`와 `"$RUN_DIR/app.log"`는 변수에 저장된 실제 PID와 파일 경로를 사용합니다. `$`를 붙이지 않은 이름을 그대로 입력하면 저장된 값 대신 문자 이름을 명령에 전달하게 됩니다. [ps](../glossary.md#ps), [로그](../glossary.md#log) 참조.

이 조회들을 `capture_agent_state()` 함수에 묶어 같은 형식으로 다시 호출했습니다. 함수는 여러 명령에 이름을 붙여 재사용하는 Bash 문법입니다. `capture_agent_state | tee "$RUN_DIR/snapshot-1.txt"`는 화면에도 보여주고 파일에도 같은 출력을 저장합니다. `sleep 10`은 다음 조회 전 10초를 기다리는 명령이며, 실제 비교 시각은 각 스냅샷 첫 줄의 날짜로 확인했습니다. 첫째·둘째 조회 사이에 앱을 재시작한 것이 아닙니다.

실행 조건에서 `export MULTI_THREAD_ENABLE=true`는 교착 경로를 재현하는 비교 조건이고, `false`는 변경 후 조건입니다. 메모리 512와 CPU 40은 두 실행 모두 유지했습니다. **false는 앱 전체가 한 스레드로 바뀐다는 보장이 아니므로 실제 스레드 수는 출력으로 별도 확인했습니다.** 실행·PTY·PID별 CSV 수집 방법은 [CPU 보고서의 코드 해석](02-cpu.md) 및 [monitor.sh 상세 해설](../monitor-code-guide.md)과 같습니다.

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

#### 출력 해석 — 스냅샷의 각 행은 무엇을 의미하나요?

| 출력 | 해석 | 이 값만으로 알 수 없는 내용 |
|---|---|---|
| `script` PID 15018 | 터미널 출력 기록 세션입니다. | 앱의 실제 작업 주체가 아닙니다. |
| 앱 PID 15021, 부모 15018 | script가 시작한 앱 실행기입니다. | 이 실행기 존재만으로 작업이 진행한다고 할 수 없습니다. |
| 앱 PID 15052, 부모 15021 | 실제 작업 자식입니다. | PID는 살아 있어도 내부 스레드가 막혀 있을 수 있습니다. |
| TID 15052 / 15174 / 15175 | 같은 프로세스 안의 세 실행 흐름입니다. 주 스레드의 TID는 PID와 같습니다. | 두 TID가 로그의 Worker-Thread-1/2 중 각각 누구인지는 이번 자료로 대응시키지 못했습니다. |
| `%CPU 0.0`, `TIME 00:00:00` | 표시에 잡힌 평균 CPU와 누적 CPU 시간이 매우 작습니다. | 한 번의 0만으로 교착을 확정하지 않습니다. |
| `RSS 18428` 세 행 | 프로세스가 상주 메모리 18,428KiB를 공유합니다. | 스레드마다 별개로 18,428KiB를 쓰는 것이 아니므로 세 배로 합산하면 안 됩니다. |
| `STAT SNl+` | 대기 S, 낮은 우선순위 N, 여러 스레드 l, 전경 프로세스 그룹 +입니다. | 이 상태 문자열 자체가 교착의 전용 표시는 아닙니다. |
| `WCHAN futex_do_wait` | 커널의 동기화 대기 지점에 있습니다. | 정상적인 락·조건 대기에서도 보이므로 자원 순환 로그가 필요합니다. |
| `log_bytes=2802` | 기록 파일 크기가 2,802바이트입니다. | 크기 한 번만으로는 정체를 알 수 없어 두 시점과 비교했습니다. |
| `modified=19:53:12.458...` | 파일 내용이 마지막으로 수정된 시각입니다. | 현재 스냅샷 시각 19:53:53과 다릅니다. 수정 시각이 그대로인 점을 다음 로그와 연결합니다. |

쉬운 판단 순서: **존재한다 → 그러나 시간이 지나도 자원·로그가 정체된다 → 스레드들이 동기화 대기 중이다 → 마지막 로그에 서로 기다리는 자원이 명시돼 있다**입니다. “CPU가 0이니까 교착”처럼 한 가지 수치로 끝내지 않았습니다.

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

#### 출력 해석 — LOCK ACQUIRED와 WAITING은 무엇인가요?

1. `Worker-Thread-1 ... LOCK ACQUIRED: [Shared_Memory_A]. (Holding...)`는 첫 워커가 A의 사용 권한을 확보해 계속 보유하고 있다는 뜻입니다. 이 문장은 아직 오류가 아닙니다.
2. `Worker-Thread-2 ... LOCK ACQUIRED: [Socket_Pool_B]. (Holding...)`는 두 번째 워커가 B를 보유했다는 뜻입니다. A·B는 앱 로그에서 사용하는 자원 이름이며 실제 내부 구현은 확인하지 않았습니다.
3. 첫 워커의 `WAITING for [Socket_Pool_B] ... BLOCKED`는 일을 끝내려면 B가 더 필요하지만 다른 워커가 보유해 기다린다는 뜻입니다.
4. 둘째 워커의 `WAITING for [Shared_Memory_A] ... BLOCKED`는 A가 더 필요하지만 첫 워커가 보유해 기다린다는 뜻입니다.
5. `Waiting for worker threads to complete transactions`는 주 실행 흐름도 워커들이 끝나길 기다린다는 앱 기록입니다. 작업 완료 로그가 뒤따르지 않고 두 스냅샷도 정체돼 있다는 점을 연결합니다.

자원 관계를 말로 설명하면 **첫 워커는 A를 놓지 않고 B를 기다리고, 둘째 워커는 B를 놓지 않고 A를 기다립니다.** 둘 중 어느 쪽도 먼저 끝내고 자원을 반환하지 못하는 고리입니다. `BLOCKED`는 앱의 문구이며 ps의 상태 글자가 반드시 B로 표시된다는 뜻은 아닙니다. [교착상태](../glossary.md#deadlock) 참조.

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

#### 출력 해석 — 변경 후에는 무엇이 달라졌나요?

- 로그 크기 `9439 - 8778 = 661`바이트 증가는 두 관측 사이 새 내용이 기록됐다는 뜻입니다. 단순 경고 반복만으로 진행을 단정하지 않고 어떤 작업 내용이 추가됐는지 봤습니다.
- `Peak reached ... Starting cooldown`은 CPU 담당 부분이 부하를 줄이는 단계에 들어갔다는 뜻입니다.
- `Current Heap: 525MB`와 `Memory Usage Reached Limit`는 이 실행 경로에서 메모리 정리가 시작되는 조건을 기록한 것입니다. `Starting cleanup`은 정리를 시작한다는 뜻이고 OOM 실험의 `Self-terminating`과는 다릅니다.
- `Memory Cache Flushed. Process Stabilized`와 `MEMORY RECOVERED (Cache Cleared)`는 앱이 캐시 정리를 기록한 문구입니다. OS의 모든 캐시를 비웠다거나 모든 장애를 영구 해결했다는 뜻으로 확대하지 않습니다.
- 뒤따르는 `Current Load: 37.21%`는 CPU 작업 로그가 이어졌다는 근거입니다. After의 메인 스레드가 futex 대기를 하더라도 워커 작업 진행과 모순되지 않습니다.
- RSS `505008 → 120976`은 `384032KiB` 감소입니다. 메모리 정리 로그와 부합하지만 감소 자체를 교착 회피의 유일한 근거로 삼지 않았습니다.

따라서 결론은 “10초 관측 구간에서 해당 교착 경로가 회피됐고 작업이 진행했다”입니다. 모든 서비스 요청의 응답이나 이후 영구 안정성까지 확인했다고 말하지 않습니다.

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

### 코드·출력 해석 — 정리는 왜 따로 기록하나요?

실험자는 관측을 마친 뒤 대상 PID인지 확인하고 `kill -TERM "$PID"`로 [SIGTERM](../glossary.md#sigterm)을 보냈습니다. 이는 교착을 코드로 해결한 것이 아니라 이번 실행을 종료한 것입니다. `cleanup.log`의 시각과 PID를 남겨 자동 보호 종료로 오해하지 않게 했습니다. `wait "$SESSION_PID"` 직후 상태를 저장해 두 실행 모두 143이 남았습니다. [종료 코드](../glossary.md#exit-code)는 SIGTERM 종료와 부합하며 누가 요청했는지는 수동 기록이 설명합니다.

정리 후 ps에 제목만 남는 것은 **조회한 PID의 데이터 행이 없다**는 뜻입니다. 포트 조회에 아무 행이 없었던 것은 해당 조건의 listening 소켓이 없었다는 뜻입니다. 이 두 조회로 실험 대상이 정리됐는지 확인했으며 시스템 전체가 비었다는 뜻은 아닙니다.

### 증거 링크를 누르면 무엇을 보나요?

| 클릭할 증거 | 먼저 찾을 부분 | 이 증거가 필요한 이유 |
|---|---|---|
| settings.txt: [true](../evidence/deadlock-true-20261110-195228/settings.txt) / [false](../evidence/deadlock-false-20261110-195628/settings.txt) | 메모리 512, CPU 40은 동일하고 true/false만 변경 | 단일 설정 변경 비교인지 확인합니다. |
| Before [snapshot-1.txt](../evidence/deadlock-true-20261110-195228/snapshot-1.txt) / [snapshot-2.txt](../evidence/deadlock-true-20261110-195228/snapshot-2.txt) | 첫 줄 시각, 작업 PID 15052, TID, RSS, log_bytes·modified | 약 10초 동안 존재하지만 정체된 상태를 같은 형식으로 비교합니다. |
| [Before monitor-15052.csv](../evidence/deadlock-true-20261110-195228/monitor-15052.csv) | 같은 PID의 CPU·RSS·스레드 수 추세 | 한 장면만 본 것이 아니라 연속 관측도 남겼는지 확인합니다. |
| [Before app.log](../evidence/deadlock-true-20261110-195228/app.log) | A와 B의 LOCK ACQUIRED → 상대 자원 WAITING | 대기가 순환 관계인지 직접 추적합니다. 경고 제목만 읽지 않습니다. |
| After [snapshot-1.txt](../evidence/deadlock-false-20261110-195628/snapshot-1.txt) / [snapshot-2.txt](../evidence/deadlock-false-20261110-195628/snapshot-2.txt) | 작업 PID 16896, 로그 8778→9439, 새 작업 행 | 살아 있는 것에 더해 일이 진행하는지 확인합니다. |
| After [app.log](../evidence/deadlock-false-20261110-195628/app.log) · [monitor-16896.csv](../evidence/deadlock-false-20261110-195628/monitor-16896.csv) | 냉각·cleanup·그 뒤의 Current Load, RSS 변화 | 실제 작업 진행과 정리 동작이 측정 변화와 부합하는지 봅니다. |
| cleanup.log: [Before](../evidence/deadlock-true-20261110-195228/cleanup.log) / [After](../evidence/deadlock-false-20261110-195628/cleanup.log), exit-code.txt: [Before](../evidence/deadlock-true-20261110-195228/exit-code.txt) / [After](../evidence/deadlock-false-20261110-195628/exit-code.txt) | manual SIGTERM과 143 | 장애 재현 상태와 실험자의 종료를 구분합니다. |
| ps-after-cleanup.txt: [Before](../evidence/deadlock-true-20261110-195228/ps-after-cleanup.txt) / [After](../evidence/deadlock-false-20261110-195628/ps-after-cleanup.txt) | 제목 아래 대상 PID 행 부재 | 실험이 끝난 뒤 프로세스를 남기지 않았는지 확인합니다. |

표 안의 파일 링크를 직접 누르면 해당 원본이 열립니다. 로그·스레드 대기·자원 관계를 함께 설명해야 하며, `futex_do_wait` 한 단어만 가리키고 교착이라고 결론내리지 않습니다.

근본 수정은 모든 경로의 락 획득 순서를 A→B처럼 통일하고, 중첩 락 축소·타임아웃/롤백·예외 시 해제 보장을 검토하는 것입니다. 실제 소스 수정과 검증은 별도 작업입니다.

### 평가 설명 문장

“true에서 PID는 남았지만 로그와 메모리가 정체됐고 두 워커의 순환 대기를 확인했습니다. false에서는 로그와 작업이 진행해 관측 구간에서 교착 경로가 회피됐다고 판단했습니다.”
