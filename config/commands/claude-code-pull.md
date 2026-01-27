---
allowed-tools: Bash, Read, Write, Edit
---

# Claude Code 설정 동기화

Repository의 설정을 로컬 환경에 적용합니다.

## 동기화 순서

다음 순서대로 동기화를 진행해주세요:

### Step 1: 프로젝트 경로 탐지

1. `~/.claude/commands` 심볼릭 링크에서 프로젝트 경로를 찾고 자주 사용되는 경로를 변수화합니다:
   ```bash
   PROJECT_DIR="$(dirname "$(dirname "$(readlink "$HOME/.claude/commands")")")"
   CONFIG_DIR="$PROJECT_DIR/config"
   REGISTRY_DIR="$PROJECT_DIR/registry"
   echo "프로젝트 경로: $PROJECT_DIR"
   ```

2. 프로젝트 경로가 유효한지 확인:
   ```bash
   ls -la "$CONFIG_DIR/settings.json"
   ```
   파일이 없으면 "claude-code-config 프로젝트를 찾을 수 없습니다. init.sh를 먼저 실행해주세요."라고 알려주세요.

3. 프로젝트 디렉토리로 이동하여 Git 상태 확인:
   ```bash
   cd "$PROJECT_DIR" && git status
   ```
   uncommitted changes가 있으면 사용자에게 알려주세요.

### Step 2: 최신 설정 가져오기 (선택)

사용자에게 `git pull`을 실행할지 확인합니다:
```bash
cd "$PROJECT_DIR" && git pull
```

### Step 3: 기존 설정 백업

1. 백업 디렉토리 생성 및 기존 설정 백업
   ```bash
   BACKUP_DIR="$HOME/.claude/backup/$(date +%Y%m%d_%H%M%S)"
   mkdir -p "$BACKUP_DIR"
   ```

2. 심볼릭 링크가 아닌 실제 파일/디렉토리만 백업
   ```bash
   # settings.json 백업 (심볼릭 링크가 아닌 경우)
   if [ -f "$HOME/.claude/settings.json" ] && [ ! -L "$HOME/.claude/settings.json" ]; then
     cp "$HOME/.claude/settings.json" "$BACKUP_DIR/"
   fi

   # CLAUDE.md 백업 (심볼릭 링크가 아닌 경우)
   if [ -f "$HOME/.claude/CLAUDE.md" ] && [ ! -L "$HOME/.claude/CLAUDE.md" ]; then
     cp "$HOME/.claude/CLAUDE.md" "$BACKUP_DIR/"
   fi

   # commands 디렉토리 백업 (심볼릭 링크가 아닌 경우)
   if [ -d "$HOME/.claude/commands" ] && [ ! -L "$HOME/.claude/commands" ]; then
     cp -r "$HOME/.claude/commands" "$BACKUP_DIR/"
   fi

   # skills 디렉토리 백업 (심볼릭 링크가 아닌 경우)
   if [ -d "$HOME/.claude/skills" ] && [ ! -L "$HOME/.claude/skills" ]; then
     cp -r "$HOME/.claude/skills" "$BACKUP_DIR/"
   fi
   ```

### Step 4: 설정 파일 동기화

1. 기존 심볼릭 링크 또는 파일 제거 후 새로 생성
   ```bash
   # settings.json
   rm -f "$HOME/.claude/settings.json"
   ln -s "$CONFIG_DIR/settings.json" "$HOME/.claude/settings.json"

   # CLAUDE.md
   rm -f "$HOME/.claude/CLAUDE.md"
   ln -s "$CONFIG_DIR/CLAUDE.md" "$HOME/.claude/CLAUDE.md"

   # commands/ (이미 심볼릭 링크로 연결되어 있음 - 확인만)

   # skills/
   rm -rf "$HOME/.claude/skills"
   ln -s "$PROJECT_DIR/skills" "$HOME/.claude/skills"
   ```

### Step 5: MCP 서버 동기화

1. `$REGISTRY_DIR/mcp-servers.json` 파일을 읽어 MCP 서버 목록을 확인합니다.

2. **registry에 없는 서버 삭제**: 현재 설치된 MCP 서버 중 registry에 명시되지 않은 서버를 삭제합니다.
   ```bash
   # 현재 설치된 서버 목록 조회
   claude mcp list

   # registry에 없는 서버 삭제
   claude mcp remove <name>
   ```

3. 각 서버에 대해 다음 명령을 실행합니다:
   ```bash
   # 기존 서버 제거 (이미 있는 경우)
   claude mcp remove <name>

   # 새로 추가
   claude mcp add-json --scope <scope> <name> '<config_json>'
   ```

4. 예시 (fetch 서버):
   ```bash
   claude mcp remove fetch
   claude mcp add-json --scope user fetch '{"type":"stdio","command":"npx","args":["-y","@h16rkim/mcp-fetch-server@latest"],"env":{"HTTP_PROXY":"http://127.0.0.1:3128","HTTPS_PROXY":"http://127.0.0.1:3128"}}'
   ```

### Step 6: Marketplace 동기화

1. `$REGISTRY_DIR/marketplaces.json` 파일을 읽어 marketplace 목록을 확인합니다.

2. **registry에 없는 marketplace 삭제**: `~/.claude/plugins/known_marketplaces.json`을 읽어 registry에 명시되지 않은 marketplace를 삭제합니다.
   ```bash
   # 현재 등록된 marketplace 목록 확인
   cat ~/.claude/plugins/known_marketplaces.json

   # registry에 없는 marketplace 삭제
   claude plugin marketplace remove <marketplace_name>
   ```

3. 각 marketplace에 대해:
   - `source`가 `github`인 경우: `claude plugin marketplace add <repo>`
   - `source`가 `git`인 경우: `claude plugin marketplace add <url>`

4. 예시:
   ```bash
   claude plugin marketplace add anthropics/claude-plugins-official
   claude plugin marketplace add https://github.com/h16rkim/cc-lsp.git
   ```

### Step 7: Plugin 동기화

1. `$REGISTRY_DIR/plugins.json` 파일을 읽어 plugin 목록을 확인합니다.

2. **registry에 없는 plugin 삭제**: `~/.claude/plugins/installed_plugins.json`을 읽어 registry에 명시되지 않은 plugin을 삭제합니다.
   ```bash
   # 현재 설치된 plugin 목록 확인
   cat ~/.claude/plugins/installed_plugins.json

   # registry에 없는 plugin 삭제
   claude plugin uninstall <name>@<marketplace>
   ```

3. 각 plugin에 대해:
   ```bash
   # 설치
   claude plugin install <name>@<marketplace>

   # 활성화/비활성화 (enabled 값에 따라)
   claude plugin enable <name>@<marketplace>   # enabled: true
   claude plugin disable <name>@<marketplace>  # enabled: false
   ```

4. 예시:
   ```bash
   claude plugin install kotlin-lsp@cc-lsp
   claude plugin enable kotlin-lsp@cc-lsp
   ```

### Step 8: 완료

동기화 결과를 요약하여 보고합니다:
- 프로젝트 경로
- 생성된 심볼릭 링크 목록
- 설치된 MCP 서버 목록
- 추가된 Marketplace 목록
- 설치된 Plugin 목록

사용자에게 "설정 적용을 위해 Claude Code를 재시작해주세요"라고 안내합니다.

## 주의사항

- 기존 설정이 심볼릭 링크로 되어 있다면 경로를 확인하고 필요시 사용자에게 알려주세요
- MCP 서버 추가 시 이미 존재하는 서버는 먼저 제거 후 추가합니다
- Plugin 설치 시 이미 설치된 경우에도 에러 없이 진행됩니다
