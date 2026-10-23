# 증거 링크를 열었을 때 읽는 해설서

작성: 2026-10-23. 이 문서는 2026-10-09 원본 증거를 설명합니다. **해설에서 파일 이름을 클릭하면 원본이 열립니다. 브라우저 뒤로가기로 해설로 돌아옵니다.** 빈 파일도 수집 당시 내용이므로 채워 넣지 않았습니다. GitHub가 큰 로그를 접으면 Raw 또는 파일 보기를 사용합니다. 화면의 값은 입력할 명령이 아닙니다.

## 1. 파일이 만들어지는 이유와 읽는 순서

설정 → 앱 로그 → 관제 값 → 종료/정리 기록 순서로 읽습니다. 설정은 실행 조건이고 관제는 결과입니다. 서로 다른 실행 폴더의 PID·시각을 섞으면 잘못된 결론을 낼 수 있습니다. 파일명에 들어간 시각은 폴더를 만든 시각이며 앱 시작 시각과 반드시 같지는 않습니다.

### CSV는 왜 쉼표와 숫자로 보이는가

monitor.sh가 ps 출력을 awk로 변환해 CSV로 저장했기 때문입니다. 각 줄은 한 시점의 표본입니다.

| 열 | 뜻 | 해석할 때 주의할 점 |
|---|---|---|
| timestamp | 측정 시각 | +09:00은 한국 시간대이며 경과 시간이 아님 |
| pid / ppid | 대상 / 부모 번호 | 작은 RSS의 실행기와 작업 자식을 구분 |
| elapsed_s | 프로세스 경과 초 | 폴더 생성 이후 시간이 아님 |
| cpu_avg_pct | ps 누적 평균 CPU | top의 짧은 구간 최대와 다를 수 있음 |
| mem_pct | OS가 보는 물리 메모리 비율 | Windows PC Manager 비율이나 앱 한도 비율이 아님 |
| rss_kib | 상주 메모리, KiB | 1024로 나누면 MiB; 마지막 관측값이 순간 절대 최대는 아님 |
| threads | 스레드 수 | false 설정이라도 전체 스레드가 1개가 되는 것은 아님 |
| state | 프로세스 상태 | SN은 수면+낮은 우선순위; R은 실행/실행 가능 |

예를 들어 OOM128 CSV의 `962,954,17,0.8,1.8,146376,1,SN`은 PID962, 부모954, 경과17초, 누적 평균 CPU0.8%, 물리 메모리1.8%, RSS146376KiB, 스레드1개, 낮은 우선순위의 수면 상태라는 뜻입니다. CPU가 낮아도 메모리 장애는 발생할 수 있습니다.

### 로그와 시스템 출력은 왜 모양이 다른가

앱 로그는 앱이 출력한 시각·등급·모듈·문장이고, ps/top은 OS가 관측한 값입니다. `[CRITICAL]`은 로그 등급, `[MemoryGuard]`는 기록 주체 이름입니다. `>=`는 이상 비교입니다. 128MB 실험이 150MB에서 종료되는 것은 로그의 증가가 25MB 단위로 관측됐기 때문입니다.

top의 윗부분 load average는 시스템의 실행/일부 대기 부하 평균이며 퍼센트가 아닙니다. 아래 PID 행의 %CPU를 비교합니다. 첫 프레임은 이후 갱신 구간과 기준이 달라 최대 계산에서 제외했습니다. 짧은 표본의 50%와 앱 내부 53.11%가 다른 것은 곧 오류라는 뜻이 아닙니다.

ps 제목만 남으면 조회 조건에 맞는 프로세스 행이 없는 것입니다. 즉시 성공/실패로 단정하지 않고 조회한 PID와 시각을 확인합니다. `futex_do_wait`는 동기화 대기 위치입니다. 정상 대기도 가능하므로 로그의 자원 보유·요청과 반복 관측을 함께 읽습니다.

### 이 구성의 용어 설명

표본은 한 번의 측정, 관측 범위는 실제 기록한 시간 구간, 무결성은 원본 바이트의 보존입니다. 137은 SIGKILL과 일치하는 상태지만 커널 OOM의 단독 증거가 아니고, 143도 Watchdog와 수동 종료 둘 다에서 나올 수 있습니다. 종료 주체는 로그와 함께 판단합니다.

## 2. OOM 변경 전: 128MB

작업 PID 962. RSS 18,356→146,376KiB로 증가했습니다. 150MB >= 128MB와 Self-terminating 로그가 직접 종료 원인인 MemoryGuard를 설명합니다. 시작 로그부터 종료 요청까지 17.202초입니다.

### 원본 링크와 파일별 출력 해설

- [app.log](../evidence/oom-128-20261009-113259/app.log): 앱의 부팅·작업·보호 로그입니다. PTY 실행이면 script 시작/종료 표지도 포함됩니다. 설정 확인 뒤 마지막 핵심 문장을 읽고 관제 시각과 대조합니다.

