# GitHub 화면으로 설명하는 B4-2 전체 발표 대본

**링크를 연 뒤 내용을 해석하려면:** 각 원본 링크 옆의 **코드·출력 해석**을 누르세요. [파일32종의 상세 해설](linked-file-commentary.md)에서 명령의 옵션·처리 순서와 출력의 열·값·문장을 설명합니다.

작성일: 2026-10-23. 기준 자료: 이 저장소의 2026-10-09 실험. 이 문서는 교안을 바탕으로 발표를 준비하는 자료이며 새 실습 완료를 뜻하지 않습니다. 실제로 이해하고 확인한 범위에 맞춰 표현을 조정합니다.

**출력 화면 읽기:** 아래 회색 코드 블록은 원본 파일에 보존된 실제 출력 또는 저장 파일 내용입니다. 입력할 명령이 아닙니다. 새로 실행하거나 화면을 합성하지 않았습니다. CRLF 줄바꿈을 화면 표시용 LF로 정규화했으며, 발췌 범위와 원본 링크를 표시했습니다. 새 실습에서는 시각·PID·수치가 달라질 수 있습니다.

## 1. 이 자료를 사용하는 방법과 전체 순서

발표는 약 10~15분을 기준으로 구성했습니다. 평가 시간이 짧으면 각 절의 **발표할 말**을 중심으로 설명하고, 질문을 받으면 출력 해설과 예상 질문을 사용합니다. 모든 로그를 처음부터 끝까지 읽기보다 결론을 뒷받침하는 구간을 보여줍니다.

| 순서 | 열 화면 | 설명할 핵심 |
|---|---|---|
| 1 | README | 과제 목적과 세 가지 장애 |
| 2 | 환경 정보·env.sh | Linux 실행 조건과 준비 이유 |
| 3 | monitor.sh | PID별 관제와 각 지표 |
| 4 | 설정 비교 표 | 128/256/512, 100/80/40, true/false 선택 이유 |
| 5 | OOM 보고서·CSV·로그 | 메모리 증가와 MemoryGuard 종료 |
| 6 | CPU 보고서·top·로그 | CPU 상승, Watchdog 종료, 냉각 비교 |
| 7 | Deadlock 보고서·스냅샷·로그 | 살아 있으나 진행하지 못하는 순환 대기 |
| 8 | 종료·정리 기록 | 자동 종료와 실험자 종료 구분 |
| 9 | 보고서 양식·분석 한계 | 증거에 근거한 협업 보고 |
| 10 | 정리 발언 | 배운 점과 추가 확인할 내용 |

