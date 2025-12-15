#!/bin/bash
#
# pre-session-hook.sh - Hook that runs before each Claude Code session
#
# Verifies environment is ready for a coding session.
# Install to ~/.claude/hooks/pre-session-hook.sh
#

set -e

# Configuration
FEATURE_FILE="feature_list.json"
PROGRESS_FILE="claude-progress.txt"
INIT_SCRIPT="init.sh"

# Colors
RED='\033[0;31m'
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
echo -e "${BLUE}  Long-Running Agent Harness - Pre-Session Check${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"

ERRORS=0

# Check 1: Feature list exists and is valid JSON
echo -n "✓ Checking feature_list.json... "
if python3 -c "import json; json.load(open('$FEATURE_FILE'))" 2>/dev/null; then
    echo -e "${GREEN}valid${NC}"
else
    echo -e "${RED}INVALID JSON${NC}"
    ERRORS=$((ERRORS + 1))
fi

# Check 2: Progress file exists
echo -n "✓ Checking claude-progress.txt... "
if [ -f "$PROGRESS_FILE" ]; then
    echo -e "${GREEN}exists${NC}"
else
    echo -e "${YELLOW}missing (will be created)${NC}"
fi

# Check 3: Init script exists and is executable
echo -n "✓ Checking init.sh... "
if [ -x "$INIT_SCRIPT" ]; then
    echo -e "${GREEN}ready${NC}"
elif [ -f "$INIT_SCRIPT" ]; then
    echo -e "${YELLOW}exists but not executable${NC}"
    chmod +x "$INIT_SCRIPT"
    echo "   → Made executable"
else
    echo -e "${RED}MISSING${NC}"
    ERRORS=$((ERRORS + 1))
fi

# Check 4: Git repository
echo -n "✓ Checking git repository... "
if git rev-parse --git-dir > /dev/null 2>&1; then
    BRANCH=$(git branch --show-current)
    echo -e "${GREEN}on branch '$BRANCH'${NC}"
else
    echo -e "${RED}NOT A GIT REPO${NC}"
    ERRORS=$((ERRORS + 1))
fi

# Check 5: Uncommitted changes
echo -n "✓ Checking for uncommitted changes... "
UNCOMMITTED=$(git status --porcelain 2>/dev/null | wc -l)
if [ "$UNCOMMITTED" -eq 0 ]; then
    echo -e "${GREEN}clean${NC}"
else
    echo -e "${YELLOW}$UNCOMMITTED files modified${NC}"
fi

# Check 6: Show current progress
echo ""
echo "📊 Current Progress:"
cat "$FEATURE_FILE" | python3 -c "
import json, sys
d = json.load(sys.stdin)
features = d.get('features', [])
passing = sum(1 for f in features if f.get('passes'))
total = len(features)
pct = passing/total*100 if total > 0 else 0
print(f'   {passing}/{total} features passing ({pct:.1f}%)')

# Show next feature
priority_order = {'critical': 0, 'high': 1, 'medium': 2, 'low': 3}
failing = [f for f in features if not f.get('passes')]
failing.sort(key=lambda f: priority_order.get(f.get('priority', 'low'), 4))
if failing:
    f = failing[0]
    print(f'   Next: {f[\"id\"]} - {f[\"description\"][:50]}')
elif total > 0:
    print('   ✅ All features complete!')
"

# Final status
echo ""
if [ "$ERRORS" -gt 0 ]; then
    echo -e "${RED}❌ Pre-flight check failed with $ERRORS error(s)${NC}"
    echo "   Please fix the issues above before continuing."
    exit 1
else
    echo -e "${GREEN}✅ Pre-flight check passed - ready for coding session${NC}"
fi

echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
