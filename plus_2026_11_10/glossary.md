# 용어집: 코드와 출력에서 만나는 말

[README로 돌아가기](README.md) · [발표 최종 메모](evaluation-final-memo.md) · [monitor.sh 전체 코드 해설](monitor-code-guide.md)

[용어집 메모장용 다운로드](glossary.txt)

보고서의 파란 용어를 클릭하면 이 문서의 해당 항목으로 이동합니다. 아래에서는 **뜻 → 이번 실습에서 읽는 방법 → 주의할 해석** 순서로 설명합니다. 로그 속 영문은 원본이므로 그대로 두고 한국어 설명을 붙였습니다.

## 찾아보기

- 환경과 실행: [OS](#os), [WSL2·Ubuntu](#wsl), [아키텍처](#architecture), [프로세스·PID](#pid), [스레드·TID](#thread), [권한](#permissions), [환경변수·source](#environment-variable), [포트](#port).
- 메모리: [Memory Leak와 OOM](#oom), [Heap·Current Heap](#current-heap), [RSS](#rss), [단위 MB·MiB·KiB](#units), [MemoryGuard](#memoryguard), [MEMORY_LIMIT](#memory-limit), [한도 초과](#memory-limit-exceeded), [캐시·정리](#cache).
- CPU: [CPU와 사용률](#cpu), [CPU_MAX_OCCUPY](#cpu-max-occupy), [Current Load](#current-load), [Watchdog](#watchdog), [cooldown](#cooldown), [nice·우선순위](#nice).
- 교착: [Deadlock와 네 조건](#deadlock), [락·공유 자원](#lock), [futex·WCHAN](#futex), [MULTI_THREAD_ENABLE](#multi-thread-enable).
- 도구·증거: [monitor.sh](#monitor-sh), [ps](#ps), [top](#top), [CSV·awk](#csv), [로그](#log), [script·PTY](#script), [리다이렉션·백그라운드](#shell), [SIGTERM](#sigterm), [SIGKILL](#sigkill), [종료 코드](#exit-code), [Before & After](#comparison), [해시](#hash).

<a id="os"></a>
## OS: Operating System, 운영체제

프로그램이 CPU·메모리·파일·네트워크를 사용할 수 있도록 관리하는 기본 소프트웨어입니다. 이 실습에서는 Ubuntu 안에서 Linux 커널이 관리하는 프로세스 정보를 ps와 top으로 읽었습니다.

**구분:** 앱이 출력한 `Current Heap`은 앱 내부 기록이고 `RSS`는 OS 도구의 측정입니다. Windows PC Manager의 전체 RAM 비율도 별도 범위의 지표입니다. 이 셋을 같은 값처럼 비교하지 않습니다.

<a id="wsl"></a>
## WSL2·Ubuntu·커널

WSL은 Windows에서 Linux 환경을 사용하는 기능이며, 이번에는 WSL2의 Ubuntu에서 실행했습니다. Ubuntu는 Linux 배포판이고 커널은 프로세스·메모리 등을 관리하는 핵심 부분입니다.

`uname -r`의 `6.18.58.1-microsoft-standard-WSL2`는 이번 환경의 커널 식별 정보입니다. `cat /etc/os-release`는 Ubuntu 배포판 정보를 보여줍니다. [환경 파일](environment-at-backup.txt)은 백업 시점 기록이므로 장애 순간의 메모리 여유량 증거로 사용하지 않습니다.

<a id="architecture"></a>
## 아키텍처·x86_64·ELF

아키텍처는 CPU가 실행하는 명령 체계입니다. `uname -m`이 `x86_64`여서 제공 파일 중 `file` 결과가 `x86-64`인 `agent-leak-app-x86`을 선택했습니다. 파일 이름의 x86만 보고 32비트라고 판단하지 않았습니다.

ELF는 Linux 실행 파일 등에 사용하는 형식입니다. `file`의 `dynamically linked`는 동적 링크 방식이라는 뜻이며, `stripped`는 일부 심벌 정보가 제거됐다는 뜻입니다. 이 확인은 실행 환경을 고르기 위한 파일 형식 조회이며 디컴파일은 수행하지 않았습니다.

<a id="pid"></a>
## 프로세스·PID·PPID·부모 실행기

프로세스는 실행 중인 프로그램의 한 인스턴스입니다. PID는 해당 프로세스 번호, PPID는 부모 프로세스 번호입니다. 숫자는 실행할 때마다 달라지며 이후 재사용될 수 있습니다.

이번 OOM Before에서는 부모 실행기 PID 11329 아래 작업 자식 PID 11373이 있었고, 메모리가 크게 증가한 것은 작업 자식입니다. `script`를 사용하는 실행에서는 기록 세션의 PID도 별도로 존재합니다. **세션 PID·앱 부모 PID·작업 PID·관제 PID는 서로 다른 역할**입니다.

`ps`에 PID가 있다는 것은 프로세스 존재의 근거입니다. 요청에 응답하거나 작업이 진행한다는 뜻까지 보장하지는 않습니다.

<a id="thread"></a>
## 스레드·TID·NLWP

스레드는 프로세스 안의 실행 흐름입니다. 같은 프로세스의 스레드들은 주소 공간을 공유합니다. TID는 스레드 번호, NLWP는 스레드 수입니다.

Deadlock의 `ps -L`은 하나의 PID 안에 있는 스레드를 여러 행으로 보여줍니다. 각 행에 RSS가 반복돼도 공유 메모리이므로 행 수만큼 더하지 않습니다. OS의 TID와 앱 로그의 `Worker-Thread-1` 이름은 별도 정보여서 대응이 기록되지 않았다면 임의로 연결하지 않습니다.

<a id="permissions"></a>
## 일반 사용자·UID·chmod·실행 권한

`whoami`는 계정 이름, `id -u`는 사용자 번호를 보여줍니다. 이번 `jae0608`, UID 1000은 root(UID 0)가 아닌 계정으로 실행했다는 근거입니다.

`chmod u+x agent-leak-app`은 파일 소유자에게 실행 권한을 추가합니다. `ls -l`의 `-rwxr-xr-x`에서 첫 `-`는 일반 파일, 뒤 세 묶음은 소유자·그룹·기타 사용자 권한입니다. r은 읽기, w는 쓰기, x는 실행입니다. 디렉터리의 x는 경로를 통과해 접근하는 권한입니다.

`chmod 600 secret.key`는 소유자만 읽고 쓸 수 있게 합니다. 실행 권한이나 키 파일 준비 자체가 장애를 해결하는 것은 아니며 앱의 부팅 요구사항을 맞추는 과정입니다.

<a id="environment-variable"></a>
## 환경변수·env.sh·export·source·cat

환경변수는 새로 실행되는 프로그램에 전달할 이름과 값입니다. `env.sh`에는 이를 설정하는 셸 명령을 저장했습니다.

- `cat env.sh`: 파일 안에 적힌 내용을 **읽어서 보여줍니다**. 설정을 적용하지 않습니다.
- `source ./env.sh`: 파일의 명령을 **현재 셸에서 실행합니다**. 이 파일 안의 export가 적용됩니다.
- `export MEMORY_LIMIT=256`: 현재 셸에서 시작하는 프로그램에 해당 값을 전달합니다. 이미 실행 중인 앱 설정을 자동 변경하지는 않습니다.
- `$HOME`은 사용자 홈 경로이고 `$AGENT_HOME`은 앞에서 지정한 변수 값을 넣는 표현입니다. 큰따옴표는 경로 안의 공백 등이 여러 인자로 쪼개지는 것을 막습니다.
- 새 터미널에서는 필요한 설정을 다시 적용해야 합니다. 저장된 env.sh는 초기 128/100/false이므로 실행별 settings.txt와 앱 부팅 로그를 함께 확인합니다.

| 변수 | 앱이 요구하는 내용·이번 사용 이유 |
|---|---|
| AGENT_HOME | 실습 기준 경로. 이번에는 `/home/jae0608/agent-b42-practice` |
| AGENT_PORT | 앱 요구사항인 15034 |
| AGENT_UPLOAD_DIR | 업로드 폴더 경로. 실제 디렉터리도 준비해야 함 |
| AGENT_KEY_PATH | api_keys 디렉터리. 안에 요구된 secret.key 준비 |
| AGENT_LOG_DIR | 기록할 로그 디렉터리. 존재·쓰기·접근 권한 확인 |
| MEMORY_LIMIT | 앱 메모리 판단용 설정. 허용 50~512, 단위는 앱 표시 MB |
| CPU_MAX_OCCUPY | 앱 CPU 작업 관련 설정. 허용 10~100 |
| MULTI_THREAD_ENABLE | 이번 교착 경로 재현·회피 비교에 사용한 설정 |

<a id="port"></a>
## 포트·listen·바인딩

포트는 네트워크 통신의 접점을 구분하는 번호입니다. 바인딩은 앱이 주소와 포트에 소켓을 연결하는 과정이고 listen은 연결 요청을 받을 준비 상태입니다.

`ss -ltnH 'sport = :15034'`는 해당 포트의 TCP listening 소켓을 조회합니다. `-l`은 listening, `-t`는 TCP, `-n`은 숫자 표시, `-H`는 제목 생략입니다. 정상 조회에서 출력이 비어 있으면 그 순간 조회 범위에 맞는 listening 소켓이 없다는 뜻입니다. 이후 앱이 반드시 바인딩할 수 있다는 영구 보장은 아닙니다.

<a id="oom"></a>
## Memory Leak와 OOM

Memory Leak는 더 이상 필요 없는 메모리를 회수하지 못해 사용량이 누적되는 문제입니다. Python처럼 자동 메모리 관리가 있어도 필요 없는 참조를 계속 유지하면 데이터가 남을 수 있습니다.

OOM(Out Of Memory)은 필요한 메모리를 확보하지 못하는 상황입니다. 메모리 증가와 OOM은 관련될 수 있지만 모든 OOM이 누수 때문인 것은 아닙니다. 이번 과제 이름은 OOM Crash지만 **직접 확인한 종료는 앱의 MemoryGuard 정책**입니다. 커널 OOM Killer 개입이나 정확한 누수 코드 위치까지 입증한 것은 아닙니다.

비유: 물을 계속 담는 모습은 RSS·Heap 증가, 컵의 관리 기준은 MEMORY_LIMIT, 기준을 보고 종료시키는 장치는 MemoryGuard입니다. 컵 크기를 키우는 것과 물이 계속 들어오는 원인을 고치는 것은 다릅니다.

<a id="current-heap"></a>
## Heap·Current Heap·MemoryWorker

힙(Heap)은 프로그램이 실행 중 동적으로 데이터를 보관할 때 사용하는 메모리 영역을 설명하는 말입니다. `Current Heap`은 이 앱의 MemoryWorker가 **현재 메모리 값으로 로그에 출력한 내부 지표**입니다. 내부 계산 방법을 역분석한 것은 아닙니다.

예: `Current Heap: 150MB`는 앱이 해당 시점 값을 150MB로 기록했다는 뜻입니다. RSS 전체가 정확히 150MB라는 뜻은 아닙니다. MemoryWorker는 메모리 작업을 수행하며 로그를 남기는 앱 구성요소의 이름입니다.

이번 128/256 비교에서는 약 3초마다 25MB씩 늘었습니다. 중간 시점에는 값이 유지되므로 짧게 보면 계단 모양이며 전체로는 지속 상승하는 추세였습니다.

<a id="rss"></a>
## RSS·RES·%MEM

RSS(Resident Set Size)는 프로세스 메모리 중 실제 RAM에 상주하는 양입니다. 가상 주소 공간 전체 크기와 다릅니다. ps의 rss는 KiB로 읽었습니다. top의 RES는 상주 메모리 열이며 표시 단위 설정을 함께 봅니다.

Before의 `rss_kib=146412`는 `146412 ÷ 1024 ≈ 142.98MiB`입니다. `%MEM=1.8`은 해당 Linux 환경 메모리 기준 비율이며 Windows 전체 RAM 비율과 같다고 해석하지 않습니다.

RSS 상승은 메모리 점유 증가의 증거입니다. 정상 캐시나 작업량 증가도 가능하므로 RSS 하나만으로 누수 위치나 종료 주체를 확정하지 않습니다. 이번에는 앱의 지속 증가 로그·한도 초과·자체 종료를 함께 연결했습니다.

<a id="units"></a>
## 바이트·KiB·MiB·MB·초

- 1바이트(byte)는 데이터 크기 단위입니다. 키 문자열의 영문·숫자·밑줄 18글자는 이번 UTF-8 저장에서 18바이트였습니다.
- 1KiB = 1,024바이트, 1MiB = 1,024KiB입니다. 1MB의 표준 십진 정의는 1,000,000바이트입니다.
- 앱은 MB, ps는 KiB, top 요약은 MiB처럼 표시하므로 단위를 함께 적습니다. 앱의 MB 내부 계산을 확인하지 않은 상태에서 이름만 보고 모든 수치를 정확히 환산해 동일시하지 않습니다.
- `17.185초`는 로그 시각의 차이입니다. `ELAPSED=86`은 ps가 표시한 프로세스 실행 경과 초입니다. 폴더 생성 시각이나 사용자가 입력한 sleep 시간과 구분합니다.

<a id="memoryguard"></a>
## MemoryGuard·Self-terminating

MemoryGuard는 앱 내부 메모리 보호 구성요소의 이름입니다. 이번에는 한도 초과 뒤 `Self-terminating process 11373 to prevent system instability.`를 기록했습니다. “시스템 불안정을 막기 위해 해당 프로세스를 스스로 종료한다”는 뜻입니다.

보호 종료를 두는 목적은 한 프로세스의 메모리 증가가 다른 프로세스와 시스템 자원에 미치는 영향을 줄이는 것입니다. 이것을 Linux 커널의 OOM Killer와 같은 기능이라고 설명하지 않습니다. 실제 종료 여부는 종료 코드와 이후 PID 조회도 함께 확인했습니다.

<a id="memory-limit"></a>
## MEMORY_LIMIT·메모리 한도

이 앱이 메모리 관련 판단에 사용하는 환경변수입니다. OS나 Windows의 전체 RAM 용량을 지정하는 설정이 아닙니다.

128은 빠르게 보호 종료를 관찰한 조건, 256은 한도만 늘려 생존 시간 변화를 비교한 조건입니다. CPU·Deadlock 비교에서는 512로 고정해 다른 설정 효과를 살폈습니다. 이 값들은 과제 허용 범위 안의 실험값이며 모든 서버의 권장 운영값은 아닙니다.

<a id="memory-limit-exceeded"></a>
## Memory limit exceeded·한도 초과·Recommend

`Memory limit exceeded (150MB >= 128MB)`는 앱이 비교한 메모리 값이 설정 한도 이상이라는 뜻입니다. `>=`는 크거나 같다는 비교입니다. 앱 값이 125→150으로 증가했으므로 128을 정확히 기록하지 않아도 한도를 넘을 수 있습니다.

이 문구는 **종료 조건을 판단했다는 근거**, 이어진 Self-terminating은 **종료 행동을 기록한 근거**입니다. 이후 PID 부재와 함께 해석합니다.

`Recommend Over 256MB`는 256MB보다 큰 값을 권고하는 안내입니다. 256 자체에서도 경고가 나왔지만 부팅 실패는 아니었습니다. 경고와 실제 종료를 구분합니다.

<a id="cache"></a>
## 캐시·cleanup·Memory recovered

캐시는 나중에 다시 사용할 데이터를 보관하는 공간입니다. 무제한으로 보관하면 메모리 증가 요인이 될 수 있지만 모든 캐시가 누수는 아닙니다.

`Starting cleanup`은 정리 시작, `Memory Cache Flushed`는 앱이 캐시 정리를 기록했다는 뜻, `MEMORY RECOVERED`는 앱의 회수 알림입니다. false 실행에서는 이 로그와 RSS 감소·후속 작업을 함께 확인했습니다. 이것을 128/256 OOM 비교에서 코드를 고친 결과로 섞지 않습니다.

<a id="cpu"></a>
## CPU·CPU 사용률·Latency

CPU는 명령을 실행하는 연산 자원입니다. 실행 가능한 작업이 CPU를 계속 점유하면 같은 CPU에서 처리할 다른 작업이 기다릴 수 있어 응답 지연(latency)이 커질 수 있습니다.

이번에는 CPU 사용률과 앱 동작을 관측했습니다. 실제 요청 응답 시간이나 P99는 측정하지 않았습니다. P99는 요청 지연의 99번째 백분위수 같은 분포 지표이므로 CPU 수치만으로 대신할 수 없습니다.

<a id="cpu-max-occupy"></a>
## CPU_MAX_OCCUPY

이 앱의 CPU 작업 관련 환경변수입니다. 이번에는 80과 40을 비교했습니다. 앱의 표시 이름은 Maximum CPU Limit이지만 **프로세스 전체에 대한 OS 강제 CPU 상한이라고 확인한 것은 아닙니다.**

80 설정에서 앱 내부 50.5%에 임계치 위반이 기록됐으므로 “80%를 넘어서 종료”라고 말하지 않습니다. 정확한 내부 판단식은 미확인입니다. 40에서는 내부 40%에 냉각했고 top은 한 구간 70%를 관측했습니다. CPU 작업 설정과 OS 관측을 분리해 설명합니다.

<a id="current-load"></a>
## Current Load·CpuWorker·Peak reached

Current Load는 CpuWorker가 기록한 앱 내부 부하 값입니다. top 프로세스 행의 %CPU나 상단 load average와 다른 이름·범위의 지표입니다. 내부 산식을 확인하지 않았습니다.

`Peak reached (40.00%)`는 앱이 해당 값에 도달했다고 기록한 것이고, `Starting cooldown`은 이후 부하 감소 단계로 들어간다는 뜻입니다. 같은 초의 top 70%와 앱 내부 39.53%가 함께 존재해도 두 값을 같은 측정으로 단정하지 않습니다.

<a id="watchdog"></a>
## Watchdog·CPU Threshold Violated

Watchdog는 상태를 감시하고 보호 동작을 요청하는 장치를 가리키는 말입니다. 이번 로그의 `CPU Threshold Violated`는 CPU 관련 임계 조건 위반을, `WATCHDOG: INITIATING EMERGENCY ABORT (SIGTERM)`은 감시 정책의 종료 요청을 나타냅니다.

이 문구와 실제 종료를 연결해 보호 종료라고 판단했습니다. 예외 오류가 전혀 없었다거나 모든 임계치가 환경변수 숫자와 똑같다고 확장하지 않습니다.

<a id="cooldown"></a>
## Cooldown·냉각

이번 앱 로그에서는 부하를 낮추는 단계입니다. `Cooldown complete (5.00%). Resuming load increase`는 내부 부하를 낮춘 뒤 다시 증가시키는 단계로 전환했다는 기록입니다.

물리 CPU 온도를 측정해 식혔다는 뜻으로 쓰지 않았습니다. 냉각 로그, 계속되는 작업, PID 존재를 함께 보아 관측 구간의 진행을 확인했습니다.

<a id="nice"></a>
## nice·PR·NI·S

nice는 일반적인 CPU 스케줄링에서 상대적 우선순위에 영향을 주는 값입니다. 앱은 nice=10으로 우선순위를 낮췄다고 기록했고 top의 NI=10과 부합했습니다. CPU 사용률을 특정 비율로 강제 제한하는 값은 아닙니다.

PR은 도구가 보여주는 우선순위 열입니다. S는 읽는 순간의 상태이며 대기 상태 S라도 직전 측정 구간에는 CPU를 썼을 수 있습니다. 따라서 top 화면의 S와 70%는 모순이라고 볼 수 없습니다.

<a id="deadlock"></a>
## Deadlock·교착상태·네 조건

서로 필요한 자원을 가진 실행 흐름들이 상대를 기다려 진행하지 못하는 상태입니다. 이번에는 T1이 A를 가지고 B를 기다리고, T2가 B를 가지고 A를 기다렸습니다.

| 조건 | 쉬운 뜻 | 이번 연결 |
|---|---|---|
| 상호 배제 | 한 번에 하나만 사용 | 각각의 락 획득 기록 |
| 점유 대기 | 가진 것을 놓지 않고 더 기다림 | Holding 후 상대 자원 WAITING |
| 비선점 | 상대가 가진 것을 대기자가 강제 회수하지 못함 | 대기 로그와 일반적인 락 동작으로 추론 |
| 순환 대기 | 서로 기다리는 관계가 고리 | T1→B→T2→A→T1 |

네 조건은 대표적인 교착 모델의 조건입니다. 이름을 나열하거나 CPU가 낮다는 사실만으로 진단하지 않고 이번 소유·대기 관계와 정체 기록에 연결했습니다. false 변경 후 관측 구간에서 진행한 것이며 모든 미래 교착의 제거를 검증한 것은 아닙니다.

<a id="lock"></a>
## Lock·LOCK ACQUIRED·Holding·WAITING·BLOCKED

락은 공유 자원에 동시에 접근할 때 순서를 제어하는 동기화 수단입니다. `LOCK ACQUIRED`는 획득, `Holding`은 보유, `WAITING`은 기다림, `BLOCKED`는 다음 진행이 막혔다는 앱의 상태 표현입니다.

`Shared_Memory_A`와 `Socket_Pool_B`는 앱이 자원에 붙인 이름입니다. 이름만으로 실제 OS 공유 메모리 객체나 소켓 구현을 역추정하지 않았습니다. 먼저 누가 무엇을 획득했는지, 다음에 무엇을 기다렸는지를 시간순으로 읽습니다.

<a id="futex"></a>
## WCHAN·futex_do_wait·poll

WCHAN은 대기 중인 작업의 커널 대기 위치를 보여주는 열입니다. futex는 사용자 공간 동기화를 지원하는 Linux 기능이며 `futex_do_wait`는 관련 대기 위치입니다. 정상 락 대기나 작업 완료 대기에도 나타날 수 있습니다.

poll 계열 이름은 이벤트 대기와 관련된 위치입니다. 특정 이름 자체를 “정상” 또는 “교착” 판정기로 쓰지 않습니다. true에서는 정체와 순환 대기 로그를, false에서는 후속 작업 진행을 함께 비교했습니다.

<a id="multi-thread-enable"></a>
## MULTI_THREAD_ENABLE·true·false

동시 처리 경로를 비교하는 데 사용한 앱 환경변수입니다. true 실행에서는 교착 경로가 재현됐고 false 실행에서는 해당 관측 구간에 작업이 진행했습니다.

false에서도 세 스레드가 존재했습니다. 따라서 “false는 앱 전체를 한 스레드로 바꾼다”는 설명은 피합니다. 입력값 변경과 실제 관측 결과를 구분합니다.

<a id="monitor-sh"></a>
## monitor.sh·셸 스크립트

여러 명령을 파일에 적어 순서·반복·조건을 자동 실행하게 만든 관제 스크립트입니다. 앱의 내부 소스가 아니라 외부에서 ps로 자원 정보를 읽는 도구입니다.

이번 monitor.sh는 PID 한 개를 받아 CSV를 반복 출력합니다. 자체 경보, 누수 코드 탐색, 자동 복구 기능은 구현하지 않았습니다. [전체 코드와 줄별 해설](monitor-code-guide.md)에서 입력 검증부터 종료 메시지까지 확인할 수 있습니다.

<a id="ps"></a>
## ps·ps -L·ELAPSED·TIME·STAT

ps는 조회 시점의 프로세스 정보를 보여줍니다. `-p`는 PID 선택, `-o`는 열 선택, `-L`은 스레드 표시입니다. `ps -ef`에서 `-e`는 전체 선택, `-f`는 자세한 형식입니다.

ELAPSED는 경과 시간, TIME은 누적 CPU 시간이라 서로 다릅니다. `%CPU`는 프로세스 수명 기준 평균입니다. STAT의 S는 대기, R은 실행 중 또는 실행 가능, Z는 좀비, N은 낮은 우선순위, l은 멀티스레드, +는 전경 프로세스 그룹입니다.

제목만 있는 출력은 해당 조회 조건에 일치하는 행이 없음을 뜻합니다. 조회 실패와 구분해야 하며 이번에는 정리 로그·포트 조회와 함께 확인했습니다. [ps 매뉴얼](https://man7.org/linux/man-pages/man1/ps.1.html)

<a id="top"></a>
## top·상단 요약과 프로세스 행

top은 시스템과 프로세스 상태를 반복 갱신합니다. 프로세스 행의 `%CPU`는 갱신 구간 사용률입니다. 일반적인 Irix 표시에서는 100%가 논리 CPU 하나 기준이므로 여러 CPU 전체의 요약과 구분합니다.

이번 상단 `95.1 id`는 시스템 CPU 요약의 유휴 비율이고 특정 프로세스의 70%는 프로세스 행입니다. 분모·범위가 달라 직접 빼거나 합치지 않습니다. `load average`는 실행 가능·일부 대기 작업 수 관련 평균이며 CPU 퍼센트가 아닙니다.

`-b`는 배치, `-d`는 간격, `-p`는 PID 선택, `-w`는 출력 폭, `-H`는 스레드 표시입니다. 이번 스레드 증거는 ps -L로 수집했으며 top -H를 실제 사용한 것처럼 바꾸지 않습니다. 분석의 `$9`는 당시 기본 열 배치의 CPU 위치여서 열 구성이 달라지면 추출도 점검해야 합니다. [top 매뉴얼](https://man7.org/linux/man-pages/man1/top.1.html)

<a id="csv"></a>
## CSV·awk·grep·tail·stat·tee

- CSV: 쉼표로 값을 나눈 표입니다. 첫 줄은 열 이름, 다음 줄부터 측정값입니다.
- awk: 열과 조건으로 텍스트를 처리합니다. monitor의 `$6`은 ps 결과의 RSS이고 top 집계의 `$9`는 당시 top의 CPU 열입니다. 서로 다른 입력입니다.
- grep: 조건에 맞는 줄을 찾습니다. `-n`은 줄 번호, `-E`는 확장 정규식입니다. `110:`은 grep이 붙인 번호이며 앱의 지표가 아닙니다.
- tail -n 20: 마지막 20줄을 읽습니다. stat의 `%s`는 파일 바이트 수, `%y`는 수정 시각입니다.
- tee: 출력을 화면과 파일 양쪽에 전달합니다. 파일로 남겨 같은 증거를 나중에 보여주기 위해 사용했습니다.

grep 출력이 비었을 때 정상적인 미일치인지 파일 오류인지 구분합니다. 문구가 없다는 사실은 모든 오류 부재를 보장하지 않습니다.

<a id="log"></a>
## 로그·타임스탬프·INFO·WARNING·CRITICAL

로그는 프로그램의 동작 기록입니다. `2026-11-10 19:36:53,846`은 기록 시각과 밀리초, `[CRITICAL]`은 기록 수준, `[MemoryGuard]`는 기록 주체의 이름입니다.

INFO는 일반 정보, WARNING은 경고, CRITICAL은 심각한 상태를 나타내도록 앱이 붙인 수준입니다. WARNING이 있다는 사실만으로 종료를 뜻하지 않으며, INFO만 있어도 실제 진행 여부를 확인해야 합니다.

`app.log`는 앱 또는 PTY 출력을 모은 기록, `monitor-*.csv`는 OS 조회 수치, `cleanup.log`는 실험자가 보낸 종료 요청 기록입니다. 이처럼 기록 주체가 달라 서로 대조합니다.

<a id="script"></a>
## script·PTY·세션

script는 가상 터미널(PTY)의 출력을 파일로 보존하는 도구입니다. 터미널에서 나온 Watchdog 문구까지 기록하기 위해 사용했습니다. 터미널 방식에 따라 출력이 달라질 수 있지만 앱 내부 구현까지 단정하지는 않습니다.

`-q`는 시작·종료 안내를 조용히 하고, `-e`는 자식 종료 상태를 반영하며, `-f`는 기록을 자주 반영하고, `-c`는 실행할 명령을 지정합니다. 파일에는 script 자체의 시작·종료 표식도 포함될 수 있어 앱 로그와 구분합니다. [script 매뉴얼](https://man7.org/linux/man-pages/man1/script.1.html)

<a id="shell"></a>
## 리다이렉션·파이프·백그라운드·$!·wait

`>`는 출력을 파일로 보내며 기존 내용을 덮어쓸 수 있고, `>>`는 덧붙입니다. `2>`는 표준 오류를 보냅니다. `2>&1`은 그 시점 표준 출력과 같은 곳으로 표준 오류도 연결합니다. `|`는 왼쪽 출력을 오른쪽 입력으로 전달합니다.

줄 끝 `&`는 백그라운드 실행입니다. 바로 뒤 `$!`는 최근 백그라운드 작업의 PID입니다. 앱 실행 뒤에는 앱 실행기 PID, monitor 실행 뒤에는 관제 PID이므로 저장 시점이 중요합니다.

`wait "$APP_PID"`는 셸의 해당 자식 종료를 기다립니다. `$?`는 직전 명령의 종료 상태여서 다른 명령을 실행하기 전에 저장했습니다. `[1] 11329`에서 `[1]`은 셸 작업 번호이고 11329가 PID입니다. 이 안내문을 다시 명령으로 입력하지 않습니다.

<a id="sigterm"></a>
## SIGTERM·kill -TERM·수동 정리

시그널은 프로세스에 전달하는 알림 수단입니다. SIGTERM은 종료 요청이며 프로그램이 처리할 수 있습니다. `kill -TERM PID`는 해당 요청을 보냅니다. 이름이 kill이라고 항상 강제 즉시 종료를 뜻하지는 않습니다.

CPU Before는 Watchdog 로그, CPU After와 Deadlock은 cleanup.log의 manual SIGTERM으로 요청자를 구분했습니다. 성공적으로 신호를 보낸 것과 실제 종료 완료는 별개여서 wait와 이후 ps를 확인했습니다. [signal 매뉴얼](https://man7.org/linux/man-pages/man7/signal.7.html)

<a id="sigkill"></a>
## SIGKILL·Killed

SIGKILL은 대상이 처리하거나 무시할 수 없는 강제 종료 시그널입니다. 셸의 `Killed`와 종료 코드 137은 이 해석과 부합합니다. 다만 누구의 요청이었는지까지 알려주지는 않습니다.

이번 OOM은 앱의 자체 종료 로그와 연결해 판단했습니다. “Killed가 보였으니 Windows RAM 부족 또는 커널 OOM Killer”라는 결론은 내리지 않았습니다.

<a id="exit-code"></a>
## 종료 코드 0·1·137·143

종료 코드는 명령의 종료 상태입니다. 0은 일반적으로 성공이며, 1은 도구별 오류·조건 불일치 등에 사용됩니다. 예를 들어 grep의 1은 검색 미일치일 수 있습니다.

Bash의 시그널 종료 표현 `128 + 시그널 번호`로 137은 128+9(SIGKILL), 143은 128+15(SIGTERM)에 해당합니다. **숫자는 종료 원인의 전체 설명이 아닙니다.** 같은 143이어도 앱 보호 요청과 실험자의 수동 요청이 다르므로 로그를 봅니다.

<a id="comparison"></a>
## Before & After·임시 조치·근본 해결·생존과 진행

Before는 변경 전, After는 변경 후입니다. 다른 조건을 가능한 한 유지하고 한 변수를 바꿔 결과를 비교했습니다. 비교할 값의 측정 방식과 기간도 함께 기록합니다.

OOM은 128→256으로 종료가 늦어졌지만 증가 원인을 고치지 않았습니다. CPU는 관측 구간의 보호 종료 회피·냉각을, Deadlock은 해당 경로의 진행을 확인했습니다. 소스 수정이나 영구 안정성을 검증한 것처럼 설명하지 않습니다.

생존은 PID 존재, 진행은 작업 로그 등의 변화, 응답성은 실제 요청에 대한 응답 여부입니다. 셋은 서로 다른 확인 항목입니다.

<a id="hash"></a>
## SHA256SUMS·원본 증거·무결성

SHA-256은 파일 바이트에서 계산한 해시 값입니다. SHA256SUMS는 파일 이름과 값을 모아 복사 전후 변경 여부를 점검하기 위한 목록입니다.

이번에는 evidence 98개와 설정·관제 스크립트를 원본 백업과 대조했습니다. 해시가 같다는 것은 바이트가 같다는 확인이며, 보고서의 원인 분석이 반드시 옳다는 뜻은 아닙니다. 원본 로그는 수정하지 않고 해석을 별도 문서에 붙입니다.

## 공식 자료로 더 확인하기

도구 옵션과 OS 개념은 [ps](https://man7.org/linux/man-pages/man1/ps.1.html), [top](https://man7.org/linux/man-pages/man1/top.1.html), [script](https://man7.org/linux/man-pages/man1/script.1.html), [signal](https://man7.org/linux/man-pages/man7/signal.7.html), [futex](https://man7.org/linux/man-pages/man2/futex.2.html), [Python 스레딩](https://docs.python.org/3/library/threading.html)을 참고합니다. 앱 구성요소의 이름과 동작에 대한 판단은 이 저장소의 실제 실행 로그를 근거로 합니다.