설명의 공통 구조는 **현상 → 증거 → 원인 판단 → 조치 → 결과 → 한계**입니다. 원본 파일 옆의 해설이 필요하면 [증거 링크별 출력 해설](evidence-reading-guide.md) · [코드·출력 해석](linked-file-commentary.md#해설-01)을 함께 엽니다.

## 2. README: 과제 전체를 소개하기

**열 화면:** [저장소 README](../README.md) · [코드·출력 해석](linked-file-commentary.md#해설-02)의 소개와 검증 결과 표.

**발표할 말**

> 이 과제는 제공된 Linux 프로그램을 실행하면서 메모리 증가에 따른 종료, CPU 과점유에 따른 보호 종료, 교착상태를 관측하고 원인을 분석하는 실습입니다.
>
> 장애가 발생했을 때 다시 실행하는 데서 끝내지 않고, 실행 당시 설정과 로그, 프로세스 상태를 기록해 원인을 설명하는 것이 목표였습니다.
>
> 실행 환경은 Ubuntu WSL2의 일반 사용자 계정이었습니다. ps, top, 직접 작성한 monitor.sh와 앱 로그로 증거를 수집했고, 환경변수를 변경하기 전과 후를 비교해 세 가지 Issue 형식 보고서로 정리했습니다.

**화면에서 가리킬 부분**

검증 결과 표의 세 행을 가리킵니다. OOM은 MEMORY_LIMIT, CPU는 CPU_MAX_OCCUPY, Deadlock은 MULTI_THREAD_ENABLE을 비교했다고 먼저 알려주면 이후 설명을 따라가기 쉽습니다.

**용어 설명**

- 프로세스: 실행 중인 프로그램의 단위.
- 관제: 시간에 따라 자원 사용량과 상태를 확인하고 기록하는 일.
- Issue 형식 보고서: 현상·증거·원인·조치와 검증을 동료가 재확인할 수 있게 정리한 문서.

**예상 질문: 무엇을 직접 분석했나요?**

앱 설정과 부팅·작업·보호 로그를 읽고, PID별 자원 사용과 진행 여부를 비교했습니다. 바이너리의 디컴파일이나 내부 코드 역분석은 수행하지 않았습니다.

## 3. 실행 환경: 왜 준비 명령부터 확인했는가

**열 화면:** [환경 정보](../evidence/environment.txt) · [코드·출력 해석](linked-file-commentary.md#해설-03), [실험의 env.sh](../scripts/env.sh) · [코드·출력 해석](linked-file-commentary.md#해설-04), OOM 보고서의 부팅 로그.

**발표할 말**

> 프로그램은 Linux용 실행 파일이므로 Windows에서 Ubuntu WSL2를 사용했습니다. 실행 전에 계정과 CPU 아키텍처부터 확인했습니다.
>
> whoami는 사용자 이름을, id -u는 사용자 번호를 확인합니다. UID가1000이므로 root의 UID0이 아닌 일반 계정임을 확인했습니다. uname -m의 x86_64와 파일 형식 조회 결과를 대조해 x86 실행 파일을 선택했습니다.
>
> 이후 작업 폴더와 실행 권한, 환경변수, 키 파일, 로그 디렉터리, 포트 상태를 준비했습니다. 준비 오류로 실행이 실패한 상황과 과제에서 재현할 장애를 구분하기 위해서입니다.

**명령을 왜 입력했는지 설명하기**

| 명령·구문 | 실행 목적 | 출력이 이렇게 나오는 이유 |
|---|---|---|
| wsl -d Ubuntu | 지정한 Ubuntu 배포판 시작 | PowerShell에서 Ubuntu 셸 프롬프트로 전환 |
| cd ~ / pwd | 홈으로 이동하고 현재 위치 확인 | cd는 보통 조용히 완료, pwd는 경로를 출력 |
| whoami / id -u | 실행 계정과 UID 확인 | 이름과 숫자 식별자를 각각 요청했기 때문 |
| uname -r / uname -m | 커널과 CPU 아키텍처 확인 | 서로 다른 시스템 정보를 조회 |
| file 실행파일 | 바이너리 형식·아키텍처 확인 | ELF, x86-64 등의 형식 정보가 표시됨 |
| mkdir -p | 필요한 폴더 준비 | 성공 시 보통 출력 없음 |
| cp 원본 대상 | 실습용 복사본 준비 | 보통 출력 없이 복사하므로 ls로 확인 |
| chmod u+x | 파일 소유자의 실행 권한 추가 | 실행 허용 권한을 바꾸며 앱을 실행하지는 않음 |
| source env.sh | 설정을 현재 셸에 적용 | 파일을 읽어 변수값이 현재 셸에 반영 |
| export | 이후 자식 프로세스에 설정 전달 | 새로 시작한 앱이 환경변수를 읽을 수 있음 |
| chmod 600 secret.key | 키 파일 소유자만 읽기·쓰기 허용 | ls에서 -rw-------로 확인 |
| ss -ltn 'sport = :15034' | TCP15034 리스닝 여부 조회 | 제목만 있으면 해당 리스닝 행이 없는 것 |

키 파일 내용은 과제에서 요구한 테스트 문자열이며 실제 서비스 자격 증명을 설명하는 자료가 아닙니다. 15034는 과제의 고정 포트입니다. 포트가 비었다는 조회는 당시 상태이며 이후 바인딩 성공은 앱 부팅 로그로 다시 확인합니다.

**용어 설명**

UID는 사용자의 숫자 식별자, root는 관리자 계정, x86_64는 CPU 명령 체계입니다. 환경변수는 프로그램에 전달하는 설정이며, 실행 권한은 파일을 실행할 수 있도록 허용하는 권한입니다.

**예상 질문: All Boot Checks Passed이면 모든 장애가 없나요?**

아닙니다. 준비 조건을 통과했다는 의미입니다. 실행 후의 메모리 증가, CPU 부하, 교착 여부는 별도의 관제가 필요합니다.


### 출력 화면 3-1. 실행 환경을 확인한 실제 기록

**2026-10-09 실제 기록 발췌 — 입력할 명령이 아닙니다.**

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

원본: [environment.txt](../evidence/environment.txt#L1-L20) · [코드·출력 해석](linked-file-commentary.md#해설-03). date·uname·id·os-release·nproc·free의 결과를 한 파일에 모은 기록입니다. nproc 결과인14는 이어지는 free 표와 다른 출력입니다.

**화면 해설:** `uid=1000(jae0608)`는 사용자 번호와 이름이며, `x86_64`는 아키텍처입니다. `Mem: 7.5Gi`는 이 WSL 환경이 보는 물리 메모리 총량입니다. `available 6.9Gi`는 당시 가용량이며 모든 실험 시점의 메모리 상태를 뜻하지 않습니다.

### 출력 화면 3-2. 앱 부팅 검사 통과

**2026-10-09 실제 기록 발췌 — 입력할 명령이 아닙니다.**

```text
>>> Starting Agent Boot Sequence...
[1/6] Checking User Account               [OK]
   ... Running as service user 'jae0608' (uid=1000)
[2/6] Verifying Environment Variables     [OK]
   ... All required Envs correct
[3/6] Checking Required Files             [OK]
   ... Verified 'secret.key' with correct key string.
[4/6] Checking Port Availability          [OK]
   ... Port 15034 is available.
[5/6] Verifying Log Permission            [OK]
   ... Log directory is writable: /home/jae0608/jae-test/logs
[6/6] Verifying Mission Environment       [OK]
   ... MEMORY_LIMIT=128MB, CPU_MAX_OCCUPY=100%, MULTI_THREAD_ENABLE=False
------------------------------------------------------------
All Boot Checks Passed!
Agent READY
```

원본: [app.log](../evidence/oom-128-20261009-113259/app.log#L1-L16) · [코드·출력 해석](linked-file-commentary.md#해설-05). 준비 명령의 효과를 앱이 검사한 결과입니다.

**화면 해설:** `[1/6]~[6/6]`은 여섯 가지 부팅 검사 순서입니다. `[OK]`와 `Agent READY`는 실행 전 조건을 통과했다는 의미입니다. 이후 작업의 안정성까지 보장하지 않습니다.

## 4. 관제 방법: 어떤 프로세스를 어떻게 기록했는가

**열 화면:** [monitor.sh](../scripts/monitor.sh) · [코드·출력 해석](linked-file-commentary.md#해설-06), [OOM 작업 PID962의 CSV](../evidence/oom-128-20261009-113259/monitor-962.csv) · [코드·출력 해석](linked-file-commentary.md#해설-07).

**발표할 말**

> 앱을 백그라운드로 실행한 뒤 실행기와 자식 프로세스의 PID 관계를 확인했습니다. 실제 작업을 하는 자식의 자원 증가를 놓치지 않도록 각각 기록했습니다.
>
> monitor.sh는 대상 PID의 ps 출력을 약1초마다 읽습니다. awk로 열을 쉼표로 연결해 CSV로 저장하고, 조회되는 유효 프로세스 행이 없어지면 수집을 끝냅니다.
>
> CSV에는 시각, PID와 부모 PID, 경과 시간, CPU 평균, 메모리 비율, RSS, 스레드 수와 상태가 들어갑니다. CPU와 메모리의 수치는 측정 범위와 단위를 구분했습니다.

**CSV 한 줄을 실제로 읽는 예**

OOM128 자료의 마지막 구간에서 작업 PID는962, 부모는954, 경과 시간은17초, CPU 평균은0.8%, 메모리 비율은1.8%, RSS는146376KiB, 스레드 수는1, 상태는SN입니다.

- RSS146376KiB는 약142.945MiB입니다. KiB에서 MiB로 바꾸려면1024로 나눕니다.
- SN의 S는 수면, N은 낮은 우선순위를 뜻합니다. 한 순간 수면 상태여도 메모리 문제가 없다는 의미는 아닙니다.
- mem_pct는 Linux가 보는 메모리 비율입니다. 앱 한도128MB를 분모로 계산한 비율이 아닙니다.
- cpu_avg_pct는 ps의 실행 이후 평균입니다. 짧은 CPU 급상승을 보기 위해 CPU 실험에서는 top도 함께 기록했습니다.

**셸 구문 설명**

`&`는 백그라운드 실행, `$!`는 직전 백그라운드 작업의 PID, `>`는 표준 출력의 파일 저장, `2>&1`은 표준 오류도 같은 출력 대상으로 보내는 구문입니다. `wait`는 현재 셸이 시작한 작업의 종료를 기다리고 상태를 받습니다. `$?`는 바로 직전 명령의 종료 상태이므로 다른 명령 전에 저장합니다.

**예상 질문: RSS는 앱의 Current Heap과 같나요?**

RSS는 OS가 관측한 실제 상주량이고 Current Heap은 앱 내부 로그 값입니다. 전체 메모리 범위와 측정 시각이 다르므로 같은 숫자로 취급하지 않습니다.


### 출력 화면 4-1. monitor.sh가 저장한 작업 프로세스 CSV

**2026-10-09 실제 기록 발췌 — 입력할 명령이 아닙니다.**

```text
timestamp,pid,ppid,elapsed_s,cpu_avg_pct,mem_pct,rss_kib,threads,state
2026-10-09T11:33:01+09:00,962,954,1,2.0,0.2,18356,1,SN
2026-10-09T11:33:02+09:00,962,954,2,2.0,0.5,43960,1,SN
2026-10-09T11:33:03+09:00,962,954,3,1.5,0.5,43960,1,SN
2026-10-09T11:33:04+09:00,962,954,4,1.2,0.5,43960,1,SN
2026-10-09T11:33:05+09:00,962,954,5,1.1,0.8,69564,1,SN
2026-10-09T11:33:06+09:00,962,954,6,1.0,0.8,69564,1,SN
2026-10-09T11:33:07+09:00,962,954,8,0.8,0.8,69564,1,SN
2026-10-09T11:33:08+09:00,962,954,9,1.1,1.2,95168,1,SN
2026-10-09T11:33:09+09:00,962,954,10,0.9,1.2,95168,1,SN
2026-10-09T11:33:10+09:00,962,954,11,0.9,1.2,95168,1,SN
2026-10-09T11:33:11+09:00,962,954,12,0.9,1.5,120772,1,SN
2026-10-09T11:33:12+09:00,962,954,13,0.9,1.5,120772,1,SN
2026-10-09T11:33:13+09:00,962,954,14,0.8,1.5,120772,1,SN
2026-10-09T11:33:14+09:00,962,954,15,0.9,1.8,146376,1,SN
2026-10-09T11:33:16+09:00,962,954,16,0.8,1.8,146376,1,SN
2026-10-09T11:33:17+09:00,962,954,17,0.8,1.8,146376,1,SN
```

원본: [monitor-962.csv](../evidence/oom-128-20261009-113259/monitor-962.csv#L1-L17) · [코드·출력 해석](linked-file-commentary.md#해설-07). 각 줄은 같은 PID의 다른 측정 시각입니다.

**화면 해설:** 처음 RSS18356에서 마지막146376KiB까지 증가하는 열을 따라 읽습니다. `elapsed_s`가 커지는 동안 CPU 평균은 낮지만 메모리는 증가했습니다. 메모리와CPU를 별개 지표로 읽어야 하는 이유입니다. 부모PID954와 작업PID962를 혼동하지 않습니다.

## 5. 설정값: 왜 이 조합을 사용했는가

**열 화면:** [통합 교안의 설정값 설명](complete-course.md#실험-설정값은-왜-이렇게-골랐는가) · [코드·출력 해석](linked-file-commentary.md#해설-08).

**발표할 말**

> 각 설정은 과제의 허용 범위 안에서 비교 목적에 맞춰 선택했습니다. OOM은 메모리128과256, CPU는80과40, 교착은true와false를 비교했습니다. 각 비교 안에서는 나머지 설정을 고정했습니다.
>
> 메모리128은 비교적 짧은 시간에 증가와 종료를 확인하려고 택했고,256은 한도를 두 배로 높인 영향을 비교하기 쉬운 값입니다. CPU와 교착 실험에서는 메모리 설정을 허용 상한512로 고정했습니다.
>
> CPU80은 부하 상승과 보호 종료를 관찰한 조건입니다.40은 앱이 안내하는50 미만 권고에 들어가는 비교값이며, 이 조건에서 냉각 동작을 관찰했습니다. 동시 설정은 OOM과 CPU에서false로 고정하고, 교착 실험에서만true/false를 비교했습니다.

| 실험 | 메모리 설정 | CPU 설정 | 동시 설정 |
|---|---|---|---|
| OOM Before / After | 128 / 256 | 100 / 100 | false / false |
| CPU Before / After | 512 / 512 | 80 / 40 | false / false |
| Deadlock Before / After | 512 / 512 | 40 / 40 | true / false |

**설명할 때 구분할 것**

- 허용 범위: 앱이 받아들이는 입력 조건. 메모리50~512, CPU10~100.
- 권장값: 앱 로그의 운영상 안내. 메모리는256 초과, CPU는50 미만.
- 실험값: 비교 목적에 따라 선택한 값.
- 실제 보호 기준: 실제 동작과 로그로 확인해야 하는 판정 조건.

128/256은 RAM을 즉시 그만큼 예약한다는 뜻이 아닙니다. CPU100도 보호 기능을 끈다는 뜻으로 확인하지 않았습니다. CPU80 설정에서 내부53.11%로 종료됐으므로 설정80을 정확한 종료 임계치80%라고 설명하지 않습니다. 이 값들이 모든 서버의 운영 권장값인 것도 아닙니다.

**용어 설명**

통제 변수는 고정한 조건, 변경 변수는 실험에서 바꾼 조건, 결과 지표는 생존 시간·RSS·CPU·로그 진행 등입니다. Before와After는 변경 전후의 별도 실행입니다.


### 출력 화면 5-1. OOM 변경 전 저장 설정

**2026-10-09 실제 기록 발췌 — 입력할 명령이 아닙니다.**

```text
MEMORY_LIMIT=128
CPU_MAX_OCCUPY=100
MULTI_THREAD_ENABLE=false
```

원본: [settings.txt](../evidence/oom-128-20261009-113259/settings.txt#L1-L3) · [코드·출력 해석](linked-file-commentary.md#해설-09). 


### 출력 화면 5-2. OOM 변경 후 저장 설정

**2026-10-09 실제 기록 발췌 — 입력할 명령이 아닙니다.**

```text
MEMORY_LIMIT=256
CPU_MAX_OCCUPY=100
MULTI_THREAD_ENABLE=false
```

원본: [settings.txt](../evidence/oom-256-20261009-113740/settings.txt#L1-L3) · [코드·출력 해석](linked-file-commentary.md#해설-10). 

**화면 해설:** 메모리128→256만 바뀌었고 CPU100과false는 유지됐습니다. 이 파일은 실행 전에 저장한 설정 내용이며, 적용 결과는 앞의 부팅 로그와도 대조합니다. 값을 저장했다는 사실과 앱이 그 값을 읽었다는 사실을 구분합니다.

## 6. OOM: 메모리 증가와 종료 원인을 설명하기

**열 화면:** [OOM 보고서](../reports/01-oom.md) · [코드·출력 해석](linked-file-commentary.md#해설-11) → [128 로그](../evidence/oom-128-20261009-113259/app.log) · [코드·출력 해석](linked-file-commentary.md#해설-05) → [128 CSV](../evidence/oom-128-20261009-113259/monitor-962.csv) · [코드·출력 해석](linked-file-commentary.md#해설-07) → 보고서의 전후 비교 표.

**발표할 말**

> 메모리128MB 조건에서는 부팅 검사 이후 메모리가 약3초마다25MB 단위로 증가했습니다. OS 관제에서도 RSS가18356에서146376KiB로 증가했습니다.
>
> 앱 로그는150MB에서 Memory limit exceeded와 Self-terminating process를 기록했습니다. 따라서 직접적인 종료 원인은 앱의 MemoryGuard 보호 정책으로 판단했습니다.
>
> 메모리 한도만256MB로 높여 다시 실행했더니275MB에서 같은 보호 정책으로 종료됐습니다. 로그 기준 생존 시간은17.202초에서32.363초로 늘어 약15.161초 연장됐습니다.
>
> 한도 상향은 영향을 줄인 임시 조치였습니다. 두 번째 실행에서도 증가와 종료가 반복됐으므로, 이 비교만으로 누수가 해결됐다고 결론내리지 않았습니다.

**출력은 왜 128이 아니라150에서 초과했는가**

앱 로그의 증가 단계가25MB이기 때문입니다.128 실험은125 다음150에서,256 실험은250 다음275에서 한도를 넘었습니다. 한도에 정확히 도달하는 숫자가 반드시 출력되는 것은 아닙니다.

**결과를 어떻게 계산했는가**

생존 시간은 보고서에서 정한 `Agent listening` 시작 로그와 MemoryGuard 종료 요청 로그 사이의 차이입니다. 폴더명 시각을 기준으로 계산하지 않았습니다. 따라서 OS가 완전히 종료한 정확한 순간까지의 시간과도 구분합니다.

**OS 원리와 분석 한계**

동적 데이터가 계속 보관되면 힙과 상주 페이지가 증가할 수 있습니다. 누적이 지속되면 다른 프로세스에 사용할 물리 메모리가 줄고 페이지 회수나 스왑으로 지연이 발생할 수 있습니다. 이번 종료는 앱 보호 로그가 근거이며, 전체 RAM 소진이나 커널 OOM Killer 개입을 입증한 실험은 아닙니다. 정확한 내부 자료구조나 해제 누락 위치도 확인하지 않았습니다.

**예상 질문: Windows 메모리70% 때문에 종료됐나요?**

Windows 전체 사용률과 앱 보호 한도는 범위가 다릅니다. 이번 종료의 직접 증거는 MemoryGuard의 한도 초과와 자체 종료 로그입니다.

**예상 질문: CSV 마지막 값이 종료 로그의150MB보다 작은 이유는요?**

RSS와 내부 Heap은 다른 지표이고,1초 간격 표본은 마지막 할당 직후와 종료 사이를 놓칠 수 있습니다. CSV의 최대는 관측 최대이지 종료 순간 절대 최대가 아닙니다.


### 출력 화면 6-1. 128MB 조건의 증가와 보호 종료

**2026-10-09 실제 기록 발췌 — 입력할 명령이 아닙니다.**

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

원본: [app.log](../evidence/oom-128-20261009-113259/app.log#L30-L37) · [코드·출력 해석](linked-file-commentary.md#해설-05). 


### 출력 화면 6-2. 256MB 조건의 증가와 보호 종료

**2026-10-09 실제 기록 발췌 — 입력할 명령이 아닙니다.**

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

원본: [app.log](../evidence/oom-256-20261009-113740/app.log#L30-L42) · [코드·출력 해석](linked-file-commentary.md#해설-12). 

**화면 해설:** 두 출력 모두 `[CRITICAL] [MemoryGuard]`를 확인합니다. `150MB >= 128MB`와 `275MB >= 256MB`는 앱 내부 한도 비교입니다. 마지막 `Self-terminating`이 앱의 자체 종료 요청을 설명합니다. 생존 시간은 이 블록의 첫25MB 로그가 아니라 보고서에서 정한 `Agent listening`부터 계산했습니다.

## 7. CPU: 부하 상승과 Watchdog 종료를 설명하기

**열 화면:** [CPU 보고서](../reports/02-cpu.md) · [코드·출력 해석](linked-file-commentary.md#해설-13) → [80 PTY 로그](../evidence/cpu-80-pty-20261009-115744/app.log) · [코드·출력 해석](linked-file-commentary.md#해설-14) → [top 원본](../evidence/cpu-80-pty-20261009-115744/top.log) · [코드·출력 해석](linked-file-commentary.md#해설-15) → [40 로그](../evidence/cpu-40-pty-20261009-122044/app.log) · [코드·출력 해석](linked-file-commentary.md#해설-16).

**발표할 말**

> CPU80 조건에서는 내부 부하가 증가하다53.11%에서 CPU Threshold Violated와 Watchdog의 긴급 종료 문구가 기록됐습니다. SIGTERM이 명시돼 있어 과점유 방지 보호 동작으로 판단했습니다.
>
> top의 프로세스별 관측 최대는50.0%였습니다. 앱 내부 수치와top은 계산 기준이나 측정 구간이 다를 수 있으므로 같은 값으로 취급하지 않았습니다.
>
> CPU 설정만40으로 낮춘 실행에서는 top 최대40.0%와 앱의40% 도달 후 냉각 동작을 관찰했습니다.55초 확인 시점에도 PID가 존재하고 작업 로그가 진행했습니다. 증거 수집을 마친 뒤에는 수동 종료했습니다.

**왜 top과 script를 사용했는가**

ps CPU는 실행 이후 평균이라 짧은 변화가 희석될 수 있습니다. 그래서 top을0.1초 간격으로 수집했고 최초 프레임을 제외해 PID별 최대를 계산했습니다. script는 가상 터미널에서 앱을 실행해 터미널 출력과 종료 상태를 보존하는 데 사용했습니다.

초기1초 관제는30프레임이고 종료 직전 구간이 빠졌습니다. 그 기록의 최대4%만으로 CPU 문제가 없다고 판단하지 않고 수집 간격과 기간을 보완했습니다. 자료의 부족을 발견하고 보완한 과정도 설명할 수 있습니다.

**top 화면 읽기**

윗부분 load average는 시스템 부하 평균이며 퍼센트가 아닙니다. 아래 PID 행의 %CPU가 이번 비교 대상입니다. 일반적인 Irix 모드에서 프로세스100%는 논리 CPU 하나 기준이며 노트북 전체100%와 동일하지 않습니다. 첫 프레임은 이후 갱신 구간과 기준이 달라 집계에서 제외했습니다.

**OS 원리와 분석 한계**

CPU를 많이 사용하는 프로세스가 있으면 다른 실행 가능한 작업이 CPU 시간을 기다릴 수 있어 응답 지연으로 이어질 수 있습니다. 이번 실험은 프로세스 부하와 보호 동작을 관측했으며 서비스 응답 시간이나 P99를 별도로 측정하지 않았습니다.40 설정의 관측 구간 생존을 영구 안정성으로 확대하지 않습니다.

**예상 질문: 80으로 설정했는데 왜53%에서 종료됐나요?**

설정값과 앱 내부 보호 기준의 정확한 대응은 확인하지 못했습니다. 로그에서53.11%와 Watchdog 종료를 확인했고, OS 관측값과도 구분했습니다. 내부 구현을 확인하지 않고80% 임계치라고 단정하지 않았습니다.

**예상 질문: 종료 코드가 둘 다143인데 조치에 실패했나요?**

Before는 Watchdog SIGTERM 로그가 있고 After는 수동 정리 기록이 있습니다.143이라는 숫자만으로 같은 종료 원인이라고 판단하지 않습니다.


### 출력 화면 7-1. CPU80의 top 실제 한 화면

**2026-10-09 실제 기록 발췌 — 입력할 명령이 아닙니다.**

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

원본: [top.log](../evidence/cpu-80-pty-20261009-115744/top.log#L2481-L2490) · [코드·출력 해석](linked-file-commentary.md#해설-15). 최초 프레임을 제외한 관측 최대50.0%가 나타나는 프레임 중 첫 번째를 발췌했습니다. 시간은11:58:11입니다.

**화면 해설:** PID1921 행의 `%CPU 50.0`이 작업 프로세스의 구간 사용률입니다. PID1920은 실행기입니다. 위의 `%Cpu(s)`는 시스템 전체 요약이므로 같은 값일 필요가 없습니다. 현재 상태S는 표본 순간 수면 중이라는 뜻이며, 직전 구간에 CPU를 사용했다는50%와 모순되지 않습니다. `Tasks: 2`는 PID 필터가 적용된 화면의 작업 수로 읽습니다.

### 출력 화면 7-2. CPU80의 Watchdog 종료

**2026-10-09 실제 기록 발췌 — 입력할 명령이 아닙니다.**

```text
2026-10-09 11:58:17,438 [INFO] [CpuWorker] Current Load: 48.93%
2026-10-09 11:58:20,549 [INFO] [CpuWorker] Current Load: 53.11%
2026-10-09 11:58:20,649 [CRITICAL] [CpuWorker] CPU Threshold Violated! (53.11%).

>>> [SYSTEM] WATCHDOG: INITIATING EMERGENCY ABORT (SIGTERM) <<<


Script done on 2026-10-09 11:58:20+09:00 [COMMAND_EXIT_CODE="143"]
```

원본: [app.log](../evidence/cpu-80-pty-20261009-115744/app.log#L42-L49) · [코드·출력 해석](linked-file-commentary.md#해설-14). 

**화면 해설:** 위 top 화면과 종료 로그는 서로 다른 시각입니다. `Current Load: 53.11%`는 앱 내부 값이고, `WATCHDOG ... (SIGTERM)`은 보호 종료 요청입니다. `Script done`은 기록 세션 종료 표지이며 `COMMAND_EXIT_CODE="143"`은 script가 기록한 실행 명령의 종료 상태입니다.

### 출력 화면 7-3. CPU40의 top 실제 한 화면

**2026-10-09 실제 기록 발췌 — 입력할 명령이 아닙니다.**

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

원본: [top.log](../evidence/cpu-40-pty-20261009-122044/top.log#L1941-L1950) · [코드·출력 해석](linked-file-commentary.md#해설-17). 최초 프레임을 제외한 관측 최대40.0%가 나타나는 프레임 중 첫 번째입니다.


### 출력 화면 7-4. CPU40 도달 후 냉각 구간

**2026-10-09 실제 기록 발췌 — 입력할 명령이 아닙니다.**

```text
2026-10-09 12:21:06,415 [INFO] [CpuWorker] Current Load: 38.47%
2026-10-09 12:21:08,526 [INFO] [CpuWorker] Peak reached (40.00%). Starting cooldown...
2026-10-09 12:21:08,953 [INFO] [MemoryWorker] Current Heap: 200MB
2026-10-09 12:21:09,526 [INFO] [CpuWorker] Current Load: 40.00%
2026-10-09 12:21:11,987 [INFO] [MemoryWorker] Current Heap: 225MB
2026-10-09 12:21:12,642 [INFO] [CpuWorker] Current Load: 32.54%
```

원본: [app.log](../evidence/cpu-40-pty-20261009-122044/app.log#L68-L73) · [코드·출력 해석](linked-file-commentary.md#해설-16). 


### 출력 화면 7-5. 냉각 완료와 재상승 시작

**2026-10-09 실제 기록 발췌 — 입력할 명령이 아닙니다.**

```text
2026-10-09 12:21:33,450 [INFO] [CpuWorker] Cooldown complete (5.00%). Resuming load increase...
2026-10-09 12:21:34,456 [INFO] [CpuWorker] Current Load: 5.00%
```

원본: [app.log](../evidence/cpu-40-pty-20261009-122044/app.log#L87-L88) · [코드·출력 해석](linked-file-commentary.md#해설-16). 


### 출력 화면 7-6. 경과55초 시점의 생존 확인

**2026-10-09 실제 기록 발췌 — 입력할 명령이 아닙니다.**

```text
    PID    PPID ELAPSED %CPU %MEM   RSS NLWP STAT
   2358    2356      55  0.1  0.0  2248    1 Ss+
   2359    2358      55  1.4  6.1 479420   3 SNl+
```

원본: [ps-check.txt](../evidence/cpu-40-pty-20261009-122044/ps-check.txt#L1-L3) · [코드·출력 해석](linked-file-commentary.md#해설-18). 

**화면 해설:** `Peak reached` 뒤 `Starting cooldown`이 부하를 낮추는 전환이며, `Cooldown complete (5.00%)`는 냉각 후 재상승을 시작한 로그입니다. ps의 `ELAPSED 55`는 해당 프로세스 경과 시간이고 PID2359가 남아 있습니다. `%CPU 1.4`는 누적 평균으로 top 구간 최대40.0%와 다를 수 있습니다. `RSS 479420`도 그 시각의 메모리이며 top12:21:06 화면과 측정 시각이 다릅니다.

## 8. Deadlock: 살아 있지만 진행하지 않는 상태 설명하기

**열 화면:** [Deadlock 보고서](../reports/03-deadlock.md) · [코드·출력 해석](linked-file-commentary.md#해설-19) → [true 스냅샷1](../evidence/deadlock-true-20261009-125943/snapshot-1.txt) · [코드·출력 해석](linked-file-commentary.md#해설-20) → [스냅샷2](../evidence/deadlock-true-20261009-125943/snapshot-2.txt) · [코드·출력 해석](linked-file-commentary.md#해설-21) → [대기 로그](../evidence/deadlock-true-20261009-125943/app.log) · [코드·출력 해석](linked-file-commentary.md#해설-22).

**발표할 말**

> 메모리512와 CPU40은 유지하고 동시 트랜잭션 설정을true로 켰습니다. 프로세스는 살아 있었지만 두 시점의 RSS가18512KiB, 로그 크기가2792바이트로 그대로였습니다. 스레드들은 동기화 대기를 보였습니다.
>
> 앱 로그에서는 첫 번째 워커가 Shared_Memory_A를 보유한 채 Socket_Pool_B를 기다렸고, 두 번째 워커는 B를 보유한 채 A를 기다렸습니다. 서로 상대가 가진 자원을 기다리는 순환 관계였습니다.
>
> 그래서 PID 존재, 진행 정체, 자원 보유와 요청 로그를 함께 근거로 교착상태를 진단했습니다.

**왜 스냅샷을 두 번 찍었는가**

한 번의 수면 상태는 정상 대기일 수 있습니다. 시간 간격을 둔 두 기록에서 CPU 시간·RSS·로그 크기·수정 시각을 비교해야 정체를 판단할 근거가 생깁니다. 스냅샷 안의 명령들은 순서대로 실행되므로 완전히 동일한 순간의 원자적 측정은 아닙니다.

**각 출력의 의미**

- ps -ef: 프로세스와 부모 관계, 당시 존재 여부.
- ps -L: 한 프로세스의 스레드별 상태.
- TID: 스레드 식별자. 로그의 워커 이름과 개별 TID의 정확한 대응은 확인하지 못했습니다.
- TIME: 누적 CPU 시간. 실제 벽시계 경과 시간과 다릅니다.
- WCHAN의 futex_do_wait: 커널 동기화 대기 위치. 이 값만으로 교착 확정은 어렵습니다.
- stat의 log_bytes와 modified: 파일 크기와 수정 시각. 로그가 더 기록되는지 비교하는 자료.
- 같은 PID의 스레드 행에 반복된 RSS: 공유 주소 공간의 값이므로 행마다 더하지 않습니다.

**교착상태 네 조건을 설명하는 말**

> 상호 배제는 자원을 한 작업만 소유하는 조건입니다. 점유 대기는 하나를 가진 채 다른 자원을 기다리는 것입니다. 비선점은 대기자가 다른 작업의 락을 강제 회수하지 못하는 조건입니다. 순환 대기는 서로의 자원을 기다리는 고리입니다.
>
> 이번에는 A와B의 보유 로그, 보유 상태의 추가 요청, 서로 반대인 대기 관계를 확인했습니다. 비선점은 대기 중 회수 로그가 없는 관측과 일반적인 락 모델로 해석했으며 내부 락 구현까지 확인한 것은 아닙니다.

**변경 후 열 화면:** [false 스냅샷1](../evidence/deadlock-false-20261009-130309/snapshot-1.txt) · [코드·출력 해석](linked-file-commentary.md#해설-23), [스냅샷2](../evidence/deadlock-false-20261009-130309/snapshot-2.txt) · [코드·출력 해석](linked-file-commentary.md#해설-24).

**발표할 말**

> 동시 설정만false로 바꾸자10초 간격 비교에서 로그가3474에서3870바이트로396바이트 증가했고 작업 로그가 진행했습니다. 관측 구간에서 해당 교착 경로가 회피됐다고 판단했습니다.
>
> false에서도 스레드3개와 메인 스레드의 대기는 남았습니다. 설정false를 프로그램 전체의 단일 스레드 전환으로 해석하지 않고, 작업 진행을 근거로 회피를 확인했습니다.

**예상 질문: 근본적으로 어떻게 수정하겠나요?**

모든 경로에서 A다음B처럼 락 획득 순서를 통일하는 방안을 제안합니다. 중첩 락 축소, 타임아웃과 롤백, 예외 시 해제 보장도 검토할 수 있습니다. 실제 구현 수정과 검증은 소스 접근이 가능한 별도 작업입니다.


### 출력 화면 8-1. true 첫 관측: PID와 스레드 대기

**2026-10-09 실제 기록 발췌 — 입력할 명령이 아닙니다.**

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

원본: [snapshot-1.txt](../evidence/deadlock-true-20261009-125943/snapshot-1.txt#L1-L9) · [코드·출력 해석](linked-file-commentary.md#해설-20). 


### 출력 화면 8-2. true 10초 후 재관측

**2026-10-09 실제 기록 발췌 — 입력할 명령이 아닙니다.**

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

원본: [snapshot-2.txt](../evidence/deadlock-true-20261009-125943/snapshot-2.txt#L1-L9) · [코드·출력 해석](linked-file-commentary.md#해설-21). 

**화면 해설:** 같은 PID9226과 세TID가 존재합니다. 두 화면의RSS18512, 로그크기2792, 수정시각이 같습니다. CPU0.3→0.1은 ps의 누적 평균 변화일 수 있으며, 이를 작업 재개로 해석하지 않습니다. `SNl+`의 `l`은 멀티스레드, `+`는 터미널 전경 프로세스 그룹에 속한다는 뜻입니다.

### 출력 화면 8-3. 서로의 자원을 기다리는 마지막 로그

**2026-10-09 실제 기록 발췌 — 입력할 명령이 아닙니다.**

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

원본: [snapshot-1.txt](../evidence/deadlock-true-20261009-125943/snapshot-1.txt#L22-L29) · [코드·출력 해석](linked-file-commentary.md#해설-20). 

**화면 해설:** T1이A를 보유하고 T2가B를 보유한 뒤 T2는A, T1은B를 기다립니다. `Holding`은 보유 상태, `WAITING`과`BLOCKED`는 추가 자원을 기다리는 상태라는 앱의 설명입니다. 스레드 대기 위치만으로 단정하지 않고 이 자원 관계를 함께 읽습니다.

### 출력 화면 8-4. false 첫 관측: 같은 형식으로 비교

**2026-10-09 실제 기록 발췌 — 입력할 명령이 아닙니다.**

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

원본: [snapshot-1.txt](../evidence/deadlock-false-20261009-130309/snapshot-1.txt#L1-L9) · [코드·출력 해석](linked-file-commentary.md#해설-23). 


### 출력 화면 8-5. false 10초 후 재관측

**2026-10-09 실제 기록 발췌 — 입력할 명령이 아닙니다.**

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

원본: [snapshot-2.txt](../evidence/deadlock-false-20261009-130309/snapshot-2.txt#L1-L9) · [코드·출력 해석](linked-file-commentary.md#해설-24). 

**화면 해설:** 로그3474→3870바이트, RSS121000→197812KiB로 달라집니다. 메인 스레드는futex대기지만 워커는poll대기이며 작업 로그도 진행합니다. 여러 값이 바뀐다는 사실만으로 정상이라고 단정하지 않고 작업 진행 로그와 함께 회피를 확인했습니다. 같은 PID의RSS를 세 행만큼 더하지 않습니다.

## 9. 종료 코드와 정리: 자동 종료와 수동 종료 구분하기

**열 화면:** [CPU40 정리 로그](../evidence/cpu-40-pty-20261009-122044/cleanup.log) · [코드·출력 해석](linked-file-commentary.md#해설-25), [Deadlock true 정리 로그](../evidence/deadlock-true-20261009-125943/cleanup.log) · [코드·출력 해석](linked-file-commentary.md#해설-26), 각 폴더의 exit-code.txt와 종료 후 ps.

**발표할 말**

> 종료 코드는 보조 증거로 사용했습니다. Bash 규칙상137은128+9로 SIGKILL 해석과 일치하고143은128+15로 SIGTERM 해석과 일치합니다. 하지만 이 숫자만으로 누가 종료했는지는 알 수 없습니다.
>
> OOM은 MemoryGuard 로그, CPU Before는 Watchdog 로그, 수동 정리한 실행은 cleanup.log를 함께 확인했습니다. 특히 Deadlock은 스스로 종료된 장애가 아니라 살아 있는 채 정체된 상태였으며 증거 수집 후 제가 종료한 것으로 구분했습니다.

**출력이 제목뿐인 이유**

정리 후 ps가 제목만 출력한 것은 당시 조회 조건에 맞는 프로세스 행이 없었기 때문입니다. 조회 PID와 오류 여부가 맞는지 확인한 다음 정리 결과로 설명합니다. top이나 monitor의 Done은 관제 도구의 종료 알림일 수 있으므로 앱의 종료와 구분합니다.

**용어 설명**

시그널은 프로세스에 전달하는 알림·요청입니다. SIGTERM은 종료 요청, SIGKILL은 강제 종료 시그널입니다. 종료 코드137이 커널 OOM 발생의 단독 증거는 아닙니다.


### 출력 화면 9-1. OOM128 종료 상태 파일

**2026-10-09 실제 기록 발췌 — 입력할 명령이 아닙니다.**

```text
137
```

원본: [exit-code.txt](../evidence/oom-128-20261009-113259/exit-code.txt#L1-L1) · [코드·출력 해석](linked-file-commentary.md#해설-27). 


### 출력 화면 9-2. CPU80 PTY 종료 상태 파일

**2026-10-09 실제 기록 발췌 — 입력할 명령이 아닙니다.**

```text
143
```

원본: [exit-code.txt](../evidence/cpu-80-pty-20261009-115744/exit-code.txt#L1-L1) · [코드·출력 해석](linked-file-commentary.md#해설-28). 


### 출력 화면 9-3. CPU40 실험자의 정리 기록

**2026-10-09 실제 기록 발췌 — 입력할 명령이 아닙니다.**

```text
2026-10-09T12:46:44+09:00 manual SIGTERM PID=2358
2026-10-09T12:46:44+09:00 manual SIGTERM PID=2359
```

원본: [cleanup.log](../evidence/cpu-40-pty-20261009-122044/cleanup.log#L1-L2) · [코드·출력 해석](linked-file-commentary.md#해설-25). 


### 출력 화면 9-4. 정리 후 ps에는 제목만 남음

**2026-10-09 실제 기록 발췌 — 입력할 명령이 아닙니다.**

```text
    PID    PPID ELAPSED %CPU %MEM   RSS NLWP STAT
```

원본: [ps-after-cleanup.txt](../evidence/cpu-40-pty-20261009-122044/ps-after-cleanup.txt#L1-L1) · [코드·출력 해석](linked-file-commentary.md#해설-29). 

**화면 해설:** 위137과143은 서로 다른 실행의 파일입니다. CPU40의 `manual SIGTERM`은 실험자가 정리를 위해 보낸 요청입니다. 정리 후 제목만 있는ps 출력은 조회 대상 행이 없다는 뜻입니다. 수동 정리 기록이12:46:44라고 해서 앞의55초 관측부터 그때까지 연속 안정성을 입증한 것으로 확대하지 않습니다.

## 10. 보고서와 분석 한계: 동료가 확인할 수 있게 정리하기

**열 화면:** [Issue 보고서 양식](../templates/issue-report-template.md) · [코드·출력 해석](linked-file-commentary.md#해설-30), 세 보고서의 원인 분석과 조치·검증 절.

**발표할 말**

> 보고서는 현상 설명, 증거와 로그, 원인 분석, 조치와 검증으로 구성했습니다. 실행 조건과 시각, PID, 설정 변경, 원본 링크를 남겨 다른 사람이 판단 과정을 다시 확인할 수 있게 했습니다.
>
> 관측한 사실과 추론은 구분했습니다. 메모리 증가와 보호 종료는 확인했지만 내부 코드의 누수 위치는 확인하지 않았습니다. CPU 과점유와 보호 동작은 확인했지만 실제 서비스 지연은 측정하지 않았습니다. 교착의 순환 대기와 회피는 확인했지만 모든 실행의 무한한 안정성을 보장한 것은 아닙니다.
>
> 선택 과제의 스케줄링도 앱 로그의 작업 순서를 근거로 FCFS와 유사하다고 추론했으며, Linux 커널의 CPU 스케줄러를 확정한 것은 아닙니다.

**이슈 등록과 문서 형식 구분**

이 저장소의 보고서는 GitHub Issue 형식의 Markdown 문서입니다. 별도의 Issues 등록 여부는 문서 형식과 구분해서 설명합니다.

**용어 설명**

근본 원인은 문제를 일으키는 원리, 임시 조치는 발생을 늦추거나 영향을 줄이는 대응, 검증은 조치 전후를 실제 자료로 비교하는 과정입니다. 한계는 자료로 확인하지 못한 범위입니다.

## 11. 마지막 정리 발언

**발표할 말**

> 이번 실습에서 자원 사용률 하나만으로 장애를 판단하면 안 된다는 점을 배웠습니다. 프로세스가 살아 있다는 것과 작업이 진행한다는 것도 구분해야 했습니다.
>
> 메모리 실험에서는 RSS 증가와 MemoryGuard 종료를 연결했고, 한도 상향이 생존 시간을 늘리지만 원인을 해결하지는 못한다는 점을 확인했습니다.
>
> CPU 실험에서는 측정 기준과 수집 구간을 구분하고 Watchdog 종료와 냉각 동작을 비교했습니다. 교착 실험에서는 자원 보유·요청 관계와 반복 스냅샷을 통해 순환 대기를 설명했습니다.
>
> 결과적으로 장애가 발생했을 때 실행 조건과 관제, 로그를 보존하고, 확인한 범위에 맞춰 원인과 조치 효과를 보고하는 방법을 연습했습니다.

이 발언은 본인이 실제로 이해하고 확인한 내용에 맞춰 사용합니다. AI의 도움을 받은 범위도 질문받으면 사실대로 설명합니다.

## 12. 바로 답할 수 있도록 연습할 핵심 질문

| 질문 | 답변의 핵심 |
|---|---|
| 왜 계정과 아키텍처부터 확인했나요? | 일반 사용자 조건과 실행 파일 호환성 확인 |
| env.sh를 만들면 설정이 바로 적용되나요? | 저장과 적용은 다름. 현재 셸에서 source 필요 |
| 왜 부모와 자식을 각각 관제했나요? | 실행기와 실제 작업의 자원 사용을 구분 |
| RSS와Heap이 다른 이유는요? | OS 상주량과 앱 내부 지표로 범위·시각이 다름 |
| 왜128/256을 사용했나요? | 한도 상향에 따른 생존 시간 비교, 다른 조건 고정 |
| 256으로 바꾸면 해결됐나요? | 생존 시간 증가 후 같은 종료. 임시 조치 |
| CPU80인데53%에서 종료된 이유는요? | 설정과 실제 내부 기준 대응은 미확인. 로그 관측 범위로 설명 |
| 왜top의 첫 프레임을 뺐나요? | 이후 갱신 구간과 측정 기준이 다름 |
| 143이면 모두Watchdog인가요? | 수동SIGTERM도 가능. 원인 로그와 정리 기록 대조 |
| CPU0%면Deadlock인가요? | 정상 대기도 가능. 순환 관계와 진행 정체를 함께 확인 |
| false인데 스레드3개인 이유는요? | 전체 단일 스레드 설정으로 확인되지 않음. 해당 실행 경로의 진행으로 판단 |
| 무엇을 추가 확인해야 하나요? | 소스의 메모리 보관/회수, 보호 기준, 락 구현, 서비스 지연 측정 등 |

모르는 질문에는 “이번 자료로는 확인하지 못했습니다. 확인한 근거는 여기까지이며 추가로 해당 자료가 필요합니다”라고 답합니다. 그 다음 어떤 파일이나 측정이 필요한지 구체적으로 말합니다.

## 13. 발표 자료를 읽은 뒤 직접 실습하는 순서

[통합 교안](complete-course.md) · [코드·출력 해석](linked-file-commentary.md#해설-08)의 제1부로 준비 이유와 출력을 읽고, 제2부의 실습 절차를 단계별로 진행합니다. 긴 문서 전체를 터미널에 한 번에 붙여넣지 않습니다. 입력할 명령만 실행하고 실제 출력과 질문을 [학습 기록 양식](../templates/learning-record-template.md) · [코드·출력 해석](linked-file-commentary.md#해설-31)에 적습니다.

새 실습은 새 폴더·시각·PID로 기록하며 이 대본의2026-10-09 수치를 새 결과로 복사하지 않습니다. 기존 원본과 새 결과가 다르면 그대로 남기고 조건과 관측 범위를 확인합니다. 학습을 시작할 때는 [함께 진행하는 방법](guided-learning.md) · [코드·출력 해석](linked-file-commentary.md#해설-32)을 따릅니다.
