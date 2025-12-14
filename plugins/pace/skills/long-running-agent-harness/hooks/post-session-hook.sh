#!/bin/bash
#
# post-session-hook.sh - Hook that runs after each Claude Code session
#
# This hook checks if more features remain and can trigger continuation.
# Install to ~/.claude/hooks/post-session-hook.sh
#

set -e

# Configuration
FEATURE_FILE="feature_list.json"
PROGRESS_FILE="claude-progress.txt"
AUTO_CONTINUE=${AUTO_CONTINUE:-false}  # Set to true for full automation
COOLDOWN_SECONDS=${COOLDOWN_SECONDS:-5}

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Check if we're in a long-running harness project
if [ ! -f "$FEATURE_FILE" ]; then
    # Not a harness project, exit silently
    exit 0
fi

echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  Long-Running Agent Harness - Post-Session Hook${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"

# Calculate progress
TOTAL=$(cat "$FEATURE_FILE" | python3 -c "import json,sys; print(len(json.load(sys.stdin)['features']))")
PASSING=$(cat "$FEATURE_FILE" | python3 -c "import json,sys; print(sum(1 for f in json.load(sys.stdin)['features'] if f.get('passes')))")
FAILING=$((TOTAL - PASSING))
PERCENT=$((PASSING * 100 / TOTAL))

echo "📊 Progress: $PASSING/$TOTAL features ($PERCENT%)"

# Check if complete
if [ "$FAILING" -eq 0 ]; then
    echo -e "\n${GREEN}🎉 ALL FEATURES COMPLETE!${NC}"
    echo "The project has been fully implemented."
    exit 0
fi

# Show next feature
NEXT_FEATURE=$(cat "$FEATURE_FILE" | python3 -c "
import json, sys
d = json.load(sys.stdin)
priority_order = {'critical': 0, 'high': 1, 'medium': 2, 'low': 3}
failing = [f for f in d['features'] if not f.get('passes')]
failing.sort(key=lambda f: priority_order.get(f.get('priority', 'low'), 4))
if failing:
    f = failing[0]
    print(f\"{f['id']}: {f['description'][:60]}\")
")

echo -e "\n📋 Next feature: $NEXT_FEATURE"
echo "   Remaining: $FAILING features"

# Check git status
UNCOMMITTED=$(git status --porcelain 2>/dev/null | wc -l)
if [ "$UNCOMMITTED" -gt 0 ]; then
    echo -e "\n${YELLOW}⚠️  Warning: $UNCOMMITTED uncommitted changes${NC}"
fi

# Auto-continuation logic
if [ "$AUTO_CONTINUE" = "true" ]; then
    echo -e "\n${GREEN}🔄 Auto-continue enabled. Starting next session in ${COOLDOWN_SECONDS}s...${NC}"
    echo "   Press Ctrl+C to cancel"
    sleep "$COOLDOWN_SECONDS"
    
    # Trigger next session
    # This depends on how Claude Code is invoked in your environment
    exec claude -p "Continue work on this project. Follow the coding agent workflow to implement the next feature: $NEXT_FEATURE"
else
    echo -e "\n${YELLOW}💡 To continue, run:${NC}"
    echo "   claude -p 'Continue to the next feature using the coding agent workflow'"
    echo ""
    echo "   Or enable auto-continue:"
    echo "   AUTO_CONTINUE=true claude ..."
fi

echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
