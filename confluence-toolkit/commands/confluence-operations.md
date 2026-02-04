---
description: Work with Confluence pages - create, update, search, and manage documentation
argument-hint: [operation] [args...]
allowed-tools: Bash(confluence-helper.sh:*)
---

# Confluence Operations

Work with Confluence pages using the Confluence REST API. All operations use credentials from `~/.atlassian_env`.

## Arguments

The user invoked this command with: $ARGUMENTS

## Available Helper Script

Use the confluence helper script at:
```
~/.claude/plugins/local/confluence-toolkit/confluence-helper.sh
```

## Common Operations

### Search Confluence
```bash
~/.claude/plugins/local/confluence-toolkit/confluence-helper.sh search "query text"
~/.claude/plugins/local/confluence-toolkit/confluence-helper.sh search "space=MYSPACE AND title~'keyword'"
```

### Get Page Content
```bash
~/.claude/plugins/local/confluence-toolkit/confluence-helper.sh get-page PAGE_ID
```

### Create Page
```bash
~/.claude/plugins/local/confluence-toolkit/confluence-helper.sh create-page SPACE_KEY "Page Title" "Page content here"
```

### Update Page
```bash
~/.claude/plugins/local/confluence-toolkit/confluence-helper.sh update-page PAGE_ID "New content"
```

### List Spaces
```bash
~/.claude/plugins/local/confluence-toolkit/confluence-helper.sh list-spaces
```

## Your Task

Based on the user's request in $ARGUMENTS, determine what Confluence operation they need and execute it using the helper script.

Common patterns:
- "search for X" → use search command
- "create a page" → use create-page command
- "update page ID" → use update-page command
- "get content from" → use get-page command
- "list spaces" → use list-spaces command

Execute the appropriate command and report the results back to the user.
