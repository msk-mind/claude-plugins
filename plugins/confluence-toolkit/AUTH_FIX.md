# Authentication Fix

## Issue

The initial helper script used HTTP Basic Authentication (`-u username:token`), but the MSK Confluence instance has Basic Authentication disabled, returning:

```json
{
  "message": "Basic Authentication has been disabled on this instance."
}
```

## Solution

Updated the helper script to use **Bearer Token authentication** instead:

### Before (Basic Auth - Not Working)
```bash
curl -u "$CONFLUENCE_USERNAME:$CONFLUENCE_API_TOKEN" \
  "${CONFLUENCE_URL}rest/api/space"
```

### After (Bearer Token - Working)
```bash
curl -H "Authorization: Bearer $CONFLUENCE_API_TOKEN" \
  "${CONFLUENCE_URL}rest/api/space"
```

## Changes Made

Updated all API calls in `/home/limr/confluence-skill/confluence-helper.sh`:

1. **confluence_search()** - Now uses Bearer token
2. **confluence_get_page()** - Now uses Bearer token
3. **confluence_create_page()** - Now uses Bearer token
4. **confluence_update_page()** - Now uses Bearer token
5. **confluence_list_spaces()** - Now uses Bearer token

## Test Result

The script now works correctly:

```bash
$ source ~/.atlassian_env
$ /home/limr/confluence-skill/confluence-helper.sh spaces | jq '.results[0:3]'
```

Returns successful response with spaces:
```json
{
  "key": "AAA",
  "name": "AAA",
  "type": "global"
}
{
  "key": "~ParikhA",
  "name": "Aalap Parikh",
  "type": "personal"
}
{
  "key": "ADSRnD",
  "name": "ADS R&D",
  "type": "global"
}
```

## Note for SKILL.md

The SKILL.md documentation still references Basic Authentication in examples. For MSK Confluence, users should use Bearer token authentication instead:

**Replace:**
```bash
curl -u "$CONFLUENCE_USERNAME:$CONFLUENCE_API_TOKEN" ...
```

**With:**
```bash
curl -H "Authorization: Bearer $CONFLUENCE_API_TOKEN" ...
```

The helper script (`confluence-helper.sh`) has been updated and works correctly with Bearer tokens.
