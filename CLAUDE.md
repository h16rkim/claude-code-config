# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 프로젝트 개요

여러 머신에서 Claude Code 설정을 동기화하기 위한 설정 관리 프로젝트입니다. 코드 프로젝트가 아닌 설정 파일과 스킬/명령어 모음입니다.

## 아키텍처

```
~/.claude/                          이 프로젝트
├── settings.json  ─── symlink ───► config/settings.json
├── CLAUDE.md      ─── symlink ───► config/CLAUDE.md
├── commands/      ─── symlink ───► commands/
└── skills/        ─── symlink ───► skills/
```

심볼릭 링크를 통해 `~/.claude/` 설정이 이 프로젝트와 연결되어, Git으로 버전 관리 및 동기화가 가능합니다.

## 주요 명령어

| 명령어 | 실행 위치 | 설명 |
|--------|-----------|------|
| `/claude-code-init` | 이 프로젝트 디렉토리 | 새 머신 초기 설정 |
| `/claude-code-pull` | 어디서든 | Repository → 로컬 동기화 |
| `/claude-code-commit` | 어디서든 | 로컬 → Repository 백업 |

## 디렉토리 역할

- **`.claude/skills/claude-code-init/`**: 프로젝트 로컬 스킬. init.sh로 심볼릭 링크 생성 및 확장 설치
- **`commands/`**: 전역 슬래시 명령어. `~/.claude/commands`로 심볼릭 링크됨
- **`skills/`**: 전역 사용자 정의 스킬. `~/.claude/skills`로 심볼릭 링크됨
- **`config/`**: settings.json, CLAUDE.md 저장
- **`registry/`**: MCP 서버, Marketplace, Plugin 목록 (JSON 형식)

## Registry 파일 형식

### mcp-servers.json
```json
{
  "servers": [
    { "name": "서버명", "scope": "user", "config": { "type": "stdio", "command": "...", "args": [...] } }
  ]
}
```

### marketplaces.json
```json
{
  "marketplaces": [
    { "name": "이름", "source": "github", "repo": "owner/repo" }
  ]
}
```

### plugins.json
```json
{
  "plugins": [
    { "name": "플러그인명", "marketplace": "마켓이름", "enabled": true }
  ]
}
```

## 작업 가이드라인

### 변경 이력 기록
작업 완료 후 `CHANGELOG.md` 파일에 수정 내용을 기록합니다. 이 기록은 다음 작업 시 AI가 이전 컨텍스트를 파악하는 데 활용됩니다.

기록 형식:
```markdown
## YYYY-MM-DD

### 작업 내용
- 변경/추가/삭제한 내용 요약

### 변경된 파일
- 파일 경로 및 변경 사항
```

### 문서 동기화
작업 완료 후 프로젝트 구조나 명령어 등이 변경되었다면, `README.md`가 최신 상태와 일치하는지 확인하고 필요시 업데이트합니다.

확인 항목:
- 디렉토리 구조 변경
- 명령어 추가/수정/삭제
- 사용법 변경
- Registry 파일 형식 변경