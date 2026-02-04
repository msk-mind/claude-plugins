# Confluence Skill Installation Guide

## What Was Created

A complete Claude Code skill for working with Confluence has been created at:
`~/confluence-skill/`

### Directory Structure

```
~/confluence-skill/
├── .claude-plugin/
│   └── plugin.json           # Plugin metadata
├── skills/
│   └── confluence-operations/
│       └── SKILL.md          # Main skill documentation
├── confluence-helper.sh      # Bash helper script
└── README.md                 # Plugin documentation
```

## Installation

### Option 1: Install as External Plugin (Recommended)

Copy the plugin to Claude's external plugins directory:

```bash
# Copy to external plugins
cp -r ~/confluence-skill ~/.claude/plugins/marketplaces/claude-plugins-official/external_plugins/confluence-toolkit

# Restart Claude Code or reload plugins
```

### Option 2: Install to User Plugins (If Available)

If you have a local plugins directory:

```bash
# Check if local plugins directory exists
mkdir -p ~/.local/share/claude-code/plugins

# Copy plugin there
cp -r ~/confluence-skill ~/.local/share/claude-code/plugins/confluence-toolkit
```

### Option 3: Use Without Installation

You can use the helper script directly without installing as a plugin:

```bash
# Add to your PATH
echo 'export PATH="$HOME/confluence-skill:$PATH"' >> ~/.bashrc
source ~/.bashrc

# Now you can run:
confluence-helper.sh help
```

## Verification

After installation, verify the plugin is available:

```bash
# Check if plugin directory exists
ls ~/.claude/plugins/marketplaces/claude-plugins-official/external_plugins/confluence-toolkit

# Or check if the skill is loaded (restart Claude Code first)
# Then type: /confluence-operations
```

## Configuration

### 1. Ensure ~/.atlassian_env Exists

The file already exists at `~/.atlassian_env` with your credentials:

```bash
export CONFLUENCE_URL=https://your-confluence.example.com/
export CONFLUENCE_USERNAME=your-username
export CONFLUENCE_API_TOKEN=your-api-token-here
```

### 2. Verify Permissions

```bash
chmod 600 ~/.atlassian_env
```

### 3. Test Connection

```bash
# Source the environment
source ~/.atlassian_env

# Test with helper script
~/confluence-skill/confluence-helper.sh spaces
```

## Usage Examples

### Using the Helper Script

```bash
# List all spaces
~/confluence-skill/confluence-helper.sh spaces

# Search for pages
~/confluence-skill/confluence-helper.sh search 'text~"authentication"'

# Get a specific page
~/confluence-skill/confluence-helper.sh get 123456

# Create a new page
~/confluence-skill/confluence-helper.sh create DOCS "My Page" "<h1>Hello</h1><p>Content here</p>"

# Update a page
~/confluence-skill/confluence-helper.sh update 123456 "Updated Title" "<p>New content</p>"
```

### Using the Skill in Claude Code

Once installed as a plugin, you can use it in Claude Code:

```
User: /confluence-operations search for pages about authentication
Claude: [Uses the skill to search Confluence]

User: Create a new page in the DOCS space called "API Guide"
Claude: [Uses the skill to create the page]

User: Update the Release Notes page with version 2.5.0 information
Claude: [Uses the skill to update the page]
```

## Features

The skill provides comprehensive Confluence operations:

1. **Search** - CQL-based search across pages and spaces
2. **Read** - Get page content by ID or title
3. **Create** - Create new pages with proper formatting
4. **Update** - Update existing pages with version control
5. **Spaces** - List and manage Confluence spaces
6. **Attachments** - Upload and manage file attachments
7. **Hierarchy** - Work with parent/child page relationships

## API Operations Supported

All operations use the Confluence REST API:

- `GET /rest/api/content/search` - Search content
- `GET /rest/api/content/{id}` - Get page
- `POST /rest/api/content` - Create page
- `PUT /rest/api/content/{id}` - Update page
- `DELETE /rest/api/content/{id}` - Delete page
- `GET /rest/api/space` - List spaces
- `POST /rest/api/content/{id}/child/attachment` - Upload attachment

## Confluence Storage Format

The skill supports Confluence's storage format (HTML with macros):

```html
<h1>Heading</h1>
<p>Text with <strong>bold</strong> and <em>italic</em></p>
<ac:structured-macro ac:name="info">
  <ac:rich-text-body>
    <p>Info panel content</p>
  </ac:rich-text-body>
</ac:structured-macro>
```

## Troubleshooting

### Plugin Not Loading

1. Check that the directory structure is correct
2. Verify `plugin.json` exists in `.claude-plugin/`
3. Restart Claude Code completely
4. Check Claude Code logs for errors

### Authentication Errors

1. Verify `~/.atlassian_env` exists and is readable
2. Check that credentials are correct
3. Ensure the API token is valid
4. Source the environment before using: `source ~/.atlassian_env`

### Permission Issues

```bash
# Fix file permissions
chmod 600 ~/.atlassian_env
chmod +x ~/confluence-skill/confluence-helper.sh
chmod -R u+r ~/confluence-skill/
```

## Next Steps

1. **Test the Helper Script**:
   ```bash
   source ~/.atlassian_env
   ~/confluence-skill/confluence-helper.sh spaces
   ```

2. **Install as Plugin** (if desired):
   ```bash
   cp -r ~/confluence-skill ~/.claude/plugins/marketplaces/claude-plugins-official/external_plugins/confluence-toolkit
   ```

3. **Restart Claude Code** to load the new plugin

4. **Try the Skill**:
   - Type `/confluence-operations` to see if it's available
   - Ask Claude to search Confluence or create a page

## Additional Resources

- Skill Documentation: `~/confluence-skill/skills/confluence-operations/SKILL.md`
- Helper Script: `~/confluence-skill/confluence-helper.sh`
- Plugin README: `~/confluence-skill/README.md`
- Confluence REST API: https://developer.atlassian.com/cloud/confluence/rest/v2/
- CQL Reference: https://developer.atlassian.com/cloud/confluence/advanced-searching-using-cql/

## Support

For issues or modifications:
1. Check the SKILL.md for detailed usage instructions
2. Review the README.md for API reference
3. Test with the helper script first to verify connectivity
4. Check Claude Code logs for plugin loading errors
