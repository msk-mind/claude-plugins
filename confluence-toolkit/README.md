# Confluence Toolkit Plugin

A comprehensive Claude Code plugin for working with Atlassian Confluence. This plugin provides skills and commands for creating, updating, searching, and managing Confluence documentation.

## Features

- **Search Confluence Content** - Use CQL (Confluence Query Language) to search pages and content
- **Create Pages** - Create new documentation pages with proper formatting
- **Update Pages** - Update existing pages with version control
- **Manage Spaces** - List and work with Confluence spaces
- **Work with Attachments** - Upload and manage page attachments
- **Content Formatting** - Support for Confluence storage format (HTML with macros)

## Setup

### Prerequisites

1. Confluence account with API access
2. API token generated from Atlassian account settings

### Configuration

Create a `~/.atlassian_env` file with your Confluence credentials:

```bash
export CONFLUENCE_URL=https://your-domain.atlassian.net/wiki/
export CONFLUENCE_USERNAME=your-email@example.com
export CONFLUENCE_API_TOKEN=your-api-token-here
```

**To generate an API token:**
1. Go to https://id.atlassian.com/manage-profile/security/api-tokens
2. Click "Create API token"
3. Give it a name and copy the token
4. Add it to your `~/.atlassian_env` file

### Permissions

Ensure the `~/.atlassian_env` file is only readable by you:

```bash
chmod 600 ~/.atlassian_env
```

## Installation

### Option 1: Copy to External Plugins Directory

If you have access to the Claude plugins marketplace directory:

```bash
cp -r ~/confluence-skill ~/.claude/plugins/marketplaces/claude-plugins-official/external_plugins/confluence-toolkit
```

### Option 2: Use as Local Plugin

Keep the plugin in your home directory and reference it directly. The plugin will automatically be available if placed in the correct location.

## Usage

### Available Skills

#### `/confluence-operations`

Comprehensive skill for all Confluence operations including:
- Creating and updating pages
- Searching content with CQL
- Managing spaces and attachments
- Working with page hierarchies

**Example usage:**
- "Search Confluence for authentication documentation"
- "Create a new page in the DOCS space called 'API Guide'"
- "Update the Release Notes page with new features"
- "Find all pages in the Engineering space"

## Skills Overview

### Confluence Operations

**When to use:**
- Need to create or update documentation
- Search for existing content
- Manage page hierarchies
- Work with attachments

**Common workflows:**
1. **Create Documentation**: Search for parent page → Create new child page
2. **Update Documentation**: Search for page → Get current version → Update content
3. **Search and Read**: Search with CQL → Get page content → Display results

## API Reference

This plugin uses the [Confluence REST API v2](https://developer.atlassian.com/cloud/confluence/rest/v2/intro/).

**Base Endpoint:** `${CONFLUENCE_URL}rest/api/`

**Authentication:** HTTP Basic Auth (username + API token)

## Examples

### Create a New Page

```bash
source ~/.atlassian_env

curl -u "$CONFLUENCE_USERNAME:$CONFLUENCE_API_TOKEN" \
  -X POST \
  "${CONFLUENCE_URL}rest/api/content" \
  -H "Content-Type: application/json" \
  -d '{
    "type": "page",
    "title": "My New Page",
    "space": {"key": "DOCS"},
    "body": {
      "storage": {
        "value": "<h1>Hello World</h1><p>This is my page content.</p>",
        "representation": "storage"
      }
    }
  }'
```

### Search for Pages

```bash
source ~/.atlassian_env

curl -u "$CONFLUENCE_USERNAME:$CONFLUENCE_API_TOKEN" \
  "${CONFLUENCE_URL}rest/api/content/search?cql=text~\"search term\""
```

### Update a Page

```bash
source ~/.atlassian_env

# Get current version
PAGE_ID="123456"
VERSION=$(curl -s -u "$CONFLUENCE_USERNAME:$CONFLUENCE_API_TOKEN" \
  "${CONFLUENCE_URL}rest/api/content/${PAGE_ID}?expand=version" | \
  jq -r '.version.number')

# Update with incremented version
curl -u "$CONFLUENCE_USERNAME:$CONFLUENCE_API_TOKEN" \
  -X PUT \
  "${CONFLUENCE_URL}rest/api/content/${PAGE_ID}" \
  -H "Content-Type: application/json" \
  -d "{
    \"id\": \"${PAGE_ID}\",
    \"type\": \"page\",
    \"title\": \"Updated Title\",
    \"version\": {\"number\": $((VERSION + 1))},
    \"body\": {
      \"storage\": {
        \"value\": \"<p>Updated content</p>\",
        \"representation\": \"storage\"
      }
    }
  }"
```

## Troubleshooting

### Common Issues

**"401 Unauthorized"**
- Verify your API token is correct in `~/.atlassian_env`
- Make sure you've sourced the environment file: `source ~/.atlassian_env`
- Check that the username matches the API token owner

**"409 Conflict" when updating**
- Version number might be incorrect
- Someone else may have updated the page
- Get the latest version and try again

**"404 Not Found"**
- Page ID or space key is incorrect
- Page may have been deleted or moved
- Check your permissions to access the page

### Debug Mode

Add the `-v` flag to curl commands to see detailed request/response information:

```bash
curl -v -u "$CONFLUENCE_USERNAME:$CONFLUENCE_API_TOKEN" \
  "${CONFLUENCE_URL}rest/api/content/${PAGE_ID}"
```

## Contributing

This is a local plugin. Feel free to modify and extend it for your needs.

## License

MIT License - Free to use and modify

## Resources

- [Confluence REST API Documentation](https://developer.atlassian.com/cloud/confluence/rest/v2/intro/)
- [Confluence Storage Format Guide](https://confluence.atlassian.com/doc/confluence-storage-format-790796544.html)
- [CQL (Confluence Query Language) Reference](https://developer.atlassian.com/cloud/confluence/advanced-searching-using-cql/)

## Support

For issues or questions about this plugin, please refer to the skill documentation in `skills/confluence-operations/SKILL.md`.
