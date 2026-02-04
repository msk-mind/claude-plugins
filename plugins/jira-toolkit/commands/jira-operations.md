---
description: Work with Jira issues - create, update, search, assign, and manage issues
argument-hint: [operation] [args...]
allowed-tools: Bash(jira-helper.sh:*)
---

# Jira Operations

Work with Jira issues using the Jira REST API. All operations use credentials from `~/.atlassian_env`.

## Arguments

The user invoked this command with: $ARGUMENTS

## Available Helper Script

Use the jira helper script at:
```
~/.claude/plugins/local/jira-toolkit/jira-helper.sh
```

## Common Operations

### Search Issues (JQL)
```bash
~/.claude/plugins/local/jira-toolkit/jira-helper.sh search
~/.claude/plugins/local/jira-toolkit/jira-helper.sh search "assignee=currentUser() AND status='In Progress'"
~/.claude/plugins/local/jira-toolkit/jira-helper.sh search "project=MYPROJ AND type=Bug"
```

### View Issue
```bash
~/.claude/plugins/local/jira-toolkit/jira-helper.sh view PROJ-123
```

### Create Issue
```bash
~/.claude/plugins/local/jira-toolkit/jira-helper.sh create PROJECT Bug "Summary" "Description"
```

### Update Issue
```bash
~/.claude/plugins/local/jira-toolkit/jira-helper.sh update PROJ-123 --summary "New title" --priority "High"
```

### Add Comment
```bash
~/.claude/plugins/local/jira-toolkit/jira-helper.sh comment PROJ-123 "Comment text"
```

### Assign Issue
```bash
~/.claude/plugins/local/jira-toolkit/jira-helper.sh assign PROJ-123 username
```

### Transition Status
```bash
~/.claude/plugins/local/jira-toolkit/jira-helper.sh transition PROJ-123 "In Progress"
```

### Link Issues
```bash
~/.claude/plugins/local/jira-toolkit/jira-helper.sh link PROJ-123 "blocks" PROJ-456
```

### Manage Labels
```bash
~/.claude/plugins/local/jira-toolkit/jira-helper.sh labels PROJ-123 add bug critical
~/.claude/plugins/local/jira-toolkit/jira-helper.sh labels PROJ-123 remove outdated
```

### Log Work
```bash
~/.claude/plugins/local/jira-toolkit/jira-helper.sh worklog PROJ-123 "2h" "Work description"
```

### Watch/Unwatch
```bash
~/.claude/plugins/local/jira-toolkit/jira-helper.sh watch PROJ-123
~/.claude/plugins/local/jira-toolkit/jira-helper.sh unwatch PROJ-123
```

### List Projects
```bash
~/.claude/plugins/local/jira-toolkit/jira-helper.sh projects
```

### View Current User
```bash
~/.claude/plugins/local/jira-toolkit/jira-helper.sh me
```

## Your Task

Based on the user's request in $ARGUMENTS, determine what Jira operation they need and execute it using the helper script.

Common patterns:
- "search for my issues" → use search command (no args = your unresolved issues)
- "create a ticket/issue" → use create command
- "view PROJ-123" → use view command
- "update PROJ-123" → use update command
- "assign to me" → use assign command
- "move to In Progress" → use transition command
- "add comment" → use comment command
- "log work/time" → use worklog command
- "add label" → use labels command with add
- "link issues" → use link command

Execute the appropriate command and report the results back to the user.
