# Jira Toolkit

Claude Code plugin for working with Atlassian Jira.

## Features

- **Search Issues** - Use JQL to find issues
- **View Issues** - Get full issue details
- **Create Issues** - Create bugs, tasks, stories
- **Update Issues** - Modify fields, priority, summary
- **Workflow** - Assign, transition status, comment
- **Track Work** - Log time on issues
- **Labels & Links** - Manage labels and issue relationships
- **Watch** - Subscribe to issue updates

## Setup

### 1. Create credentials file

Create `~/.atlassian_env`:

```bash
export JIRA_URL=https://your-domain.atlassian.net
export JIRA_API_TOKEN=your-api-token
```

### 2. Secure the file

```bash
chmod 600 ~/.atlassian_env
```

### 3. Generate API Token

1. Go to https://id.atlassian.com/manage-profile/security/api-tokens
2. Click "Create API token"
3. Copy the token to your `~/.atlassian_env`

## Installation

```bash
claude plugin marketplace add msk-mind/claude-plugins
claude plugin install jira-toolkit@msk-mind-plugins
```

Restart Claude Code after installation.

## Usage

Just ask Claude naturally:

- "Search for my open Jira issues"
- "Create a bug ticket for the login problem"
- "What's the status of PROJ-123?"
- "Assign PROJ-456 to me and move it to In Progress"
- "Add a comment to PROJ-789"
- "Log 2 hours on PROJ-123"

## Helper Script Commands

```bash
# Search issues
jira-helper.sh search "assignee=currentUser() AND status='In Progress'"

# View issue
jira-helper.sh view PROJ-123

# Create issue
jira-helper.sh create PROJECT Bug "Summary" "Description"

# Update issue
jira-helper.sh update PROJ-123 --summary "New title" --priority "High"

# Add comment
jira-helper.sh comment PROJ-123 "Comment text"

# Assign issue
jira-helper.sh assign PROJ-123 username

# Transition status
jira-helper.sh transition PROJ-123 "In Progress"

# Link issues
jira-helper.sh link PROJ-123 "blocks" PROJ-456

# Manage labels
jira-helper.sh labels PROJ-123 add bug critical

# Log work
jira-helper.sh worklog PROJ-123 "2h" "Work description"

# Watch/unwatch
jira-helper.sh watch PROJ-123

# List projects
jira-helper.sh projects

# Current user info
jira-helper.sh me
```

## JQL Query Examples

```bash
# Your unresolved issues
"assignee=currentUser() AND resolution=Unresolved"

# Issues in a project
"project=MYPROJ AND status='Open'"

# High priority bugs
"project=MYPROJ AND type=Bug AND priority=High"

# Recently updated
"assignee=currentUser() AND updated >= -7d"

# Current sprint
"sprint in openSprints() AND assignee=currentUser()"

# Text search
"text ~ 'authentication' AND project=MYPROJ"
```

## Troubleshooting

### Authentication Errors
- Verify `~/.atlassian_env` has correct values
- Regenerate API token if needed
- Ensure JIRA_URL includes `https://`

### Issue Not Found
- Verify issue key format (PROJECT-123)
- Check permissions

### Transition Fails
- Status names must match exactly (case-sensitive)
- Some transitions require specific permissions

## Dependencies

- `curl` - API requests
- `jq` - JSON parsing

## License

MIT
