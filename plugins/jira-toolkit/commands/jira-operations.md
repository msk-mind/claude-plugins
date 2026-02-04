---
description: Work with Jira issues - create, update, search, assign, and manage issues
argument-hint: [operation] [args...]
allowed-tools: Bash(jira-helper.sh:*), Bash(*jira-helper.sh:*)
---

# Jira Operations

Work with Jira issues using the Jira REST API. All operations use credentials from `~/.atlassian_env`.

## Arguments

The user invoked this command with: $ARGUMENTS

## Helper Script Location

First, locate the jira helper script:
```bash
JIRA_HELPER=$(ls ~/.claude/plugins/cache/msk-mind-plugins/jira-toolkit/*/jira-helper.sh 2>/dev/null | head -1)
```

Then use `$JIRA_HELPER` for all operations below.

## Common Operations

### Search Issues (JQL)
```bash
$JIRA_HELPER search
$JIRA_HELPER search "assignee=currentUser() AND status='In Progress'"
$JIRA_HELPER search "project=MYPROJ AND type=Bug"
```

### View Issue
```bash
$JIRA_HELPER view PROJ-123
```

### Create Issue
```bash
$JIRA_HELPER create PROJECT Bug "Summary" "Description"
```

### Update Issue
```bash
$JIRA_HELPER update PROJ-123 --summary "New title" --priority "High"
```

### Add Comment
```bash
$JIRA_HELPER comment PROJ-123 "Comment text"
```

### Assign Issue
```bash
$JIRA_HELPER assign PROJ-123 username
```

### Transition Status
```bash
$JIRA_HELPER transition PROJ-123 "In Progress"
```

### Link Issues
```bash
$JIRA_HELPER link PROJ-123 "blocks" PROJ-456
```

### Manage Labels
```bash
$JIRA_HELPER labels PROJ-123 add bug critical
$JIRA_HELPER labels PROJ-123 remove outdated
```

### Log Work
```bash
$JIRA_HELPER worklog PROJ-123 "2h" "Work description"
```

### Watch/Unwatch
```bash
$JIRA_HELPER watch PROJ-123
$JIRA_HELPER unwatch PROJ-123
```

### List Projects
```bash
$JIRA_HELPER projects
```

### View Current User
```bash
$JIRA_HELPER me
```

## Your Task

Based on the user's request in $ARGUMENTS, determine what Jira operation they need and execute it.

**IMPORTANT**: First run this to get the helper path:
```bash
JIRA_HELPER=$(ls ~/.claude/plugins/cache/msk-mind-plugins/jira-toolkit/*/jira-helper.sh 2>/dev/null | head -1) && echo "Helper: $JIRA_HELPER"
```

Then execute the appropriate command using `$JIRA_HELPER` and report the results.

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