- [exit-code.txt](../evidence/oom-128-20261009-113259/exit-code.txt): wait 직후 저장한 종료 상태입니다. 137/143을 앱 로그·cleanup.log와 대조해 원인과 정리를 구분합니다. 숫자만으로 종료 주체를 알 수 없습니다.

- [launcher.pid](../evidence/oom-128-20261009-113259/launcher.pid): 백그라운드로 시작한 실행기의 $! 값입니다. 실제 작업 자식 번호와 다를 수 있으므로 PPID로 연결합니다.

- [monitor-954.csv](../evidence/oom-128-20261009-113259/monitor-954.csv): ps의 시계열 CSV입니다. 위 CSV 열 해설을 보며 RSS·CPU·상태의 시간 변화를 읽습니다. PID가 실행기인지 작업 자식인지 PPID와 함께 확인합니다.

- [monitor-954.log](../evidence/oom-128-20261009-113259/monitor-954.log): 관제기의 표준 오류·종료 알림입니다. Monitoring ended는 대상 행이 없거나 좀비를 제외해 관제를 끝냈다는 뜻입니다. 정확한 종료 원인은 앱 로그가 설명합니다.

- [monitor-962.csv](../evidence/oom-128-20261009-113259/monitor-962.csv): ps의 시계열 CSV입니다. 위 CSV 열 해설을 보며 RSS·CPU·상태의 시간 변화를 읽습니다. PID가 실행기인지 작업 자식인지 PPID와 함께 확인합니다.

- [monitor-962.log](../evidence/oom-128-20261009-113259/monitor-962.log): 관제기의 표준 오류·종료 알림입니다. Monitoring ended는 대상 행이 없거나 좀비를 제외해 관제를 끝냈다는 뜻입니다. 정확한 종료 원인은 앱 로그가 설명합니다.

- [ps-check.txt](../evidence/oom-128-20261009-113259/ps-check.txt): 종료 또는 생존 확인 시점의 ps 결과입니다. 헤더뿐이면 그 조회에 맞는 행이 없다는 뜻이며 로그와 결합해 판단합니다.

- [ps-start.txt](../evidence/oom-128-20261009-113259/ps-start.txt): 앱 시작 직후 ps 스냅샷입니다. PID/PPID 관계와 RSS를 확인합니다. 경과0초의 CPU 평균은 짧은 초기 구간 값이라 지속 과점유로 단정하지 않습니다.

- [settings.txt](../evidence/oom-128-20261009-113259/settings.txt): 실행 전에 저장한 환경변수입니다. 세 값 중 비교 대상 하나만 달라졌는지 읽습니다. 실제 적용은 부팅 로그와 대조합니다.

- [started_at.txt](../evidence/oom-128-20261009-113259/started_at.txt): 실행 명령 직전에 기록한 시각입니다. 부팅 완료 시각과 차이가 있으므로 보고서의 생존 시간은 지정한 시작 로그를 기준으로 계산합니다.

### 이 구성의 용어 설명

MemoryGuard는 앱 메모리 보호 정책, RSS는 상주량, 생존 시간은 지정한 두 로그 시각의 차이입니다.

## 3. OOM 변경 후: 256MB

작업 PID 1156. RSS 18,476→274,516KiB로 증가했습니다. 275MB >= 256MB에서 같은 보호 정책으로 종료됐습니다. 32.363초로 15.161초 늘었지만 메모리 증가 자체는 해결되지 않았습니다.

### 원본 링크와 파일별 출력 해설

- [app.log](../evidence/oom-256-20261009-113740/app.log): 앱의 부팅·작업·보호 로그입니다. PTY 실행이면 script 시작/종료 표지도 포함됩니다. 설정 확인 뒤 마지막 핵심 문장을 읽고 관제 시각과 대조합니다.

- [exit-code.txt](../evidence/oom-256-20261009-113740/exit-code.txt): wait 직후 저장한 종료 상태입니다. 137/143을 앱 로그·cleanup.log와 대조해 원인과 정리를 구분합니다. 숫자만으로 종료 주체를 알 수 없습니다.

- [launcher.pid](../evidence/oom-256-20261009-113740/launcher.pid): 백그라운드로 시작한 실행기의 $! 값입니다. 실제 작업 자식 번호와 다를 수 있으므로 PPID로 연결합니다.

- [monitor-1148.csv](../evidence/oom-256-20261009-113740/monitor-1148.csv): ps의 시계열 CSV입니다. 위 CSV 열 해설을 보며 RSS·CPU·상태의 시간 변화를 읽습니다. PID가 실행기인지 작업 자식인지 PPID와 함께 확인합니다.

- [monitor-1148.log](../evidence/oom-256-20261009-113740/monitor-1148.log): 관제기의 표준 오류·종료 알림입니다. Monitoring ended는 대상 행이 없거나 좀비를 제외해 관제를 끝냈다는 뜻입니다. 정확한 종료 원인은 앱 로그가 설명합니다.

