# fwdslsh Plugins

This repository contains plugins for [Claude Code](https://github.com/anthropics/claude-code) and [OpenCode](https://opencode.ai).

## Available Plugins

### PACE (Progressive Autonomous Coding Engine)

A comprehensive plugin system that enables systematic feature development through specialized agents and workflows.

#### Features

- **Specialized Agents**: Architecture strategist, code reviewers, performance oracle, security sentinel, and more
- **Project Initialization**: Automated setup with feature planning and progress tracking
- **Continuous Development**: Structured workflows for feature implementation
- **Code Review Pipeline**: Multiple specialized reviewers for comprehensive code analysis

#### Usage

The PACE plugin provides several commands:

- `/pace-init-project` - Initialize a new project with PACE structure
- `/pace-next-feature` - Work on the next feature in the queue
- `/pace-continue-work` - Resume work on the current feature
- `/pace-commit-feature` - Commit completed features with proper review

See the [plugins/pace](./plugins/pace) directory for detailed documentation on available agents and commands.

## Installation

### For Claude Code

1. Clone this repository:
   ```bash
   git clone https://github.com/fwdslsh/agent-plugins.git
   ```

2. Link plugins to your Claude Code installation (location varies by platform):
   ```bash
   # macOS/Linux example
   ln -s /path/to/agent-plugins/plugins/pace ~/.claude/plugins/pace
   ```

### For OpenCode

1. Clone this repository:
   ```bash
   git clone https://github.com/fwdslsh/agent-plugins.git
   ```

2. Link plugins to your OpenCode installation:
   ```bash
   ln -s /path/to/agent-plugins/plugins/pace ~/.opencode/plugins/pace
   ```

## Development

To create your own plugins, refer to the plugin structure in the `plugins/` directory:

```
plugins/
  your-plugin/
    agent/           # Custom agent definitions
    command/         # Command implementations
    your-plugin.ts   # Plugin entry point
```

## Contributing

Contributions are welcome! Please feel free to submit issues or pull requests.

## License

CC-BY-4.0
