#!/bin/bash

# Claude Code Config 초기 설정 스크립트
# 새 머신에서 최초 1회 실행하여 Claude Code 설정을 적용합니다.

set -e

SCRIPT_DIR="$(git rev-parse --show-toplevel)"
CLAUDE_BASE_DIR="$HOME/.claude"

# 자주 사용되는 경로 변수화
CONFIG_DIR="$SCRIPT_DIR/config"
CONFIG_COMMANDS_DIR="$CONFIG_DIR/commands"
CONFIG_SKILLS_DIR="$CONFIG_DIR/skills"
CONFIG_RULES_DIR="$CONFIG_DIR/rules"

echo "=== Claude Code Config 초기 설정 ==="
echo ""

# 1. ~/.claude 디렉토리 생성
echo "[1/7] ~/.claude 디렉토리 확인..."
mkdir -p "$CLAUDE_BASE_DIR"

# 2. 기존 설정을 프로젝트로 백업 (심볼릭 링크가 아닌 실제 파일만)
echo ""
echo "[2/7] 기존 설정을 프로젝트로 백업..."

# config 디렉토리 생성
mkdir -p "$CONFIG_DIR"

# settings.json 백업
if [ -f "$CLAUDE_BASE_DIR/settings.json" ] && [ ! -L "$CLAUDE_BASE_DIR/settings.json" ]; then
    cp "$CLAUDE_BASE_DIR/settings.json" "$CONFIG_DIR/"
    echo "  - settings.json -> config/settings.json"
fi

# CLAUDE.md 백업
if [ -f "$CLAUDE_BASE_DIR/CLAUDE.md" ] && [ ! -L "$CLAUDE_BASE_DIR/CLAUDE.md" ]; then
    cp "$CLAUDE_BASE_DIR/CLAUDE.md" "$CONFIG_DIR/"
    echo "  - CLAUDE.md -> config/CLAUDE.md"
fi

# keybindings.json 백업
if [ -f "$CLAUDE_BASE_DIR/keybindings.json" ] && [ ! -L "$CLAUDE_BASE_DIR/keybindings.json" ]; then
    cp "$CLAUDE_BASE_DIR/keybindings.json" "$CONFIG_DIR/"
    echo "  - keybindings.json -> config/keybindings.json"
fi

# commands 디렉토리 내 파일들 백업 (symlink가 아닌 파일만)
if [ -d "$CLAUDE_BASE_DIR/commands" ] && [ ! -L "$CLAUDE_BASE_DIR/commands" ]; then
    mkdir -p "$CONFIG_COMMANDS_DIR"
    find "$CLAUDE_BASE_DIR/commands" -maxdepth 1 -type f ! -name ".*" | while read -r file; do
        filename=$(basename "$file")
        cp "$file" "$CONFIG_COMMANDS_DIR/"
        echo "  - commands/$filename -> config/commands/$filename"
    done
fi

# skills 디렉토리 내 파일들 백업 (symlink가 아닌 파일만)
if [ -d "$CLAUDE_BASE_DIR/skills" ] && [ ! -L "$CLAUDE_BASE_DIR/skills" ]; then
    mkdir -p "$CONFIG_SKILLS_DIR"
    find "$CLAUDE_BASE_DIR/skills" -maxdepth 1 -type f ! -name ".*" | while read -r file; do
        filename=$(basename "$file")
        cp "$file" "$CONFIG_SKILLS_DIR/"
        echo "  - skills/$filename -> config/skills/$filename"
    done
fi

# rules 디렉토리 내 파일들 백업 (symlink가 아닌 파일만)
if [ -d "$CLAUDE_BASE_DIR/rules" ] && [ ! -L "$CLAUDE_BASE_DIR/rules" ]; then
    mkdir -p "$CONFIG_RULES_DIR"
    find "$CLAUDE_BASE_DIR/rules" -maxdepth 1 -type f ! -name ".*" | while read -r file; do
        filename=$(basename "$file")
        cp "$file" "$CONFIG_RULES_DIR/"
        echo "  - rules/$filename -> config/rules/$filename"
    done
fi

# 3. 심볼릭 링크 생성
echo ""
echo "[3/7] 심볼릭 링크 생성..."

# settings.json
rm -f "$CLAUDE_BASE_DIR/settings.json"
ln -s "$CONFIG_DIR/settings.json" "$CLAUDE_BASE_DIR/settings.json"
echo "  - settings.json -> $CONFIG_DIR/settings.json"

# CLAUDE.md
rm -f "$CLAUDE_BASE_DIR/CLAUDE.md"
ln -s "$CONFIG_DIR/CLAUDE.md" "$CLAUDE_BASE_DIR/CLAUDE.md"
echo "  - CLAUDE.md -> $CONFIG_DIR/CLAUDE.md"

# keybindings.json
rm -f "$CLAUDE_BASE_DIR/keybindings.json"
ln -s "$CONFIG_DIR/keybindings.json" "$CLAUDE_BASE_DIR/keybindings.json"
echo "  - keybindings.json -> $CONFIG_DIR/keybindings.json"

