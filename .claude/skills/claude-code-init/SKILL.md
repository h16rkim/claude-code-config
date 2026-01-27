---
allowed-tools: Bash, Read, Write, Edit
---

# claude-code-config-init

로컬 Claude Code 설정을 읽어서 이 프로젝트에 백업합니다. commands, skills 디렉토리와 registry JSON 파일들을 동기화한 후, init.sh를 실행합니다.

## 수행 작업

1. **Commands 복제**: `~/.claude/commands` 디렉토리의 파일들을 프로젝트의 `commands/` 디렉토리로 복제
2. **Skills 복제**: `~/.claude/skills` 디렉토리의 파일들을 프로젝트의 `skills/` 디렉토리로 복제
3. **MCP 서버 설정 읽기**: `~/.claude.json` 파일에서 MCP 서버 정보를 읽어 `registry/mcp-servers.json`에 저장
4. **Marketplace 설정 읽기**: `claude plugin marketplace list` 명령으로 marketplace 목록을 읽어 `registry/marketplaces.json`에 저장
5. **Plugin 설정 읽기**: `claude plugin list` 명령으로 설치된 플러그인 목록을 읽어 `registry/plugins.json`에 저장
6. **init.sh 실행**: 위 작업 완료 후 `./init.sh`를 실행하여 설정 적용

## Registry JSON 파일 형식

### registry/mcp-servers.json

MCP 서버 설정을 저장합니다. `~/.claude.json`의 `mcpServers` 섹션에서 변환합니다.

**소스 형식** (`~/.claude.json`):
```json
{
  "mcpServers": {
    "fetch": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "@anthropic/mcp-fetch-server"]
    },
    "filesystem": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "@anthropic/mcp-filesystem-server", "/path/to/dir"]
    }
  }
}
```

**대상 형식** (`registry/mcp-servers.json`):
```json
{
  "servers": [
    {
      "name": "fetch",
      "scope": "user",
      "config": {
        "type": "stdio",
        "command": "npx",
        "args": ["-y", "@anthropic/mcp-fetch-server"]
      }
    },
    {
      "name": "filesystem",
      "scope": "user",
      "config": {
        "type": "stdio",
        "command": "npx",
        "args": ["-y", "@anthropic/mcp-filesystem-server", "/path/to/dir"]
      }
    }
  ]
}
```

### registry/marketplaces.json

플러그인 마켓플레이스 목록을 저장합니다.

```json
{
  "marketplaces": [
    {
      "name": "claude-plugins-official",
      "source": "github",
      "repo": "anthropics/claude-plugins-official"
    },
    {
      "name": "my-marketplace",
      "source": "github",
      "repo": "username/repo-name"
    },
    {
      "name": "custom-marketplace",
      "source": "git",
      "url": "https://github.com/username/repo.git"
    }
  ]
}
```

**필드 설명:**
- `name`: 마켓플레이스 식별자
- `source`: `github` 또는 `git`
- `repo`: GitHub 저장소 (source가 github인 경우)
- `url`: Git URL (source가 git인 경우)

### registry/plugins.json

설치할 플러그인 목록을 저장합니다.

```json
{
  "plugins": [
    {
      "name": "typescript-language-server",
      "marketplace": "cc-lsp",
      "enabled": true
    },
    {
      "name": "claude-hud",
      "marketplace": "claude-hud",
      "enabled": true
    },
    {
      "name": "git-workflow",
      "marketplace": "inflab",
      "enabled": false
    }
  ]
}
```

**필드 설명:**
- `name`: 플러그인 이름
- `marketplace`: 플러그인이 속한 마켓플레이스 이름
- `enabled`: 활성화 여부 (true/false)

## 실행 지침

### Step 1: Commands 복제
1. `~/.claude/commands` 디렉토리가 존재하는지 확인합니다.
2. 디렉토리 내의 모든 `.md` 파일을 프로젝트의 `commands/` 디렉토리로 복사합니다.
3. 심볼릭 링크인 경우 실제 파일의 내용을 복사합니다.

### Step 2: Skills 복제
1. `~/.claude/skills` 디렉토리가 존재하는지 확인합니다.
2. 디렉토리 내의 모든 스킬 디렉토리를 프로젝트의 `skills/` 디렉토리로 복사합니다.
3. 심볼릭 링크인 경우 실제 파일의 내용을 복사합니다.

### Step 3: MCP 서버 설정 읽기
1. `~/.claude.json` 파일을 Read 도구로 읽습니다.
2. `mcpServers` 섹션을 추출하여 위의 대상 형식으로 변환합니다.
3. `registry/mcp-servers.json` 파일에 저장합니다.

### Step 4: Marketplace 목록 읽기
1. `claude plugin marketplace list` 명령을 실행합니다.
2. 출력을 파싱하여 marketplace 정보를 추출합니다.
3. `registry/marketplaces.json` 파일에 저장합니다.

### Step 5: Plugin 목록 읽기
1. `claude plugin list` 명령을 실행합니다.
2. 출력을 파싱하여 플러그인 정보를 추출합니다.
3. `registry/plugins.json` 파일에 저장합니다.

### Step 6: init.sh 실행
1. 위 단계가 모두 완료되면 루트 디렉토리의 `./init.sh`를 실행합니다.
2. 실행 결과를 사용자에게 보고합니다.

## 주의사항

- 이 스킬은 프로젝트 루트 디렉토리에서 실행되어야 합니다.
- 기존 registry 파일들은 덮어쓰게 됩니다.
