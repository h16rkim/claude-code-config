---
allowed-tools: Bash, Read, Write, Edit
---

# Claude Code 설정 백업

로컬 Claude Code 설정을 Repository에 백업합니다.

## 백업 순서

다음 순서대로 백업을 진행해주세요:

### Step 1: 프로젝트 경로 탐지

1. `~/.claude/commands` 심볼릭 링크에서 프로젝트 경로를 찾습니다:
   ```bash
   CONFIG_DIR="$(dirname "$(readlink "$HOME/.claude/commands")")"
   echo "프로젝트 경로: $CONFIG_DIR"
   ```

2. 프로젝트 경로가 유효한지 확인:
   ```bash
   ls -la "$CONFIG_DIR/config/settings.json"
   ```
   파일이 없으면 "claude-code-config 프로젝트를 찾을 수 없습니다. init.sh를 먼저 실행해주세요."라고 알려주세요.

3. Git 상태 확인:
   ```bash
   cd "$CONFIG_DIR" && git status
   ```

### Step 2: 설정 파일 백업

1. **settings.json 백업**

   `~/.claude/settings.json` 파일을 읽습니다.
   - 심볼릭 링크인 경우: 실제 파일 내용을 읽습니다
   - 로컬 전용 필드(`feedbackSurveyState` 등)는 제거합니다
   - `statusLine.command`의 절대 경로를 `$HOME` 형식으로 변환합니다

   변환된 내용을 `$CONFIG_DIR/config/settings.json`에 저장합니다.

2. **CLAUDE.md 백업**

   `~/.claude/CLAUDE.md` 파일을 `$CONFIG_DIR/config/CLAUDE.md`에 복사합니다.

### Step 3: Commands 백업

`~/.claude/commands/` 디렉토리의 내용을 `$CONFIG_DIR/commands/`에 동기화합니다.

**참고**: 심볼릭 링크로 연결되어 있으면 이미 동기화되어 있습니다. 심볼릭 링크가 아닌 경우에만 파일을 복사합니다.

1. 심볼릭 링크 여부 확인:
   ```bash
   if [ -L "$HOME/.claude/commands" ]; then
     echo "commands/는 이미 심볼릭 링크로 연결되어 있습니다."
   else
     # 파일 동기화 필요
     ls -la ~/.claude/commands/
   fi
   ```

2. 심볼릭 링크가 아닌 경우:
   - 로컬에 있는 새 명령어 파일 추가
   - 변경된 파일 업데이트
   - `sync.md`, `backup.md`는 덮어쓰지 않음 (이 repository의 핵심 파일)

### Step 4: MCP 서버 목록 추출

1. 현재 설치된 MCP 서버 목록 조회:
   ```bash
   claude mcp list
   ```

2. 각 서버의 설정 확인:
   ```bash
   claude mcp get <server_name>
   ```

3. `$CONFIG_DIR/registry/mcp-servers.json` 파일을 업데이트합니다.

   형식:
   ```json
   {
     "servers": [
       {
         "name": "서버이름",
         "scope": "user",
         "config": { ... }
       }
     ]
   }
   ```

### Step 5: Marketplace 목록 추출

1. `~/.claude/plugins/known_marketplaces.json` 파일을 읽습니다.

2. 각 marketplace의 정보를 추출하여 `$CONFIG_DIR/registry/marketplaces.json`을 업데이트합니다.

   형식:
   ```json
   {
     "marketplaces": [
       {
         "name": "marketplace이름",
         "source": "github",
         "repo": "owner/repo"
       },
       {
         "name": "marketplace이름2",
         "source": "git",
         "url": "https://github.com/..."
       }
     ]
   }
   ```

### Step 6: Plugin 목록 추출

1. `~/.claude/plugins/installed_plugins.json` 파일을 읽습니다.

2. `~/.claude/settings.json`의 `enabledPlugins` 필드를 확인합니다.

3. 각 plugin의 활성화 상태를 포함하여 `$CONFIG_DIR/registry/plugins.json`을 업데이트합니다.

   형식:
   ```json
   {
     "plugins": [
       {
         "name": "plugin이름",
         "marketplace": "marketplace이름",
         "enabled": true
       }
     ]
   }
   ```

### Step 7: 변경사항 확인

1. 프로젝트 디렉토리로 이동하여 Git diff로 변경사항 표시:
   ```bash
   cd "$CONFIG_DIR" && git diff
   ```

2. 변경사항을 사용자에게 요약하여 보여줍니다:
   - 프로젝트 경로
   - 수정된 설정 파일
   - 추가/변경된 commands
   - 업데이트된 registry 파일들

3. 커밋 여부를 사용자에게 질문합니다.
   - 커밋을 원하면 프로젝트 디렉토리에서 `/commit` 명령어 사용을 권장합니다.
   - 또는 직접 커밋:
     ```bash
     cd "$CONFIG_DIR" && git add . && git commit -m "Update claude code config"
     ```

## 주의사항

- 민감한 정보(API 키, 토큰 등)가 포함되지 않도록 주의합니다
- `feedbackSurveyState` 같은 로컬 전용 필드는 백업에서 제외합니다
- 심볼릭 링크인 경우 이미 동기화되어 있으므로 별도 복사가 필요 없습니다
