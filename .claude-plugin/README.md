# Claude Code Plugins

This directory contains Claude Code plugins for the Pace orchestrator.

## Available Plugins

### pace

Orchestrate long-running software development across multiple context windows using a two-agent architecture (initializer + coding agent).

**Components:**

- **Commands**: `/init-project`, `/continue-work`, `/next-feature`
- **Agents**: coding-agent, coding-coordinator, initializer-agent, plus review agents
- **Skills**: long-running-agent-harness

See `pace/` for full documentation.
