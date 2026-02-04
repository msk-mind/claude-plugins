#!/bin/bash

# Confluence Helper Script
# Uses credentials from ~/.atlassian_env

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

# Ensure URL ends with /
[[ "$CONFLUENCE_URL" != */ ]] && CONFLUENCE_URL="${CONFLUENCE_URL}/"

# Helper function to make API calls and handle errors
api_call() {
    local method="$1"
    local endpoint="$2"
    local data="$3"

    local response
    local http_code

    if [ "$method" = "GET" ]; then
        response=$(curl -s -w "\n%{http_code}" \
            "${CONFLUENCE_URL}${endpoint}" \
            -H "Authorization: Bearer $CONFLUENCE_API_TOKEN" \
            -H "Content-Type: application/json")
    else
        response=$(curl -s -w "\n%{http_code}" -X "$method" \
            "${CONFLUENCE_URL}${endpoint}" \
            -H "Authorization: Bearer $CONFLUENCE_API_TOKEN" \
            -H "Content-Type: application/json" \
            -d "$data")
    fi

    # Extract HTTP code (last line) and body (everything else)
    http_code=$(echo "$response" | tail -n1)
    body=$(echo "$response" | sed '$d')

    # Check for HTTP errors
    if [[ "$http_code" -ge 400 ]]; then
        echo "Error: HTTP $http_code"
        echo "$body"
        return 1
    fi

    # Try to parse as JSON, if it fails just output raw
    if echo "$body" | jq . >/dev/null 2>&1; then
        echo "$body" | jq .
    else
        echo "$body"
    fi
}

# Function to search Confluence
confluence_search() {
    local query="$1"
    # URL encode the query
    local encoded_query=$(printf '%s' "$query" | jq -sRr @uri)
    api_call "GET" "rest/api/content/search?cql=${encoded_query}"
}

# Function to get page by ID
confluence_get_page() {
    local page_id="$1"
    api_call "GET" "rest/api/content/${page_id}?expand=body.storage,version,space"
}

# Function to create page
confluence_create_page() {
    local space_key="$1"
    local title="$2"
    local content="$3"
    local parent_id="$4"

    # Use jq to properly escape JSON
    local json_data
    if [ -n "$parent_id" ]; then
        json_data=$(jq -n \
            --arg type "page" \
            --arg title "$title" \
            --arg space_key "$space_key" \
            --arg content "$content" \
            --arg parent_id "$parent_id" \
            '{
                type: $type,
                title: $title,
                space: {key: $space_key},
                body: {storage: {value: $content, representation: "storage"}},
                ancestors: [{id: $parent_id}]
            }')
    else
        json_data=$(jq -n \
            --arg type "page" \
            --arg title "$title" \
            --arg space_key "$space_key" \
            --arg content "$content" \
            '{
                type: $type,
                title: $title,
                space: {key: $space_key},
                body: {storage: {value: $content, representation: "storage"}}
            }')
    fi

    api_call "POST" "rest/api/content" "$json_data"
}

# Function to update page
confluence_update_page() {
    local page_id="$1"
    local title="$2"
    local content="$3"

    # Get current version
    local page_info
    page_info=$(curl -s "${CONFLUENCE_URL}rest/api/content/${page_id}?expand=version" \
        -H "Authorization: Bearer $CONFLUENCE_API_TOKEN" \
        -H "Content-Type: application/json")

    local current_version
    current_version=$(echo "$page_info" | jq -r '.version.number // empty')

    if [ -z "$current_version" ]; then
        echo "Error: Could not get current version for page $page_id"
        echo "$page_info"
        return 1
    fi

    local next_version=$((current_version + 1))

    # Use jq to properly escape JSON
    local json_data
    json_data=$(jq -n \
        --arg id "$page_id" \
        --arg type "page" \
        --arg title "$title" \
        --argjson version "$next_version" \
        --arg content "$content" \
        '{
            id: $id,
            type: $type,
            title: $title,
            version: {number: $version, message: "Updated via script"},
            body: {storage: {value: $content, representation: "storage"}}
        }')

    api_call "PUT" "rest/api/content/${page_id}" "$json_data"
}

# Function to list spaces
confluence_list_spaces() {
    api_call "GET" "rest/api/space"
}

# Main command dispatcher
case "${1:-help}" in
    search)
        if [ -z "$2" ]; then
            echo "Usage: $0 search <cql-query>"
            exit 1
        fi
        confluence_search "$2"
        ;;
    get)
        if [ -z "$2" ]; then
            echo "Usage: $0 get <page-id>"
            exit 1
        fi
        confluence_get_page "$2"
        ;;
    create)
        if [ -z "$2" ] || [ -z "$3" ] || [ -z "$4" ]; then
            echo "Usage: $0 create <space-key> <title> <content> [parent-id]"
            exit 1
        fi
        confluence_create_page "$2" "$3" "$4" "$5"
        ;;
    update)
        if [ -z "$2" ] || [ -z "$3" ] || [ -z "$4" ]; then
            echo "Usage: $0 update <page-id> <title> <content>"
            exit 1
        fi
        confluence_update_page "$2" "$3" "$4"
        ;;
    spaces)
        confluence_list_spaces
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