- [monitor-1156.csv](../evidence/oom-256-20261009-113740/monitor-1156.csv): ps의 시계열 CSV입니다. 위 CSV 열 해설을 보며 RSS·CPU·상태의 시간 변화를 읽습니다. PID가 실행기인지 작업 자식인지 PPID와 함께 확인합니다.

- [monitor-1156.log](../evidence/oom-256-20261009-113740/monitor-1156.log): 관제기의 표준 오류·종료 알림입니다. Monitoring ended는 대상 행이 없거나 좀비를 제외해 관제를 끝냈다는 뜻입니다. 정확한 종료 원인은 앱 로그가 설명합니다.

- [ps-check.txt](../evidence/oom-256-20261009-113740/ps-check.txt): 종료 또는 생존 확인 시점의 ps 결과입니다. 헤더뿐이면 그 조회에 맞는 행이 없다는 뜻이며 로그와 결합해 판단합니다.

- [settings.txt](../evidence/oom-256-20261009-113740/settings.txt): 실행 전에 저장한 환경변수입니다. 세 값 중 비교 대상 하나만 달라졌는지 읽습니다. 실제 적용은 부팅 로그와 대조합니다.

- [started_at.txt](../evidence/oom-256-20261009-113740/started_at.txt): 실행 명령 직전에 기록한 시각입니다. 부팅 완료 시각과 차이가 있으므로 보고서의 생존 시간은 지정한 시작 로그를 기준으로 계산합니다.

### 이 구성의 용어 설명

MemoryGuard는 앱 메모리 보호 정책, RSS는 상주량, 생존 시간은 지정한 두 로그 시각의 차이입니다.

## 4. CPU 최초 수집: 관제 한계 확인

비교의 주 근거로 삼기 어려운 최초 실행입니다. 1초 top의 30프레임은 종료 전 약 5초를 놓쳤습니다. 관측 최대 4%만 보고 CPU 문제가 없었다고 결론내릴 수 없습니다. 아래 PTY 실행으로 증거를 보완했습니다.

### 원본 링크와 파일별 출력 해설

- [app.log](../evidence/cpu-80-20261009-114729/app.log): 앱의 부팅·작업·보호 로그입니다. PTY 실행이면 script 시작/종료 표지도 포함됩니다. 설정 확인 뒤 마지막 핵심 문장을 읽고 관제 시각과 대조합니다.

- [exit-code.txt](../evidence/cpu-80-20261009-114729/exit-code.txt): wait 직후 저장한 종료 상태입니다. 137/143을 앱 로그·cleanup.log와 대조해 원인과 정리를 구분합니다. 숫자만으로 종료 주체를 알 수 없습니다.

- [launcher.pid](../evidence/cpu-80-20261009-114729/launcher.pid): 백그라운드로 시작한 실행기의 $! 값입니다. 실제 작업 자식 번호와 다를 수 있으므로 PPID로 연결합니다.

- [monitor-1522.csv](../evidence/cpu-80-20261009-114729/monitor-1522.csv): ps의 시계열 CSV입니다. 위 CSV 열 해설을 보며 RSS·CPU·상태의 시간 변화를 읽습니다. PID가 실행기인지 작업 자식인지 PPID와 함께 확인합니다.

- [monitor-1522.log](../evidence/cpu-80-20261009-114729/monitor-1522.log): 관제기의 표준 오류·종료 알림입니다. Monitoring ended는 대상 행이 없거나 좀비를 제외해 관제를 끝냈다는 뜻입니다. 정확한 종료 원인은 앱 로그가 설명합니다.

- [monitor-1530.csv](../evidence/cpu-80-20261009-114729/monitor-1530.csv): ps의 시계열 CSV입니다. 위 CSV 열 해설을 보며 RSS·CPU·상태의 시간 변화를 읽습니다. PID가 실행기인지 작업 자식인지 PPID와 함께 확인합니다.

- [monitor-1530.log](../evidence/cpu-80-20261009-114729/monitor-1530.log): 관제기의 표준 오류·종료 알림입니다. Monitoring ended는 대상 행이 없거나 좀비를 제외해 관제를 끝냈다는 뜻입니다. 정확한 종료 원인은 앱 로그가 설명합니다.

- [ps-check.txt](../evidence/cpu-80-20261009-114729/ps-check.txt): 종료 또는 생존 확인 시점의 ps 결과입니다. 헤더뿐이면 그 조회에 맞는 행이 없다는 뜻이며 로그와 결합해 판단합니다.

- [settings.txt](../evidence/cpu-80-20261009-114729/settings.txt): 실행 전에 저장한 환경변수입니다. 세 값 중 비교 대상 하나만 달라졌는지 읽습니다. 실제 적용은 부팅 로그와 대조합니다.

- [started_at.txt](../evidence/cpu-80-20261009-114729/started_at.txt): 실행 명령 직전에 기록한 시각입니다. 부팅 완료 시각과 차이가 있으므로 보고서의 생존 시간은 지정한 시작 로그를 기준으로 계산합니다.