# commands/
rm -rf "$CLAUDE_BASE_DIR/commands"
ln -s "$CONFIG_COMMANDS_DIR" "$CLAUDE_BASE_DIR/commands"
echo "  - commands/ -> $CONFIG_COMMANDS_DIR"

# skills/
rm -rf "$CLAUDE_BASE_DIR/skills"
ln -s "$CONFIG_SKILLS_DIR" "$CLAUDE_BASE_DIR/skills"
echo "  - skills/ -> $CONFIG_SKILLS_DIR"

# rules/
rm -rf "$CLAUDE_BASE_DIR/rules"
ln -s "$CONFIG_RULES_DIR" "$CLAUDE_BASE_DIR/rules"
echo "  - rules/ -> $CONFIG_RULES_DIR"

# 4. MCP 서버 설치
echo ""
echo "[4/7] MCP 서버 설치..."

# registry/mcp-servers.json 파일 읽기
if [ -f "$SCRIPT_DIR/registry/mcp-servers.json" ]; then
    # jq가 설치되어 있는지 확인
    if command -v jq &> /dev/null; then
        # 각 서버에 대해 설치
        jq -c '.servers[]' "$SCRIPT_DIR/registry/mcp-servers.json" | while read -r server; do
            name=$(echo "$server" | jq -r '.name')
            scope=$(echo "$server" | jq -r '.scope')
            config=$(echo "$server" | jq -c '.config')

            echo "  - $name 서버 설치 중..."

            # 기존 서버 제거 (에러 무시)
            claude mcp remove "$name" 2>/dev/null || true

            # 새로 추가
            claude mcp add-json --scope "$scope" "$name" "$config"
        done
        echo "  - MCP 서버 설치 완료"
    else
        echo "  - jq가 설치되어 있지 않습니다. MCP 서버를 수동으로 설치해주세요."
        echo "  - brew install jq 로 jq를 설치한 후 다시 실행하세요."
    fi
else
    echo "  - registry/mcp-servers.json 파일이 없습니다."
fi

# 5. Marketplace 추가
echo ""
echo "[5/7] Marketplace 추가..."

if [ -f "$SCRIPT_DIR/registry/marketplaces.json" ]; then
    if command -v jq &> /dev/null; then
        jq -c '.marketplaces[]' "$SCRIPT_DIR/registry/marketplaces.json" | while read -r marketplace; do
            name=$(echo "$marketplace" | jq -r '.name')
            source=$(echo "$marketplace" | jq -r '.source')

            echo "  - $name marketplace 추가 중..."

            if [ "$source" = "github" ]; then
                repo=$(echo "$marketplace" | jq -r '.repo')
                claude plugin marketplace add "$repo" 2>/dev/null || true
            elif [ "$source" = "git" ]; then
                url=$(echo "$marketplace" | jq -r '.url')
                claude plugin marketplace add "$url" 2>/dev/null || true
            fi
        done
        echo "  - Marketplace 추가 완료"
    else
        echo "  - jq가 필요합니다."
    fi
else
    echo "  - registry/marketplaces.json 파일이 없습니다."
fi

# 6. Plugin 설치
echo ""
echo "[6/7] Plugin 설치..."

if [ -f "$SCRIPT_DIR/registry/plugins.json" ]; then
    if command -v jq &> /dev/null; then
        jq -c '.plugins[]' "$SCRIPT_DIR/registry/plugins.json" | while read -r plugin; do
            name=$(echo "$plugin" | jq -r '.name')
            marketplace=$(echo "$plugin" | jq -r '.marketplace')
            enabled=$(echo "$plugin" | jq -r '.enabled')

            plugin_id="$name@$marketplace"
            echo "  - $plugin_id 설치 중..."

            # 설치
            claude plugin install "$plugin_id" 2>/dev/null || true

            # 활성화/비활성화
            if [ "$enabled" = "true" ]; then
                claude plugin enable "$plugin_id" 2>/dev/null || true
            else
                claude plugin disable "$plugin_id" 2>/dev/null || true
            fi
        done
        echo "  - Plugin 설치 완료"
    else
        echo "  - jq가 필요합니다."
    fi
else
    echo "  - registry/plugins.json 파일이 없습니다."
fi

# 7. 완료
echo ""
echo "[7/7] 설정 완료!"
echo ""
echo "=== 설정 요약 ==="
echo "심볼릭 링크:"
echo "  - $CLAUDE_BASE_DIR/settings.json -> $CONFIG_DIR/settings.json"
echo "  - $CLAUDE_BASE_DIR/CLAUDE.md -> $CONFIG_DIR/CLAUDE.md"
echo "  - $CLAUDE_BASE_DIR/keybindings.json -> $CONFIG_DIR/keybindings.json"
echo "  - $CLAUDE_BASE_DIR/commands -> $CONFIG_COMMANDS_DIR"
echo "  - $CLAUDE_BASE_DIR/skills -> $CONFIG_SKILLS_DIR"
echo "  - $CLAUDE_BASE_DIR/rules -> $CONFIG_RULES_DIR"
echo ""
echo "⚠️  Claude Code를 재시작하여 설정을 적용해주세요."
echo ""
