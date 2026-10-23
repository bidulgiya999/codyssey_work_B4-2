# codyssey_work_B4-2

제공된 Linux 프로그램을 실제 실행해 **OOM Crash, CPU Latency, Deadlock**을 관측하고, 로그와 시스템 도구의 출력을 근거로 분석한 운영 장애 실습 기록입니다.

실험일은 **2026-10-09, KST(UTC+09:00)**입니다. 실행 환경은 **Ubuntu 26.04.1 LTS / WSL2 / x86_64**, 일반 사용자 `jae0608`(UID 1000)입니다. 바이너리의 디컴파일이나 리버스 엔지니어링은 수행하지 않았습니다.

## 학습과 평가 준비

이 저장소의 과제는 **OOM·CPU·Deadlock 장애 분석**입니다. SSH·방화벽·계정·cron 구축 과제와 구분합니다.

1. [처음부터 끝까지 통합 교안](docs/complete-course.md): 단계별 목적·명령·출력 해설·해당 용어와 여섯 번의 비교 실습
2. [통합 교안 PDF](docs/complete-course.pdf): 인쇄·오프라인 학습용
3. [증거 링크별 출력 해설](docs/evidence-reading-guide.md): 원본 파일마다 수집 이유·읽는 방법·판단 한계
4. [용어집 107개](docs/glossary.md): 정의와 과제에서 쓰이는 의미
5. [처음부터 공부하는 단계별 교안](docs/study-guide.md): 명령의 목적, 출력 해석, 원인 판단, 단계별 설명 연습
6. [평가 질문 24개와 답변 근거](docs/evaluation-guide.md): 원본 증거와 연결한 설명, 잘못 단정하기 쉬운 내용
7. [직접 작성하는 학습·재현 기록 양식](templates/learning-record-template.md): 본인의 새 실행 결과와 이해도 기록

학습 문서는 2026-10-23에 추가했습니다. 아래 결과와 기존 보고서·PDF는 **2026-10-09 원본 실험** 기준입니다. 새 교안 게시만으로 재실습 완료나 학습자의 이해도를 뜻하지 않습니다. 기존 제출용 mission-report.pdf는 보존하고 학습용 complete-course.pdf를 별도로 추가했습니다.

## 읽는 순서

1. [명령어·옵션·출력 해석 상세 기록](docs/command-guide.md)
2. [OOM Issue 보고서](reports/01-oom.md)
3. [CPU Issue 보고서](reports/02-cpu.md)
4. [Deadlock Issue 보고서](reports/03-deadlock.md)
5. [재사용할 Issue 마크다운 템플릿](templates/issue-report-template.md)
6. [제출용 통합 PDF](docs/mission-report.pdf)
7. [선택 과제: 응용 작업 스케줄러 분석](reports/04-scheduling-analysis.md)

## 검증 결과

| 장애 | 변경 변수 | Before | After |
|---|---|---|---|
| OOM | `MEMORY_LIMIT` 128 → 256 | 시작 로그부터 17.202초 후 MemoryGuard 종료 | 32.363초 후 동일 정책 종료; 약 15.161초 연장 |
| CPU | `CPU_MAX_OCCUPY` 80 → 40 | 0.1초 구간 CPU 최대 50.0%; WATCHDOG/SIGTERM 종료 | 같은 관제에서 최대 40.0%; 55초 시점 PID 유지 및 냉각 로그 |
| Deadlock | `MULTI_THREAD_ENABLE` true → false | PID 유지, 락 순환 대기, RSS·로그 정체 | 10초 간격 비교에서 로그·워커 작업 진행 |

OOM의 생존 시간은 `Agent listening` 로그에서 MemoryGuard 종료 요청 로그까지 계산했습니다. CPU 최대값은 `top`의 최초 프레임을 제외한 프로세스별 구간 관측값입니다. 앱의 `Current Load`와 시스템 도구의 CPU 측정값을 구분합니다. 응답 지연 자체를 측정하는 별도 벤치마크는 수행하지 않았습니다.

## 과제 요구사항 충족 자료

| 요구사항 | 자료 |
|---|---|
| OOM 메모리 상승 관제 | `evidence/oom-128-20261009-113259/monitor-962.csv`, `evidence/oom-256-20261009-113740/monitor-1156.csv` |
| OOM 종료 로그·최소 2회 비교 | 두 폴더의 `app.log`, `settings.txt`, `exit-code.txt` |
| CPU 급상승 구간 | `evidence/cpu-80-pty-20261009-115744/top.log`, CPU 그래프 |
| CPU Watchdog 종료·설정 비교 | CPU 80/40 PTY 폴더의 `app.log`·`settings.txt`·`top.log` |
| Deadlock PID 존재·스레드 정체 | true 폴더의 `snapshot-1.txt`, `snapshot-2.txt`, `monitor-9226.csv` |
| WAITING/BLOCKED·락 대기 근거 | true 폴더의 `app.log`와 Deadlock 보고서 |
| 멀티스레드 설정 변경 검증 | false 폴더의 두 스냅샷과 `settings.txt` |
| 재사용 가능한 보고서 구조 | `templates/issue-report-template.md` 및 `.github/ISSUE_TEMPLATE/bug_report.md` |

## 자료 구성

```text
reports/       장애 보고서 3건 + 선택 분석
docs/          명령어 상세 설명, 통합 PDF, 검증 수치
templates/     공통 Issue 마크다운 템플릿
figures/       원본 데이터에서 만든 벡터 그래프
scripts/       실제 사용한 env.sh와 monitor.sh
evidence/      7개 실행의 원본 로그·CSV·스냅샷, 환경 정보
.github/       GitHub Issue 작성 양식
```

관제 스크립트는 제공 다운로드에 포함되지 않아 `ps`를 이용해 직접 작성했습니다. 원본 증거 파일의 바이트는 그대로 보존했고 `evidence/SHA256SUMS`에 무결성 확인용 해시를 기록했습니다.

제공 실행 바이너리, `api_keys/secret.key` 및 업로드 파일은 저장소에 포함하지 않습니다. 재현할 때 바이너리는 과제 제공처에서 받아 `$HOME/jae-test/agent-leak-app`에 준비해야 합니다.

## 재현 설정

```bash
source scripts/env.sh
# 아래 값으로 해당 케이스를 선택하고, 먼저 관제를 준비한다.
export MEMORY_LIMIT=512
export CPU_MAX_OCCUPY=40
export MULTI_THREAD_ENABLE=false
```

`scripts/env.sh`는 초기 OOM 실험 설정인 `128 / 100 / false`입니다. `source` 후 케이스별 값을 명시적으로 덮어써야 합니다. 프로그램 실행은 일반 사용자로 수행합니다. 자세한 순서와 명령 해석은 [상세 기록](docs/command-guide.md)을 참고하세요.

## 결과를 해석할 때

- OOM은 앱의 MemoryGuard에 의한 보호 종료로 분석합니다. 종료 코드 137만으로 커널 OOM Killer를 단정하지 않습니다.
- CPU 40과 Deadlock false의 종료 코드 143은 `cleanup.log`에 기록된 **실험자 수동 종료**입니다.
- `MULTI_THREAD_ENABLE=false`에서도 정상 실행에서 스레드 3개가 관측됐습니다. 이 설정을 앱 전체의 단일 스레드 전환으로 해석하지 않습니다.
- CPU 40의 초기 메모리 상승 뒤 실제 `MEMORY RECOVERED` 로그와 메모리 감소가 관측됐습니다. 초기 상승만으로 이 정상 시나리오를 누수라고 단정하지 않습니다.

