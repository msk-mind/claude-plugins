#!/bin/bash

# Confluence Helper Script
# Uses credentials from ~/.atlassian_env

set -e

# Source environment variables
if [ -f ~/.atlassian_env ]; then
    source ~/.atlassian_env
else
    echo "Error: ~/.atlassian_env not found"
    echo "Please create it with CONFLUENCE_URL, CONFLUENCE_USERNAME, and CONFLUENCE_API_TOKEN"
    exit 1
fi

# Check required variables
if [ -z "$CONFLUENCE_URL" ] || [ -z "$CONFLUENCE_USERNAME" ] || [ -z "$CONFLUENCE_API_TOKEN" ]; then
    echo "Error: Missing required environment variables"
    echo "Required: CONFLUENCE_URL, CONFLUENCE_USERNAME, CONFLUENCE_API_TOKEN"
    exit 1
fi

# Function to search Confluence
confluence_search() {
    local query="$1"
    curl -s "${CONFLUENCE_URL}rest/api/content/search?cql=${query}" \
        -H "Authorization: Bearer $CONFLUENCE_API_TOKEN" \
        -H "Content-Type: application/json"
}

# Function to get page by ID
confluence_get_page() {
    local page_id="$1"
    curl -s "${CONFLUENCE_URL}rest/api/content/${page_id}?expand=body.storage,version,space" \
        -H "Authorization: Bearer $CONFLUENCE_API_TOKEN" \
        -H "Content-Type: application/json"
}

# Function to create page
confluence_create_page() {
    local space_key="$1"
    local title="$2"
    local content="$3"
    local parent_id="$4"

    local json_data="{
        \"type\": \"page\",
        \"title\": \"$title\",
        \"space\": {\"key\": \"$space_key\"},
        \"body\": {
            \"storage\": {
                \"value\": \"$content\",
                \"representation\": \"storage\"
            }
        }"

    if [ -n "$parent_id" ]; then
        json_data="${json_data},\"ancestors\": [{\"id\": \"$parent_id\"}]"
    fi

    json_data="${json_data}}"

    curl -s -X POST \
        "${CONFLUENCE_URL}rest/api/content" \
        -H "Authorization: Bearer $CONFLUENCE_API_TOKEN" \
        -H "Content-Type: application/json" \
        -d "$json_data"
}

# Function to update page
confluence_update_page() {
    local page_id="$1"
    local title="$2"
    local content="$3"

    # Get current version
    local current_version=$(confluence_get_page "$page_id" | jq -r '.version.number')
    local next_version=$((current_version + 1))

    curl -s -X PUT \
        "${CONFLUENCE_URL}rest/api/content/${page_id}" \
        -H "Authorization: Bearer $CONFLUENCE_API_TOKEN" \
        -H "Content-Type: application/json" \
        -d "{
            \"id\": \"$page_id\",
            \"type\": \"page\",
            \"title\": \"$title\",
            \"version\": {
                \"number\": $next_version,
                \"message\": \"Updated via script\"
            },
            \"body\": {
                \"storage\": {
                    \"value\": \"$content\",
                    \"representation\": \"storage\"
                }
            }
        }"
}

# Function to list spaces
confluence_list_spaces() {
    curl -s "${CONFLUENCE_URL}rest/api/space" \
        -H "Authorization: Bearer $CONFLUENCE_API_TOKEN" \
        -H "Content-Type: application/json"
}

# Main command dispatcher
case "${1:-help}" in
    search)
        if [ -z "$2" ]; then
            echo "Usage: $0 search <cql-query>"
            exit 1
        fi
        confluence_search "$2" | jq .
        ;;
    get)
        if [ -z "$2" ]; then
            echo "Usage: $0 get <page-id>"
            exit 1
        fi
        confluence_get_page "$2" | jq .
        ;;
    create)
        if [ -z "$2" ] || [ -z "$3" ] || [ -z "$4" ]; then
            echo "Usage: $0 create <space-key> <title> <content> [parent-id]"
            exit 1
        fi
        confluence_create_page "$2" "$3" "$4" "$5" | jq .
        ;;
    update)
        if [ -z "$2" ] || [ -z "$3" ] || [ -z "$4" ]; then
            echo "Usage: $0 update <page-id> <title> <content>"
            exit 1
        fi
        confluence_update_page "$2" "$3" "$4" | jq .
        ;;
    spaces)
        confluence_list_spaces | jq .
        ;;
    help|*)
        echo "Confluence Helper Script"
        echo ""
        echo "Usage: $0 <command> [options]"
        echo ""
        echo "Commands:"
        echo "  search <cql>              Search Confluence using CQL"
        echo "  get <page-id>             Get page by ID"
        echo "  create <space> <title> <content> [parent]"
        echo "                            Create new page"
        echo "  update <id> <title> <content>"
        echo "                            Update existing page"
        echo "  spaces                    List all spaces"
        echo "  help                      Show this help"
        echo ""
        echo "Examples:"
        echo "  $0 search 'text~\"authentication\"'"
        echo "  $0 get 123456"
        echo "  $0 spaces"
        ;;
esac
