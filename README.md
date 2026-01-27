# Claude Code Config

여러 머신에서 Claude Code 설정을 동기화하기 위한 프로젝트입니다.

## 구조

```
claude-code-config/
├── config/                 # 핵심 설정 파일
│   ├── settings.json       # Claude Code 메인 설정
│   └── CLAUDE.md           # 전역 사용자 지침
│
├── commands/               # 슬래시 명령어
│   ├── sync.md             # /sync - 설정 동기화
│   ├── backup.md           # /backup - 설정 백업
│   └── ...                 # 기타 명령어
│
├── custom/                 # 커스텀 스크립트
│   └── scripts/
│
├── registry/               # 확장 목록
│   ├── mcp-servers.json    # MCP 서버 목록
│   ├── marketplaces.json   # Marketplace 목록
│   └── plugins.json        # Plugin 목록
│
└── init.sh                 # 초기 설정 스크립트
```

## 사용법

### 새 머신에서 최초 설정

```bash
# 1. Repository 클론
git clone <repository-url> ~/develop/private/claude-code-config

# 2. 초기 설정 실행
cd ~/develop/private/claude-code-config
./init.sh
```

### 설정 동기화 (Repository → 로컬)

**어디서든 실행 가능합니다.** 프로젝트 경로는 자동으로 탐지됩니다.

```bash
# Claude Code에서 /sync 실행 (어느 디렉토리에서든 가능)
```

### 설정 백업 (로컬 → Repository)

**어디서든 실행 가능합니다.**

```bash
# 1. Claude Code에서 /backup 실행 (어느 디렉토리에서든 가능)

# 2. 변경사항 커밋 및 푸시 (프로젝트 디렉토리에서)
cd ~/develop/private/claude-code-config
git add . && git commit -m "Update claude code config" && git push
```

## 관리되는 설정

- **settings.json**: 환경변수, 권한, 훅, 플러그인 설정
- **CLAUDE.md**: 전역 사용자 지침
- **commands/**: 커스텀 슬래시 명령어
- **MCP 서버**: `registry/mcp-servers.json`에서 관리
- **Marketplace**: `registry/marketplaces.json`에서 관리
- **Plugin**: `registry/plugins.json`에서 관리
