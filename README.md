# Claude Code Config

여러 머신에서 Claude Code 설정을 동기화하기 위한 프로젝트입니다.

## 구조

```
claude-code-config/
├── .claude/
│   └── skills/
│       ├── claude-code-init/    # 초기화 스킬
│       │   ├── SKILL.md
│       │   └── init.sh
│       └── claude-code-reset/   # 리셋 스킬
│           ├── SKILL.md
│           └── reset.sh
│
├── config/                      # 설정 파일 및 디렉토리 (symlink 대상)
│   ├── settings.json            # Claude Code 메인 설정
│   ├── CLAUDE.md                # 전역 사용자 지침
│   ├── commands/                # 슬래시 명령어
│   │   ├── claude-code-pull.md    # /claude-code-pull - 설정 동기화
│   │   ├── claude-code-commit.md  # /claude-code-commit - 설정 백업
│   │   └── ...                    # 기타 명령어
│   ├── skills/                  # 사용자 정의 스킬
│   └── rules/                   # 규칙 파일
│
└── registry/                    # 확장 목록
    ├── mcp-servers.json         # MCP 서버 목록
    ├── marketplaces.json        # Marketplace 목록
    └── plugins.json             # Plugin 목록
```

## 사용법

### 새 머신에서 최초 설정

```bash
# 1. Repository 클론
git clone <repository-url> ~/develop/private/claude-code-config

# 2. 프로젝트 디렉토리에서 Claude Code 실행 후 초기화 스킬 실행
cd ~/develop/private/claude-code-config
claude
# Claude Code 내에서:
/claude-code-init
```

`/claude-code-init` 스킬은 다음 작업을 수행합니다:
- 로컬 설정을 프로젝트에 백업
- 심볼릭 링크 생성 (settings.json, CLAUDE.md, commands/, skills/, rules/)
- MCP 서버, Marketplace, Plugin 설치

### 설정 완전 초기화 (Reset)

기존 설정을 모두 삭제하고 Repository 기준으로 재설치합니다.

```bash
# 프로젝트 디렉토리에서 Claude Code 실행 후 리셋 스킬 실행
cd ~/develop/private/claude-code-config
claude
# Claude Code 내에서:
/claude-code-reset
```

`/claude-code-reset` 스킬은 다음 작업을 수행합니다:
- Repository를 최신 상태로 동기화 (git pull)
- 기존 Plugin, Marketplace, MCP 서버 전부 삭제
- 심볼릭 링크 재생성
- Registry 기준으로 MCP 서버, Marketplace, Plugin 재설치

### 설정 동기화 (Repository → 로컬)

**어디서든 실행 가능합니다.** 프로젝트 경로는 심볼릭 링크를 통해 자동으로 탐지됩니다.

```bash
# Claude Code에서 /claude-code-pull 실행 (어느 디렉토리에서든 가능)
```

### 설정 백업 (로컬 → Repository)

**어디서든 실행 가능합니다.**

```bash
# 1. Claude Code에서 /claude-code-commit 실행 (어느 디렉토리에서든 가능)
#    - 설정 파일들을 Repository에 백업
#    - 변경사항 확인 후 커밋 여부 질문

# 2. 필요시 수동으로 푸시
cd ~/develop/private/claude-code-config
git push
```

## 관리되는 설정

- **settings.json**: 환경변수, 권한, 훅, 플러그인 설정
- **CLAUDE.md**: 전역 사용자 지침
- **commands/**: 커스텀 슬래시 명령어
- **skills/**: 사용자 정의 스킬
- **rules/**: 규칙 파일
- **MCP 서버**: `registry/mcp-servers.json`에서 관리
- **Marketplace**: `registry/marketplaces.json`에서 관리
- **Plugin**: `registry/plugins.json`에서 관리

## 슬래시 명령어

| 명령어 | 설명 |
|--------|------|
| `/claude-code-init` | 새 머신에서 초기 설정 (프로젝트 디렉토리에서 실행) |
| `/claude-code-reset` | 설정 완전 초기화 후 Registry 기준 재설치 (프로젝트 디렉토리에서 실행) |
| `/claude-code-pull` | Repository 설정을 로컬에 동기화 |
| `/claude-code-commit` | 로컬 설정을 Repository에 백업 |
