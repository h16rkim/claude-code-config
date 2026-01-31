#!/bin/bash

# Claude Code Config 리셋 스크립트
# 로컬 설정을 완전히 초기화하고, Registry 기준으로 재설치합니다.

set -e

SCRIPT_DIR="$(git rev-parse --show-toplevel)"
CONFIG_DIR="$SCRIPT_DIR/config"
REGISTRY_DIR="$SCRIPT_DIR/registry"
CLAUDE_BASE_DIR="$HOME/.claude"

# 자주 사용되는 경로 변수화
CONFIG_COMMANDS_DIR="$CONFIG_DIR/commands"
CONFIG_SKILLS_DIR="$CONFIG_DIR/skills"
CONFIG_RULES_DIR="$CONFIG_DIR/rules"

echo "=== Claude Code Config 리셋 ==="
echo ""

# jq 설치 확인
if ! command -v jq &> /dev/null; then
    echo "❌ jq가 설치되어 있지 않습니다."
    echo "   brew install jq 로 jq를 설치한 후 다시 실행하세요."
    exit 1
fi

# Phase 0: Git Pull
echo "[Phase 0/4] Repository 최신 상태로 동기화..."
echo ""
cd "$SCRIPT_DIR"
if git pull; then
    echo "  - Git pull 완료"
else
    echo "  - Git pull 실패 (계속 진행)"
fi
echo ""

# Phase 1: 삭제
echo "[Phase 1/4] 기존 설정 삭제..."
echo ""

# 1-1. Plugin 삭제
echo "[1/3] Plugin 삭제 중..."
plugin_list=$(claude plugin list 2>/dev/null || echo "")
if [ -n "$plugin_list" ]; then
    echo "$plugin_list" | while read -r line; do
        # 형식: name@marketplace (enabled/disabled)
        plugin_id=$(echo "$line" | awk '{print $1}')
        if [ -n "$plugin_id" ] && [ "$plugin_id" != "No" ]; then
            echo "  - $plugin_id 삭제 중..."
            claude plugin uninstall "$plugin_id" 2>/dev/null || true
        fi
    done
    echo "  - Plugin 삭제 완료"
else
    echo "  - 설치된 Plugin이 없습니다."
fi

# 1-2. Marketplace 삭제
echo ""
echo "[2/3] Marketplace 삭제 중..."
marketplace_list=$(claude plugin marketplace list 2>/dev/null || echo "")
if [ -n "$marketplace_list" ]; then
    echo "$marketplace_list" | while read -r line; do
        # 형식: name (source)
        marketplace_name=$(echo "$line" | awk '{print $1}')
        if [ -n "$marketplace_name" ] && [ "$marketplace_name" != "No" ]; then
            echo "  - $marketplace_name 삭제 중..."
            claude plugin marketplace remove "$marketplace_name" 2>/dev/null || true
        fi
    done
    echo "  - Marketplace 삭제 완료"
else
    echo "  - 등록된 Marketplace가 없습니다."
fi

# 1-3. MCP 서버 삭제
echo ""
echo "[3/3] MCP 서버 삭제 중..."
mcp_list=$(claude mcp list 2>/dev/null || echo "")
if [ -n "$mcp_list" ]; then
    echo "$mcp_list" | while read -r line; do
        # 형식: name: description
        mcp_name=$(echo "$line" | cut -d':' -f1 | tr -d ' ')
        if [ -n "$mcp_name" ] && [ "$mcp_name" != "No" ]; then
            echo "  - $mcp_name 삭제 중..."
            claude mcp remove "$mcp_name" 2>/dev/null || true
        fi
    done
    echo "  - MCP 서버 삭제 완료"
else
    echo "  - 설치된 MCP 서버가 없습니다."
fi

# Phase 2: Symlink 생성
echo ""
echo "[Phase 2/4] Symlink 생성..."
echo ""

# ~/.claude 디렉토리 생성
mkdir -p "$CLAUDE_BASE_DIR"

# settings.json
echo "[1/6] settings.json..."
rm -f "$CLAUDE_BASE_DIR/settings.json"
if [ -f "$CONFIG_DIR/settings.json" ]; then
    ln -s "$CONFIG_DIR/settings.json" "$CLAUDE_BASE_DIR/settings.json"
    echo "  - settings.json -> $CONFIG_DIR/settings.json"