- [top-error.log](../evidence/cpu-80-20261009-114729/top-error.log): top의 표준 오류입니다. 빈 파일은 그 경로로 기록된 오류 문장이 없다는 뜻이며 관제 기간의 충분함까지 보장하지 않습니다. **이 원본은 0바이트입니다.**

- [top.log](../evidence/cpu-80-20261009-114729/top.log): 반복한 top 화면입니다. 시각 범위와 PID별 %CPU를 읽습니다. 최초 프레임을 제외하며, 마지막 관제 이후 상태는 이 파일만으로 판단하지 않습니다.

### 이 구성의 용어 설명

Watchdog는 보호 감시, PTY는 가상 터미널, 구간 최대는 기록된 표본 중 최대이며 무한 시간의 최대가 아닙니다.

## 5. CPU 변경 전: 80 설정

작업 PID 1921. top 최대 50.0%, 앱 내부 Current Load 53.11%와 WATCHDOG/SIGTERM 로그가 있습니다. 서로 다른 시간 범위·계산 기준의 지표입니다. 80 설정을 OS의 정확한 종료 임계치로 단정할 수 없습니다.

### 원본 링크와 파일별 출력 해설

- [app.log](../evidence/cpu-80-pty-20261009-115744/app.log): 앱의 부팅·작업·보호 로그입니다. PTY 실행이면 script 시작/종료 표지도 포함됩니다. 설정 확인 뒤 마지막 핵심 문장을 읽고 관제 시각과 대조합니다.

- [console.log](../evidence/cpu-80-pty-20261009-115744/console.log): script 명령의 표준 출력과 오류를 셸 리다이렉션으로 기록한 파일입니다. app.log와 겹치는 내용이 있어도 독립된 두 번의 재현은 아닙니다.

- [exit-code.txt](../evidence/cpu-80-pty-20261009-115744/exit-code.txt): wait 직후 저장한 종료 상태입니다. 137/143을 앱 로그·cleanup.log와 대조해 원인과 정리를 구분합니다. 숫자만으로 종료 주체를 알 수 없습니다.

- [monitor-1920.csv](../evidence/cpu-80-pty-20261009-115744/monitor-1920.csv): ps의 시계열 CSV입니다. 위 CSV 열 해설을 보며 RSS·CPU·상태의 시간 변화를 읽습니다. PID가 실행기인지 작업 자식인지 PPID와 함께 확인합니다.

- [monitor-1920.log](../evidence/cpu-80-pty-20261009-115744/monitor-1920.log): 관제기의 표준 오류·종료 알림입니다. Monitoring ended는 대상 행이 없거나 좀비를 제외해 관제를 끝냈다는 뜻입니다. 정확한 종료 원인은 앱 로그가 설명합니다.

- [monitor-1921.csv](../evidence/cpu-80-pty-20261009-115744/monitor-1921.csv): ps의 시계열 CSV입니다. 위 CSV 열 해설을 보며 RSS·CPU·상태의 시간 변화를 읽습니다. PID가 실행기인지 작업 자식인지 PPID와 함께 확인합니다.

- [monitor-1921.log](../evidence/cpu-80-pty-20261009-115744/monitor-1921.log): 관제기의 표준 오류·종료 알림입니다. Monitoring ended는 대상 행이 없거나 좀비를 제외해 관제를 끝냈다는 뜻입니다. 정확한 종료 원인은 앱 로그가 설명합니다.

- [observed-pids.txt](../evidence/cpu-80-pty-20261009-115744/observed-pids.txt): 관제 대상으로 발견한 앱 PID 목록입니다. 현재 프로세스가 살아 있다는 증거가 아니라 당시 대상 목록입니다.

- [ps-check.txt](../evidence/cpu-80-pty-20261009-115744/ps-check.txt): 종료 또는 생존 확인 시점의 ps 결과입니다. 헤더뿐이면 그 조회에 맞는 행이 없다는 뜻이며 로그와 결합해 판단합니다.

- [ps-start.txt](../evidence/cpu-80-pty-20261009-115744/ps-start.txt): 앱 시작 직후 ps 스냅샷입니다. PID/PPID 관계와 RSS를 확인합니다. 경과0초의 CPU 평균은 짧은 초기 구간 값이라 지속 과점유로 단정하지 않습니다.

- [session.pid](../evidence/cpu-80-pty-20261009-115744/session.pid): script 기록 세션의 PID입니다. 앱 작업 프로세스의 메모리 사용량과 직접 대응시키지 않습니다.

- [settings.txt](../evidence/cpu-80-pty-20261009-115744/settings.txt): 실행 전에 저장한 환경변수입니다. 세 값 중 비교 대상 하나만 달라졌는지 읽습니다. 실제 적용은 부팅 로그와 대조합니다.

