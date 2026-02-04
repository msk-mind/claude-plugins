# MSK MIND Claude Plugins

Claude Code plugins for working with Atlassian tools (Jira and Confluence).

## Plugins

| Plugin | Description |
|--------|-------------|
| **jira-toolkit** | Create, update, search, and manage Jira issues |
| **confluence-toolkit** | Create, update, search, and manage Confluence pages |

## Installation

```bash
# Add the marketplace
claude plugin marketplace add msk-mind/claude-plugins

# Install plugins
claude plugin install jira-toolkit@msk-mind-plugins
claude plugin install confluence-toolkit@msk-mind-plugins
```

Restart Claude Code after installation.

## Configuration

Create `~/.atlassian_env` with your credentials:

```bash
# For Jira
export JIRA_URL=https://your-domain.atlassian.net
export JIRA_API_TOKEN=your-jira-api-token

# For Confluence
export CONFLUENCE_URL=https://your-confluence.example.com/
export CONFLUENCE_USERNAME=your-username
export CONFLUENCE_API_TOKEN=your-confluence-api-token
```

Secure the file:
```bash
chmod 600 ~/.atlassian_env
```

### Getting an API Token

1. Go to [Atlassian API Tokens](https://id.atlassian.com/manage-profile/security/api-tokens)
2. Click "Create API token"
3. Copy the token to your `~/.atlassian_env`

## Usage

After installation, just ask Claude naturally:

### Jira Examples
- "Search for my open Jira issues"
- "Create a bug ticket for the login issue"
- "What's the status of PROJ-123?"
- "Assign PROJ-456 to me"
- "Add a comment to PROJ-789"

### Confluence Examples
- "Search Confluence for authentication docs"
- "Get the content of page 12345678"
- "List Confluence spaces"
- "Create a new page in the DOCS space"

## Updating

```bash
claude plugin marketplace update msk-mind-plugins
claude plugin update jira-toolkit@msk-mind-plugins
claude plugin update confluence-toolkit@msk-mind-plugins
```

## License

MIT License - see [LICENSE](LICENSE)

## Contributing

Issues and pull requests welcome at [github.com/msk-mind/claude-plugins](https://github.com/msk-mind/claude-plugins).
