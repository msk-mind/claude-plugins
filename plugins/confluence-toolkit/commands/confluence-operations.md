---
description: Work with Confluence pages - create, update, search, and manage documentation
argument-hint: [operation] [args...]
allowed-tools: Bash(confluence-helper.sh:*), Bash(*confluence-helper.sh:*)
---

# Confluence Operations

Work with Confluence pages using the Confluence REST API. All operations use credentials from `~/.atlassian_env`.

## Arguments

The user invoked this command with: $ARGUMENTS

## Helper Script Location

First, locate the confluence helper script:
```bash
CONFLUENCE_HELPER=$(ls ~/.claude/plugins/cache/msk-mind-plugins/confluence-toolkit/*/confluence-helper.sh 2>/dev/null | head -1)
```

Then use `$CONFLUENCE_HELPER` for all operations below.

## Common Operations

### Search Confluence
```bash
$CONFLUENCE_HELPER search "query text"
$CONFLUENCE_HELPER search 'text~"keyword"'
```

### Get Page Content
```bash
$CONFLUENCE_HELPER get PAGE_ID
```

### Create Page
```bash
$CONFLUENCE_HELPER create SPACE_KEY "Page Title" "Page content here"
$CONFLUENCE_HELPER create SPACE_KEY "Page Title" "Content" PARENT_ID
```

### Update Page
```bash
$CONFLUENCE_HELPER update PAGE_ID "New Title" "New content"
```

### List Spaces
```bash
$CONFLUENCE_HELPER spaces
```

## Your Task

Based on the user's request in $ARGUMENTS, determine what Confluence operation they need and execute it.

**IMPORTANT**: First run this to get the helper path:
```bash
CONFLUENCE_HELPER=$(ls ~/.claude/plugins/cache/msk-mind-plugins/confluence-toolkit/*/confluence-helper.sh 2>/dev/null | head -1) && echo "Helper: $CONFLUENCE_HELPER"
```

Then execute the appropriate command using `$CONFLUENCE_HELPER` and report the results.

Common patterns:
- "search for X" → use `search` command
- "create a page" → use `create` command
- "update page ID" → use `update` command
- "get content from" → use `get` command
- "list spaces" → use `spaces` command
