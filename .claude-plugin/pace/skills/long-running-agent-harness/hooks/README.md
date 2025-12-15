# Claude Code Hooks for Long-Running Agent Harness

This directory contains hooks that integrate with Claude Code to enable automatic session continuation.

## Available Hooks

### post-session-hook.sh

Executes after each Claude Code session ends. Checks if more work remains and can trigger the next session.

### pre-session-hook.sh

Executes before each session to verify environment is ready.

## Installation

Copy hooks to your Claude Code configuration:

```bash
mkdir -p ~/.claude/hooks
cp hooks/*.sh ~/.claude/hooks/
chmod +x ~/.claude/hooks/*.sh
```

## Configuration

Add to your Claude Code settings (`.claude/settings.json`):

```json
{
	"hooks": {
		"postSession": "~/.claude/hooks/post-session-hook.sh",
		"preSession": "~/.claude/hooks/pre-session-hook.sh"
	}
}
```

## Alternative: CLAUDE.md Integration

Add continuation instructions to your project's CLAUDE.md:

```markdown
## Session Continuation

After completing any feature:

1. Check if more features remain: `cat feature_list.json | grep '"passes": false' | wc -l`
2. If features remain, immediately continue with: "Continuing to next feature..."
3. Do NOT wait for user input between features
4. Only stop when all features pass or a blocker is encountered
```

## Alternative: Wrapper Script

For environments where hooks aren't available, use the orchestrator:

```bash
python scripts/orchestrator.py --until-complete
```