- [started_at.txt](../evidence/cpu-80-pty-20261009-115744/started_at.txt): 실행 명령 직전에 기록한 시각입니다. 부팅 완료 시각과 차이가 있으므로 보고서의 생존 시간은 지정한 시작 로그를 기준으로 계산합니다.

- [top-error.log](../evidence/cpu-80-pty-20261009-115744/top-error.log): top의 표준 오류입니다. 빈 파일은 그 경로로 기록된 오류 문장이 없다는 뜻이며 관제 기간의 충분함까지 보장하지 않습니다. **이 원본은 0바이트입니다.**

- [top.log](../evidence/cpu-80-pty-20261009-115744/top.log): 반복한 top 화면입니다. 시각 범위와 PID별 %CPU를 읽습니다. 최초 프레임을 제외하며, 마지막 관제 이후 상태는 이 파일만으로 판단하지 않습니다.

### 이 구성의 용어 설명

Watchdog는 보호 감시, PTY는 가상 터미널, 구간 최대는 기록된 표본 중 최대이며 무한 시간의 최대가 아닙니다.

## 6. CPU 변경 후: 40 설정

작업 PID 2359. top 최대 40.0%와 앱 냉각 동작을 관찰했습니다. 55초 확인 시 PID와 로그 진행이 유지됐습니다. 최종 143은 수동 정리와 함께 읽습니다. 전체 서비스 지연 개선을 측정한 실험은 아닙니다.

### 원본 링크와 파일별 출력 해설

- [app.log](../evidence/cpu-40-pty-20261009-122044/app.log): 앱의 부팅·작업·보호 로그입니다. PTY 실행이면 script 시작/종료 표지도 포함됩니다. 설정 확인 뒤 마지막 핵심 문장을 읽고 관제 시각과 대조합니다.

- [cleanup.log](../evidence/cpu-40-pty-20261009-122044/cleanup.log): 실험자가 보낸 manual SIGTERM과 시각·PID 기록입니다. 종료 코드143을 장애 자동 종료로 오해하지 않도록 수집했습니다.

- [console.log](../evidence/cpu-40-pty-20261009-122044/console.log): script 명령의 표준 출력과 오류를 셸 리다이렉션으로 기록한 파일입니다. app.log와 겹치는 내용이 있어도 독립된 두 번의 재현은 아닙니다.

- [exit-code.txt](../evidence/cpu-40-pty-20261009-122044/exit-code.txt): wait 직후 저장한 종료 상태입니다. 137/143을 앱 로그·cleanup.log와 대조해 원인과 정리를 구분합니다. 숫자만으로 종료 주체를 알 수 없습니다.

- [monitor-2358.csv](../evidence/cpu-40-pty-20261009-122044/monitor-2358.csv): ps의 시계열 CSV입니다. 위 CSV 열 해설을 보며 RSS·CPU·상태의 시간 변화를 읽습니다. PID가 실행기인지 작업 자식인지 PPID와 함께 확인합니다.

- [monitor-2358.log](../evidence/cpu-40-pty-20261009-122044/monitor-2358.log): 관제기의 표준 오류·종료 알림입니다. Monitoring ended는 대상 행이 없거나 좀비를 제외해 관제를 끝냈다는 뜻입니다. 정확한 종료 원인은 앱 로그가 설명합니다.

- [monitor-2359.csv](../evidence/cpu-40-pty-20261009-122044/monitor-2359.csv): ps의 시계열 CSV입니다. 위 CSV 열 해설을 보며 RSS·CPU·상태의 시간 변화를 읽습니다. PID가 실행기인지 작업 자식인지 PPID와 함께 확인합니다.

- [monitor-2359.log](../evidence/cpu-40-pty-20261009-122044/monitor-2359.log): 관제기의 표준 오류·종료 알림입니다. Monitoring ended는 대상 행이 없거나 좀비를 제외해 관제를 끝냈다는 뜻입니다. 정확한 종료 원인은 앱 로그가 설명합니다.

- [observed-pids.txt](../evidence/cpu-40-pty-20261009-122044/observed-pids.txt): 관제 대상으로 발견한 앱 PID 목록입니다. 현재 프로세스가 살아 있다는 증거가 아니라 당시 대상 목록입니다.

- [observed_at.txt](../evidence/cpu-40-pty-20261009-122044/observed_at.txt): 확인 명령을 실행한 시각입니다. 앱 마지막 로그 시각과 달라도 기록 오류가 아니라 확인이 늦었을 수 있습니다.

- [ps-after-cleanup.txt](../evidence/cpu-40-pty-20261009-122044/ps-after-cleanup.txt): 수동 종료 후 ps 결과입니다. 헤더만 남는 것은 당시 대상 프로세스가 조회되지 않았다는 정리 확인입니다.

- [ps-check.txt](../evidence/cpu-40-pty-20261009-122044/ps-check.txt): 종료 또는 생존 확인 시점의 ps 결과입니다. 헤더뿐이면 그 조회에 맞는 행이 없다는 뜻이며 로그와 결합해 판단합니다.

