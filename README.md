# MSK MIND Claude Plugins

A collection of Claude Code plugins for working with Atlassian tools.

## Plugins

| Plugin | Description |
|--------|-------------|
| **jira-toolkit** | Create, update, search, and manage Jira issues |
| **confluence-toolkit** | Create, update, search, and manage Confluence pages |

## Installation

### Quick Install (Recommended)

```bash
curl -fsSL https://raw.githubusercontent.com/msk-mind/claude-plugins/main/install.sh | bash
```

### Manual Install

```bash
git clone https://github.com/msk-mind/claude-plugins.git ~/.claude/plugins/msk-mind
```

## Configuration

Both plugins require Atlassian credentials. Create `~/.atlassian_env`:

```bash
ATLASSIAN_DOMAIN=your-domain.atlassian.net
ATLASSIAN_EMAIL=your-email@example.com
ATLASSIAN_API_TOKEN=your-api-token
```

### Getting an API Token

1. Go to [Atlassian API Tokens](https://id.atlassian.com/manage-profile/security/api-tokens)
2. Click "Create API token"
3. Give it a label and copy the token

## Usage

After installation, restart Claude Code. The plugins will be available automatically.

### Jira Toolkit

```
# Search for issues
/jira search "project = MYPROJ AND status = Open"

# Create an issue
/jira create --project MYPROJ --type Task --summary "New task"

# View an issue
/jira view MYPROJ-123
```

### Confluence Toolkit

```
# Search for pages
/confluence search "my documentation"

# Create a page
/confluence create --space MYSPACE --title "New Page" --content "Page content"

# View a page
/confluence view 12345678
```

## Updating

```bash
cd ~/.claude/plugins/msk-mind && git pull
```

## License

MIT License - see [LICENSE](LICENSE)

## Contributing

Issues and pull requests welcome at [github.com/msk-mind/claude-plugins](https://github.com/msk-mind/claude-plugins).
