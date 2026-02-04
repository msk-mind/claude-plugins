# Confluence Toolkit

Claude Code plugin for working with Atlassian Confluence.

## Features

- **Search** - Find pages using CQL (Confluence Query Language)
- **Get Pages** - Retrieve page content by ID
- **Create Pages** - Create new documentation pages
- **Update Pages** - Update existing pages with version control
- **List Spaces** - View available Confluence spaces

## Setup

### 1. Create credentials file

Create `~/.atlassian_env`:

```bash
export CONFLUENCE_URL=https://your-confluence.example.com/
export CONFLUENCE_USERNAME=your-username
export CONFLUENCE_API_TOKEN=your-api-token
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
claude plugin install confluence-toolkit@msk-mind-plugins
```

Restart Claude Code after installation.

## Usage

Just ask Claude naturally:

- "Search Confluence for authentication docs"
- "Get the content of page 241631425"
- "List all Confluence spaces"
- "Create a page in DOCS space called 'API Guide'"

## Helper Script Commands

The plugin uses a helper script with these commands:

```bash
# Search pages
confluence-helper.sh search 'text~"keyword"'

# Get page by ID
confluence-helper.sh get PAGE_ID

# Create page
confluence-helper.sh create SPACE_KEY "Title" "Content" [PARENT_ID]

# Update page
confluence-helper.sh update PAGE_ID "New Title" "New Content"

# List spaces
confluence-helper.sh spaces
```

## CQL Query Examples

```bash
# Text search
'text~"authentication"'

# Search in specific space
'space=DOCS AND text~"api"'

# Find pages by title
'title~"Release Notes"'

# Recently modified
'lastModified > now("-7d")'
```

## Troubleshooting

### 401 Unauthorized
- Check your API token in `~/.atlassian_env`
- Verify CONFLUENCE_USERNAME matches the token owner

### 404 Not Found
- Verify the page ID or space key exists
- Check your permissions

### Parse errors
- Ensure the API returns valid JSON
- Check your CONFLUENCE_URL ends with `/`

## Dependencies

- `curl` - API requests
- `jq` - JSON parsing

## License

MIT