- [ps-start.txt](../evidence/cpu-40-pty-20261009-122044/ps-start.txt): 앱 시작 직후 ps 스냅샷입니다. PID/PPID 관계와 RSS를 확인합니다. 경과0초의 CPU 평균은 짧은 초기 구간 값이라 지속 과점유로 단정하지 않습니다.

- [session.pid](../evidence/cpu-40-pty-20261009-122044/session.pid): script 기록 세션의 PID입니다. 앱 작업 프로세스의 메모리 사용량과 직접 대응시키지 않습니다.

- [settings.txt](../evidence/cpu-40-pty-20261009-122044/settings.txt): 실행 전에 저장한 환경변수입니다. 세 값 중 비교 대상 하나만 달라졌는지 읽습니다. 실제 적용은 부팅 로그와 대조합니다.

- [started_at.txt](../evidence/cpu-40-pty-20261009-122044/started_at.txt): 실행 명령 직전에 기록한 시각입니다. 부팅 완료 시각과 차이가 있으므로 보고서의 생존 시간은 지정한 시작 로그를 기준으로 계산합니다.

- [top-error.log](../evidence/cpu-40-pty-20261009-122044/top-error.log): top의 표준 오류입니다. 빈 파일은 그 경로로 기록된 오류 문장이 없다는 뜻이며 관제 기간의 충분함까지 보장하지 않습니다. **이 원본은 0바이트입니다.**

- [top.log](../evidence/cpu-40-pty-20261009-122044/top.log): 반복한 top 화면입니다. 시각 범위와 PID별 %CPU를 읽습니다. 최초 프레임을 제외하며, 마지막 관제 이후 상태는 이 파일만으로 판단하지 않습니다.

### 이 구성의 용어 설명

Watchdog는 보호 감시, PTY는 가상 터미널, 구간 최대는 기록된 표본 중 최대이며 무한 시간의 최대가 아닙니다.

## 7. Deadlock 변경 전: true

작업 PID 9226. 두 스냅샷에서 RSS 18,512KiB, 로그 2,792바이트가 유지됐습니다. T1은 A를 가진 채 B를, T2는 B를 가진 채 A를 기다리는 로그가 순환 대기를 보여줍니다. 살아 있으나 작업이 정체된 상태입니다.

### 원본 링크와 파일별 출력 해설

- [app.log](../evidence/deadlock-true-20261009-125943/app.log): 앱의 부팅·작업·보호 로그입니다. PTY 실행이면 script 시작/종료 표지도 포함됩니다. 설정 확인 뒤 마지막 핵심 문장을 읽고 관제 시각과 대조합니다.

- [cleanup.log](../evidence/deadlock-true-20261009-125943/cleanup.log): 실험자가 보낸 manual SIGTERM과 시각·PID 기록입니다. 종료 코드143을 장애 자동 종료로 오해하지 않도록 수집했습니다.

- [console.log](../evidence/deadlock-true-20261009-125943/console.log): script 명령의 표준 출력과 오류를 셸 리다이렉션으로 기록한 파일입니다. app.log와 겹치는 내용이 있어도 독립된 두 번의 재현은 아닙니다.

- [exit-code.txt](../evidence/deadlock-true-20261009-125943/exit-code.txt): wait 직후 저장한 종료 상태입니다. 137/143을 앱 로그·cleanup.log와 대조해 원인과 정리를 구분합니다. 숫자만으로 종료 주체를 알 수 없습니다.

- [monitor-9225.csv](../evidence/deadlock-true-20261009-125943/monitor-9225.csv): ps의 시계열 CSV입니다. 위 CSV 열 해설을 보며 RSS·CPU·상태의 시간 변화를 읽습니다. PID가 실행기인지 작업 자식인지 PPID와 함께 확인합니다.

- [monitor-9225.log](../evidence/deadlock-true-20261009-125943/monitor-9225.log): 관제기의 표준 오류·종료 알림입니다. Monitoring ended는 대상 행이 없거나 좀비를 제외해 관제를 끝냈다는 뜻입니다. 정확한 종료 원인은 앱 로그가 설명합니다.

- [monitor-9226.csv](../evidence/deadlock-true-20261009-125943/monitor-9226.csv): ps의 시계열 CSV입니다. 위 CSV 열 해설을 보며 RSS·CPU·상태의 시간 변화를 읽습니다. PID가 실행기인지 작업 자식인지 PPID와 함께 확인합니다.

- [monitor-9226.log](../evidence/deadlock-true-20261009-125943/monitor-9226.log): 관제기의 표준 오류·종료 알림입니다. Monitoring ended는 대상 행이 없거나 좀비를 제외해 관제를 끝냈다는 뜻입니다. 정확한 종료 원인은 앱 로그가 설명합니다.

