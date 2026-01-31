---
allowed-tools: Bash, Read, Write, Edit
---

# claude-code-reset

로컬 Claude Code 설정을 완전히 초기화하고, 이 프로젝트의 Registry 기준으로 재설치합니다.

## 주의사항

**이 스킬은 파괴적 작업을 수행합니다:**
- 현재 설치된 모든 MCP 서버 삭제
- 현재 설치된 모든 Plugin 삭제
- 현재 등록된 모든 Marketplace 삭제
- ~/.claude/ 하위 설정 파일들이 symlink로 교체

**실행 전 반드시 사용자 확인 필요**

## 수행 작업

1. 현재 상태 표시 및 사용자 확인
2. Repository 최신 상태로 동기화 (git pull)
3. 기존 Plugin/Marketplace/MCP 서버 전부 삭제
4. config/ 하위 파일들을 ~/.claude/에 symlink 생성
5. registry/ 기준으로 MCP/Marketplace/Plugin 재설치
6. reset.sh 실행

## 실행 지침

### Step 0: 사전 확인
- 현재 MCP/Marketplace/Plugin 목록을 표시
- 사용자에게 "이 설정들이 모두 삭제됩니다. 계속하시겠습니까?" 확인

### Step 0-1: Repository 동기화
- `git pull`로 최신 상태로 동기화

### Step 1: Plugin 삭제
- `claude plugin list`로 목록 조회
- 각 plugin에 대해 `claude plugin uninstall <name>@<marketplace>`

### Step 2: Marketplace 삭제
- `claude plugin marketplace list`로 목록 조회
- 각 marketplace에 대해 `claude plugin marketplace remove <name>`

### Step 3: MCP 서버 삭제
- `claude mcp list`로 목록 조회
- 각 서버에 대해 `claude mcp remove <name>`

### Step 4: Symlink 생성
- ~/.claude/ 디렉토리 확인/생성
- config/ 하위 항목들을 symlink로 연결:
  - settings.json, CLAUDE.md, keybindings.json
  - commands/, skills/, rules/

### Step 5: MCP 서버 설치
- registry/mcp-servers.json 읽기
- `claude mcp add-json --scope <scope> <name> '<config>'`

### Step 6: Marketplace 추가
- registry/marketplaces.json 읽기
- `claude plugin marketplace add <repo>`

### Step 7: Plugin 설치
- registry/plugins.json 읽기
- `claude plugin install <name>@<marketplace>`
- enabled에 따라 enable/disable

### Step 8: reset.sh 실행
- 위 단계 완료 후 reset.sh 실행
- 결과 보고 (삭제/설치된 항목 요약)