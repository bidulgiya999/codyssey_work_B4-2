# plus_2026_11_10: 2026-11-10 실습 결과

이번 과제의 후속 작업 위치는 **plus_2026_11_10/**입니다. 기존10월9일 실험과 구분해 이번 여섯 실행의 원본과 보고서를 관리합니다. 사용자가Ubuntu에서 직접 실행했고, 관제 코드·분석·보고서 정리에Codex의 도움을 받았습니다.

## 평가 준비와 보고서

[발표 메모·OOM 모의평가 질문16개](evaluation-qa.md) · [메모장용 텍스트 다운로드](evaluation-qa.txt)

발표문 아래에 답변·선택 이유·쉬운 설명·원본 참조 위치를 붙였습니다. 메모장용 파일은 다운로드한 뒤 열어 필요한 표현을 수정할 수 있습니다.

먼저 [평가 때 화면을 보며 설명하는 순서](assessment-quick-guide.md)를 열어두세요. 열 파일, 화면에서 가리킬 부분, 실제 설명 문장과 질문 답변을 연결했습니다. 이후 각 보고서의 표와 원본 링크를 함께 확인합니다.

1. [OOM 보고서](reports/01-oom.md): 한도128→256MB, 생존17.185→32.355초. 15.170초 연장 후 같은MemoryGuard 종료가 반복됐습니다.
2. [CPU 보고서](reports/02-cpu.md): 설정80→40, 냉각·86초 시점 생존을 확인했습니다. **top 최대50→70%를 실측대로 기록**했습니다.
3. [Deadlock 보고서](reports/03-deadlock.md): true에서 순환 대기·정체, false에서10초 사이 로그661바이트 증가와 작업 진행을 확인했습니다.

모든 보고서는 현상·증거/재현·원인 분석·조치/검증의4개 필수 절로 구성했습니다. 각 보고서 끝에는 평가용 설명 문장이 있습니다. 원본 링크는 이 폴더 내부 증거를 가리킵니다.

## 구성

```text
plus_2026_11_10/
  README.md
  assessment-quick-guide.md   평가 설명 순서와 예상 질문
  reports/                   보고서3건
  evidence/                  여섯 실행의 원본98개 파일
  scripts/                   당시env.sh와monitor.sh
  templates/                 Issue작성 양식
  measurements.json          원본에서 재계산한 수치
  environment-at-backup.txt  백업 시점 환경
  run-directories.txt        Ubuntu 원본 경로
  SHA256SUMS                 파일 무결성 목록
```

## 출처와 검증

원본 백업은Windows의Downloads/agent-app-leak/results-practice-20261110-201641-S1mFK3입니다. evidence/와scripts/는 해당 백업의 바이트를 복사하고SHA-256으로 대조했습니다. [측정 요약](measurements.json)은CSV·top·로그·스냅샷을 읽어 재계산한 파생 자료입니다.

env.sh는 초기128/100/false 설정입니다. 실행별 실제 설정은 각settings.txt와 앱 부팅 로그로 확인합니다. environment-at-backup.txt는20:16:42의 환경이며 장애 발생 순간의RAM 수치가 아닙니다. 원본에는 명령 전체 입력 기록이 없어 보고서의 재현 코드는 사용한 구문의 요약으로 표시했습니다.

## 발표 순서

과제 목적 → 실행 환경/관제 방법 → OOM → CPU → Deadlock → 조치 효과와 한계 순서로 설명합니다. 각 장애는 현상 → 증거 → 원인 판단 → 조치 → 검증 순서를 유지합니다. 관측하지 않은 내부 구현이나 성능 개선을 확정하지 않습니다.
