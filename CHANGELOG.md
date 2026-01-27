# CHANGELOG

이 파일은 프로젝트 변경 이력을 기록합니다. 다음 작업 시 AI가 이전 컨텍스트를 파악하는 데 활용됩니다.

---

## 2026-01-27

### 작업 내용
- README.md를 현재 프로젝트 구조에 맞게 업데이트
- CLAUDE.md 파일 생성
- CHANGELOG.md 파일 생성

### 변경된 파일
- `README.md`: 구조, 사용법, 명령어 설명 최신화
  - `custom/` 디렉토리 제거
  - `.claude/skills/claude-code-init/` 추가
  - 명령어 변경: `/sync` → `/claude-code-pull`, `/backup` → `/claude-code-commit`
  - 초기 설정 방식 변경: `./init.sh` → `/claude-code-init` 스킬
- `CLAUDE.md`: 신규 생성
  - 프로젝트 개요 및 아키텍처
  - 주요 명령어 및 디렉토리 역할
  - Registry 파일 형식
  - 작업 가이드라인 (변경 이력 기록, 문서 동기화)
- `CHANGELOG.md`: 신규 생성