- [observed-pids.txt](../evidence/deadlock-true-20261009-125943/observed-pids.txt): 관제 대상으로 발견한 앱 PID 목록입니다. 현재 프로세스가 살아 있다는 증거가 아니라 당시 대상 목록입니다.

- [ps-after-cleanup.txt](../evidence/deadlock-true-20261009-125943/ps-after-cleanup.txt): 수동 종료 후 ps 결과입니다. 헤더만 남는 것은 당시 대상 프로세스가 조회되지 않았다는 정리 확인입니다.

- [session.pid](../evidence/deadlock-true-20261009-125943/session.pid): script 기록 세션의 PID입니다. 앱 작업 프로세스의 메모리 사용량과 직접 대응시키지 않습니다.

- [settings.txt](../evidence/deadlock-true-20261009-125943/settings.txt): 실행 전에 저장한 환경변수입니다. 세 값 중 비교 대상 하나만 달라졌는지 읽습니다. 실제 적용은 부팅 로그와 대조합니다.

- [snapshot-1.txt](../evidence/deadlock-true-20261009-125943/snapshot-1.txt): 같은 명령 묶음으로 찍은 상태 사진입니다. ps -ef의 존재, ps -L의 TID·TIME·WCHAN, stat의 로그 바이트·수정 시각, 마지막 앱 문장을 읽습니다. 두 스냅샷의 차이와 로그의 락 관계로 정체/진행을 판단합니다.

- [snapshot-2.txt](../evidence/deadlock-true-20261009-125943/snapshot-2.txt): 같은 명령 묶음으로 찍은 상태 사진입니다. ps -ef의 존재, ps -L의 TID·TIME·WCHAN, stat의 로그 바이트·수정 시각, 마지막 앱 문장을 읽습니다. 두 스냅샷의 차이와 로그의 락 관계로 정체/진행을 판단합니다.

- [started_at.txt](../evidence/deadlock-true-20261009-125943/started_at.txt): 실행 명령 직전에 기록한 시각입니다. 부팅 완료 시각과 차이가 있으므로 보고서의 생존 시간은 지정한 시작 로그를 기준으로 계산합니다.

- [worker.pid](../evidence/deadlock-true-20261009-125943/worker.pid): 실행 당시 수집한 보조 기록입니다. 파일의 명령·시각·대상을 확인하고 같은 폴더의 설정 및 앱 로그와 대조합니다.

### 이 구성의 용어 설명

BLOCKED는 앱 로그의 대기 표현, 락은 공유 자원 접근 제어, 순환 대기는 서로의 자원을 기다리는 고리입니다.

## 8. Deadlock 변경 후: false

작업 PID 11294. 10초 간격 두 스냅샷에서 RSS 121,000→197,812KiB, 로그 3,474→3,870바이트로 변했고 작업 로그도 진행했습니다. 관측 구간에서 교착 경로가 회피됐다는 뜻입니다. 스레드 3개가 남는 것은 false가 전체 단일 스레드 설정이라는 뜻이 아니기 때문입니다.

### 원본 링크와 파일별 출력 해설

- [app.log](../evidence/deadlock-false-20261009-130309/app.log): 앱의 부팅·작업·보호 로그입니다. PTY 실행이면 script 시작/종료 표지도 포함됩니다. 설정 확인 뒤 마지막 핵심 문장을 읽고 관제 시각과 대조합니다.

- [cleanup.log](../evidence/deadlock-false-20261009-130309/cleanup.log): 실험자가 보낸 manual SIGTERM과 시각·PID 기록입니다. 종료 코드143을 장애 자동 종료로 오해하지 않도록 수집했습니다.

- [console.log](../evidence/deadlock-false-20261009-130309/console.log): script 명령의 표준 출력과 오류를 셸 리다이렉션으로 기록한 파일입니다. app.log와 겹치는 내용이 있어도 독립된 두 번의 재현은 아닙니다.

- [exit-code.txt](../evidence/deadlock-false-20261009-130309/exit-code.txt): wait 직후 저장한 종료 상태입니다. 137/143을 앱 로그·cleanup.log와 대조해 원인과 정리를 구분합니다. 숫자만으로 종료 주체를 알 수 없습니다.

- [monitor-11293.csv](../evidence/deadlock-false-20261009-130309/monitor-11293.csv): ps의 시계열 CSV입니다. 위 CSV 열 해설을 보며 RSS·CPU·상태의 시간 변화를 읽습니다. PID가 실행기인지 작업 자식인지 PPID와 함께 확인합니다.

- [monitor-11293.log](../evidence/deadlock-false-20261009-130309/monitor-11293.log): 관제기의 표준 오류·종료 알림입니다. Monitoring ended는 대상 행이 없거나 좀비를 제외해 관제를 끝냈다는 뜻입니다. 정확한 종료 원인은 앱 로그가 설명합니다.

- [monitor-11294.csv](../evidence/deadlock-false-20261009-130309/monitor-11294.csv): ps의 시계열 CSV입니다. 위 CSV 열 해설을 보며 RSS·CPU·상태의 시간 변화를 읽습니다. PID가 실행기인지 작업 자식인지 PPID와 함께 확인합니다.

