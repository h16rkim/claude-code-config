# CHANGELOG

이 파일은 프로젝트 변경 이력을 기록합니다. 다음 작업 시 AI가 이전 컨텍스트를 파악하는 데 활용됩니다.

---

## 2026-01-31

### 작업 내용
- `claude-code-reset` 스킬 신규 생성
- 모든 동기화 명령어에 `rules/` 디렉토리 지원 추가

### 변경된 파일
- `.claude/skills/claude-code-reset/SKILL.md`: 신규 생성
  - 기존 설정 완전 삭제 후 Registry 기준 재설치 기능
  - git pull로 Repository 최신 상태 동기화
- `.claude/skills/claude-code-reset/reset.sh`: 신규 생성
  - Phase 0: Git Pull
  - Phase 1: Plugin/Marketplace/MCP 삭제
  - Phase 2: Symlink 생성
  - Phase 3: Registry 기반 재설치
- `.claude/skills/claude-code-init/init.sh`: `rules/` 디렉토리 백업 및 symlink 추가
- `.claude/skills/claude-code-init/SKILL.md`: `rules/` 예시 추가
- `config/commands/claude-code-commit.md`: `rules/` 백업 섹션 추가
- `config/commands/claude-code-pull.md`: `rules/` 백업 및 symlink 추가
- `README.md`: claude-code-reset 및 rules/ 디렉토리 설명 추가

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