# Jira Toolkit

Comprehensive toolkit for working with Jira - create, update, search, and manage issues using the Jira REST API.

## Features

- **Search Issues**: Use JQL (Jira Query Language) to find issues
- **View Details**: Get full information about any issue
- **Create Issues**: Create new bugs, tasks, stories, and more
- **Update Issues**: Modify summary, description, priority, and other fields
- **Manage Workflow**: Assign issues, transition status, add comments
- **Track Work**: Log time spent on issues
- **Labels & Links**: Manage labels and create issue relationships
- **Watch Issues**: Subscribe to issue updates
- **Sprint Info**: View active sprint information
- **Project Management**: List projects and view project details

## Prerequisites

### 1. Authentication Setup

Create `~/.atlassian_env` with your Jira credentials:

```bash
export JIRA_URL=https://yourcompany.atlassian.net
export JIRA_API_TOKEN=your-api-token
```

### 2. Generate API Token

1. Go to https://id.atlassian.com/manage-profile/security/api-tokens
2. Click "Create API token"
3. Give it a name (e.g., "Claude Code Jira")
4. Copy the token and add it to `~/.atlassian_env`

### 3. Enable the Plugin

Add to your `~/.claude/settings.json`:

```json
{
  "enabledPlugins": {
    "jira-toolkit@claude-plugins-official": true
  }
}
```

Restart Claude Code after enabling.

## Usage

Once enabled, you can ask Claude to interact with Jira naturally:

- "Create a Jira ticket for this bug"
- "Search for all my open issues"
- "What's the status of PROJ-123?"
- "Assign PROJ-456 to me and move it to In Progress"
- "Add a comment to PROJ-789 explaining the fix"
- "Log 2 hours of work on PROJ-123"

Claude will automatically use the jira-operations skill when appropriate.

## Manual Usage

You can also run the helper script directly:

```bash
~/.claude/plugins/marketplaces/claude-plugins-official/external_plugins/jira-toolkit/jira-helper.sh [command]
```

### Common Commands

```bash
# Search for issues
jira-helper.sh search "assignee=currentUser() AND status='In Progress'"

# View issue details
jira-helper.sh view PROJ-123

# Create an issue
jira-helper.sh create MYPROJ Bug "Login broken" "Users cannot login"

# Update an issue
jira-helper.sh update PROJ-123 --summary "New title" --priority "High"

# Add comment
jira-helper.sh comment PROJ-123 "Fixed in latest deployment"

# Assign issue
jira-helper.sh assign PROJ-123 username

# Transition status
jira-helper.sh transition PROJ-123 "In Progress"

# Link issues
jira-helper.sh link PROJ-123 "blocks" PROJ-456

# Manage labels
jira-helper.sh labels PROJ-123 add bug critical

# Log work
jira-helper.sh worklog PROJ-123 "2h" "Implemented feature"

# Watch/unwatch
jira-helper.sh watch PROJ-123
jira-helper.sh unwatch PROJ-456

# List projects
jira-helper.sh projects

# View current user
jira-helper.sh me
```

## JQL Query Examples

```bash
# Your unresolved issues
"assignee=currentUser() AND resolution=Unresolved"

# Issues in a specific project
"project=MYPROJ AND status='Open'"

# High priority bugs
"project=MYPROJ AND type=Bug AND priority=High"

# Recently updated issues
"assignee=currentUser() AND updated >= -7d"

# Issues in current sprint
"sprint in openSprints() AND assignee=currentUser()"

# Text search
"text ~ 'authentication' AND project=MYPROJ"
```

## Troubleshooting

### Authentication Errors

1. Verify `~/.atlassian_env` exists and has correct values
2. Check that your API token is valid (regenerate if needed)
3. Ensure JIRA_URL includes the full URL with protocol (https://)
4. Test manually: `source ~/.atlassian_env && echo $JIRA_URL`

### Issue Not Found

- Verify the issue key format (PROJECT-123)
- Check you have permission to view the issue
- Ensure you're using the correct Jira instance

### Transition Fails

- Available statuses depend on your workflow configuration
- Status names must match exactly (case-sensitive, including spaces)
- Some transitions may require specific permissions

## Dependencies

- `curl` - For API requests
- `jq` - For JSON parsing

These are typically pre-installed on most systems.

## License

GPL-3.0