- [monitor-11294.log](../evidence/deadlock-false-20261009-130309/monitor-11294.log): 관제기의 표준 오류·종료 알림입니다. Monitoring ended는 대상 행이 없거나 좀비를 제외해 관제를 끝냈다는 뜻입니다. 정확한 종료 원인은 앱 로그가 설명합니다.

- [observed-pids.txt](../evidence/deadlock-false-20261009-130309/observed-pids.txt): 관제 대상으로 발견한 앱 PID 목록입니다. 현재 프로세스가 살아 있다는 증거가 아니라 당시 대상 목록입니다.

- [ps-after-cleanup.txt](../evidence/deadlock-false-20261009-130309/ps-after-cleanup.txt): 수동 종료 후 ps 결과입니다. 헤더만 남는 것은 당시 대상 프로세스가 조회되지 않았다는 정리 확인입니다.

- [session.pid](../evidence/deadlock-false-20261009-130309/session.pid): script 기록 세션의 PID입니다. 앱 작업 프로세스의 메모리 사용량과 직접 대응시키지 않습니다.

- [settings.txt](../evidence/deadlock-false-20261009-130309/settings.txt): 실행 전에 저장한 환경변수입니다. 세 값 중 비교 대상 하나만 달라졌는지 읽습니다. 실제 적용은 부팅 로그와 대조합니다.

- [snapshot-1.txt](../evidence/deadlock-false-20261009-130309/snapshot-1.txt): 같은 명령 묶음으로 찍은 상태 사진입니다. ps -ef의 존재, ps -L의 TID·TIME·WCHAN, stat의 로그 바이트·수정 시각, 마지막 앱 문장을 읽습니다. 두 스냅샷의 차이와 로그의 락 관계로 정체/진행을 판단합니다.

- [snapshot-2.txt](../evidence/deadlock-false-20261009-130309/snapshot-2.txt): 같은 명령 묶음으로 찍은 상태 사진입니다. ps -ef의 존재, ps -L의 TID·TIME·WCHAN, stat의 로그 바이트·수정 시각, 마지막 앱 문장을 읽습니다. 두 스냅샷의 차이와 로그의 락 관계로 정체/진행을 판단합니다.

- [started_at.txt](../evidence/deadlock-false-20261009-130309/started_at.txt): 실행 명령 직전에 기록한 시각입니다. 부팅 완료 시각과 차이가 있으므로 보고서의 생존 시간은 지정한 시작 로그를 기준으로 계산합니다.

- [worker.pid](../evidence/deadlock-false-20261009-130309/worker.pid): 실행 당시 수집한 보조 기록입니다. 파일의 명령·시각·대상을 확인하고 같은 폴더의 설정 및 앱 로그와 대조합니다.

### 이 구성의 용어 설명

BLOCKED는 앱 로그의 대기 표현, 락은 공유 자원 접근 제어, 순환 대기는 서로의 자원을 기다리는 고리입니다.

## 9. 그래프·환경·검증 파일 해설

- [메모리 그래프](../figures/oom-rss.svg): 가로축은 경과 시간, 세로축은 RSS입니다. 선이 끝난 위치는 관측 종료이며 커널 OOM을 표시한 선이 아닙니다. 메모리 한도는 앱 내부 기준과 구분합니다.
- [CPU 그래프](../figures/cpu-interval.svg): top의 구간별 프로세스 CPU를 보여줍니다. 80과 40은 실행 설정 이름이며 전체 노트북 CPU 사용률이 아닙니다.
- [교착 비교 그래프](../figures/deadlock-comparison.svg): 두 시점의 로그·메모리 변화 비교입니다. false에서 값이 증가해도 그 자체로 누수라는 뜻은 아니며 작업 진행 로그와 함께 읽습니다.
- [환경 정보](../evidence/environment.txt): uname은 커널, id는 계정, os-release는 배포판, nproc는 사용 가능한 처리기 수, free는 메모리 상태를 기록한 것입니다. free의 buff/cache는 모두 즉시 회수 불가능한 누수 메모리가 아닙니다.
- [무결성 목록](../evidence/SHA256SUMS): SHA-256 값과 파일 경로 쌍입니다. 같은 바이트인지 비교하는 자료이며 기술적 결론의 옳고 그름을 판정하는 값은 아닙니다.
- [측정 요약 JSON](measurements.json): 원본에서 정리한 구조화 데이터입니다. 중괄호는 객체, 대괄호는 목록이며 키 옆 값의 단위를 확인합니다. 새로운 실행 로그가 아닙니다.

평가에서는 원본을 연 뒤 “무엇을 수집했다 → 왜 이런 형식인가 → 어떤 값이 어떻게 바뀌었다 → 어느 로그와 연결된다 → 무엇은 미확인이다” 순서로 설명합니다.