fi

# CLAUDE.md
echo "[2/6] CLAUDE.md..."
rm -f "$CLAUDE_BASE_DIR/CLAUDE.md"
if [ -f "$CONFIG_DIR/CLAUDE.md" ]; then
    ln -s "$CONFIG_DIR/CLAUDE.md" "$CLAUDE_BASE_DIR/CLAUDE.md"
    echo "  - CLAUDE.md -> $CONFIG_DIR/CLAUDE.md"
fi

# keybindings.json
echo "[3/6] keybindings.json..."
rm -f "$CLAUDE_BASE_DIR/keybindings.json"
if [ -f "$CONFIG_DIR/keybindings.json" ]; then
    ln -s "$CONFIG_DIR/keybindings.json" "$CLAUDE_BASE_DIR/keybindings.json"
    echo "  - keybindings.json -> $CONFIG_DIR/keybindings.json"
fi

# commands/
echo "[4/6] commands/..."
rm -rf "$CLAUDE_BASE_DIR/commands"
if [ -d "$CONFIG_COMMANDS_DIR" ]; then
    ln -s "$CONFIG_COMMANDS_DIR" "$CLAUDE_BASE_DIR/commands"
    echo "  - commands/ -> $CONFIG_COMMANDS_DIR"
fi

# skills/
echo "[5/6] skills/..."
rm -rf "$CLAUDE_BASE_DIR/skills"
if [ -d "$CONFIG_SKILLS_DIR" ]; then
    ln -s "$CONFIG_SKILLS_DIR" "$CLAUDE_BASE_DIR/skills"
    echo "  - skills/ -> $CONFIG_SKILLS_DIR"
fi

# rules/
echo "[6/6] rules/..."
rm -rf "$CLAUDE_BASE_DIR/rules"
if [ -d "$CONFIG_RULES_DIR" ]; then
    ln -s "$CONFIG_RULES_DIR" "$CLAUDE_BASE_DIR/rules"
    echo "  - rules/ -> $CONFIG_RULES_DIR"
fi

# Phase 3: Registry 기반 재설치
echo ""
echo "[Phase 3/4] Registry 기반 재설치..."
echo ""

# 3-1. MCP 서버 설치
echo "[1/3] MCP 서버 설치..."
if [ -f "$REGISTRY_DIR/mcp-servers.json" ]; then
    jq -c '.servers[]' "$REGISTRY_DIR/mcp-servers.json" 2>/dev/null | while read -r server; do
        name=$(echo "$server" | jq -r '.name')
        scope=$(echo "$server" | jq -r '.scope')
        config=$(echo "$server" | jq -c '.config')

        echo "  - $name 서버 설치 중..."
        claude mcp add-json --scope "$scope" "$name" "$config" 2>/dev/null || true
    done
    echo "  - MCP 서버 설치 완료"
else
    echo "  - registry/mcp-servers.json 파일이 없습니다."
fi

# 3-2. Marketplace 추가
echo ""
echo "[2/3] Marketplace 추가..."
if [ -f "$REGISTRY_DIR/marketplaces.json" ]; then
    jq -c '.marketplaces[]' "$REGISTRY_DIR/marketplaces.json" 2>/dev/null | while read -r marketplace; do
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
    echo "  - registry/marketplaces.json 파일이 없습니다."
fi

# 3-3. Plugin 설치
echo ""
echo "[3/3] Plugin 설치..."
if [ -f "$REGISTRY_DIR/plugins.json" ]; then
    jq -c '.plugins[]' "$REGISTRY_DIR/plugins.json" 2>/dev/null | while read -r plugin; do
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
    echo "  - registry/plugins.json 파일이 없습니다."
fi

# 완료
echo ""
echo "=== 리셋 완료 ==="
echo ""
echo "설정 요약:"
echo "  - Symlink: settings.json, CLAUDE.md, keybindings.json, commands/, skills/, rules/"
echo "  - MCP 서버: registry/mcp-servers.json 기준 재설치"
echo "  - Marketplace: registry/marketplaces.json 기준 재설치"
echo "  - Plugin: registry/plugins.json 기준 재설치"
echo ""
echo "⚠️  Claude Code를 재시작하여 설정을 적용해주세요."
echo ""