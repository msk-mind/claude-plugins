# Confluence Skill Quick Start

## What You Have

A complete Confluence skill for Claude Code has been created at:
**`~/confluence-skill/`**

## Files Created

```
~/confluence-skill/
├── .claude-plugin/
│   └── plugin.json                      # Plugin metadata
├── skills/
│   └── confluence-operations/
│       └── SKILL.md                     # Complete skill documentation (18KB)
├── confluence-helper.sh                 # Bash helper script (executable)
├── README.md                            # Plugin documentation
├── INSTALL.md                           # Installation guide
└── QUICKSTART.md                        # This file
```

## Quick Test

Test the helper script immediately:

```bash
# 1. Source your environment (already exists)
source ~/.atlassian_env

# 2. Test listing spaces
/home/limr/confluence-skill/confluence-helper.sh spaces

# 3. Search for pages
/home/limr/confluence-skill/confluence-helper.sh search 'type=page'
```

## Install as Claude Skill (Optional)

To use this as a skill in Claude Code:

```bash
# Copy to external plugins directory
cp -r ~/confluence-skill ~/.claude/plugins/marketplaces/claude-plugins-official/external_plugins/confluence-toolkit

# Restart Claude Code
# Then you can use: /confluence-operations
```

## What the Skill Does

### 1. Search Confluence
```bash
# Search using CQL (Confluence Query Language)
./confluence-helper.sh search 'text~"authentication"'
./confluence-helper.sh search 'space=DOCS AND type=page'
./confluence-helper.sh search 'title~"Release Notes"'
```

### 2. Get Page Content
```bash
# Get a page by ID
./confluence-helper.sh get 123456
```

### 3. Create New Pages
```bash
# Create a new page
./confluence-helper.sh create DOCS "My Page Title" "<h1>Heading</h1><p>Content</p>"

# Create with parent page
./confluence-helper.sh create DOCS "Child Page" "<p>Content</p>" 123456
```

### 4. Update Pages
```bash
# Update existing page (automatically increments version)
./confluence-helper.sh update 123456 "Updated Title" "<p>New content</p>"
```

### 5. List Spaces
```bash
# List all Confluence spaces
./confluence-helper.sh spaces
```

## Your Environment

Your `~/.atlassian_env` file already contains:
- CONFLUENCE_URL: https://mskconfluence.mskcc.org/
- CONFLUENCE_USERNAME: limr
- CONFLUENCE_API_TOKEN: (configured)

## Common CQL Search Examples

```bash
# Find pages in specific space
search 'space=DOCS'

# Search by text content
search 'text~"authentication"'

# Search by title
search 'title~"Release Notes"'

# Combine criteria
search 'space=DOCS AND text~"API" AND type=page'

# Filter by date
search 'created >= "2024-01-01"'

# Filter by creator
search 'creator=limr'
```

## Confluence Content Format

When creating/updating pages, use Confluence storage format (HTML):

```html
<!-- Basic formatting -->
<h1>Heading 1</h1>
<h2>Heading 2</h2>
<p>Regular text with <strong>bold</strong> and <em>italic</em></p>

<!-- Lists -->
<ul>
  <li>Item 1</li>
  <li>Item 2</li>
</ul>

<!-- Info panels -->
<ac:structured-macro ac:name="info">
  <ac:rich-text-body>
    <p>This is an info panel</p>
  </ac:rich-text-body>
</ac:structured-macro>

<!-- Code blocks -->
<ac:structured-macro ac:name="code">
  <ac:parameter ac:name="language">python</ac:parameter>
  <ac:plain-text-body><![CDATA[
def hello():
    print("Hello!")
  ]]></ac:plain-text-body>
</ac:structured-macro>
```

## API Operations

The helper script uses the Confluence REST API:

| Operation | Endpoint | Method |
|-----------|----------|--------|
| Search | `/rest/api/content/search` | GET |
| Get page | `/rest/api/content/{id}` | GET |
| Create page | `/rest/api/content` | POST |
| Update page | `/rest/api/content/{id}` | PUT |
| List spaces | `/rest/api/space` | GET |

## Troubleshooting

### Authentication Error
```bash
# Verify environment is sourced
source ~/.atlassian_env

# Check variables are set
echo $CONFLUENCE_URL
echo $CONFLUENCE_USERNAME
```

### Page Not Found (404)
- Verify the page ID is correct
- Check you have permission to view the page
- Ensure the page hasn't been deleted

### Version Conflict (409)
- Someone else may have updated the page
- The script automatically gets the current version
- Try the update again

## Next Steps

1. **Test the helper script**:
   ```bash
   source ~/.atlassian_env
   /home/limr/confluence-skill/confluence-helper.sh spaces
   ```

2. **Read the full documentation**:
   - `~/confluence-skill/skills/confluence-operations/SKILL.md` - Complete skill guide
   - `~/confluence-skill/README.md` - Plugin overview
   - `~/confluence-skill/INSTALL.md` - Installation instructions

3. **Install as Claude skill** (optional):
   ```bash
   cp -r ~/confluence-skill ~/.claude/plugins/marketplaces/claude-plugins-official/external_plugins/confluence-toolkit
   ```

4. **Add to PATH** (optional):
   ```bash
   echo 'export PATH="$HOME/confluence-skill:$PATH"' >> ~/.bashrc
   source ~/.bashrc
   # Now you can just run: confluence-helper.sh help
   ```

## Examples

### Create Release Notes
```bash
source ~/.atlassian_env

/home/limr/confluence-skill/confluence-helper.sh create \
  DOCS \
  "Release Notes v2.5.0" \
  "<h1>Release Notes v2.5.0</h1>
   <h2>New Features</h2>
   <ul>
     <li>Feature 1</li>
     <li>Feature 2</li>
   </ul>
   <h2>Bug Fixes</h2>
   <ul>
     <li>Fixed authentication issue</li>
   </ul>"
```

### Search and Read
```bash
source ~/.atlassian_env

# Search for pages
/home/limr/confluence-skill/confluence-helper.sh search 'text~"slurm"' | jq '.results[] | {id, title}'

# Get specific page (replace with actual ID)
/home/limr/confluence-skill/confluence-helper.sh get 123456 | jq '.body.storage.value'
```

### Update Documentation
```bash
source ~/.atlassian_env

# Update a page
/home/limr/confluence-skill/confluence-helper.sh update \
  123456 \
  "Updated Documentation" \
  "<p>This documentation was updated on $(date)</p>"
```

## Resources

- **Confluence REST API**: https://developer.atlassian.com/cloud/confluence/rest/v2/
- **CQL Reference**: https://developer.atlassian.com/cloud/confluence/advanced-searching-using-cql/
- **Storage Format**: https://confluence.atlassian.com/doc/confluence-storage-format-790796544.html

## Support

For detailed usage, see the full SKILL.md documentation:
```bash
less ~/confluence-skill/skills/confluence-operations/SKILL.md
```

---

**Ready to use!** Start with:
```bash
source ~/.atlassian_env && /home/limr/confluence-skill/confluence-helper.sh spaces
```
