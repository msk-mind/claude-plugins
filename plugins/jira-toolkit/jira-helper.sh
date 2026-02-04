#!/bin/bash

# Load Jira credentials
if [ -f ~/.atlassian_env ]; then
    source ~/.atlassian_env
else
    echo "Error: ~/.atlassian_env not found"
    exit 1
fi

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Helper function to make Jira API calls
jira_api() {
    local endpoint="$1"
    local method="${2:-GET}"
    local data="$3"

    if [ -n "$data" ]; then
        curl -s -X "$method" \
            -H "Authorization: Bearer $JIRA_API_TOKEN" \
            -H "Content-Type: application/json" \
            -d "$data" \
            "$JIRA_URL/rest/api/2/$endpoint"
    else
        curl -s -X "$method" \
            -H "Authorization: Bearer $JIRA_API_TOKEN" \
            -H "Content-Type: application/json" \
            "$JIRA_URL/rest/api/2/$endpoint"
    fi
}

# Format and display issue
display_issue() {
    local issue_json="$1"

    key=$(echo "$issue_json" | jq -r '.key')
    summary=$(echo "$issue_json" | jq -r '.fields.summary')
    status=$(echo "$issue_json" | jq -r '.fields.status.name')
    assignee=$(echo "$issue_json" | jq -r '.fields.assignee.displayName // "Unassigned"')
    reporter=$(echo "$issue_json" | jq -r '.fields.reporter.displayName')
    priority=$(echo "$issue_json" | jq -r '.fields.priority.name // "None"')
    created=$(echo "$issue_json" | jq -r '.fields.created')

    echo -e "${BLUE}[$key]${NC} $summary"
    echo -e "  Status: ${YELLOW}$status${NC}"
    echo -e "  Assignee: $assignee"
    echo -e "  Reporter: $reporter"
    echo -e "  Priority: $priority"
    echo -e "  Created: $created"
    echo ""
}

# Command: search
cmd_search() {
    local jql="$*"

    if [ -z "$jql" ]; then
        jql="assignee=currentUser() AND resolution=Unresolved ORDER BY updated DESC"
    fi

    echo -e "${BLUE}Searching Jira with JQL:${NC} $jql\n"

    # URL encode the JQL
    jql_encoded=$(printf %s "$jql" | jq -sRr @uri)

    result=$(jira_api "search?jql=$jql_encoded&maxResults=10")

    total=$(echo "$result" | jq -r '.total')

    if [ "$total" -eq 0 ]; then
        echo "No issues found."
        return
    fi

    echo -e "${GREEN}Found $total issue(s):${NC}\n"

    echo "$result" | jq -c '.issues[]' | while read -r issue; do
        display_issue "$issue"
    done
}

# Command: view
cmd_view() {
    local issue_key="$1"

    if [ -z "$issue_key" ]; then
        echo "Error: Issue key required"
        echo "Usage: jira view [ISSUE-KEY]"
        return 1
    fi

    result=$(jira_api "issue/$issue_key")

    if echo "$result" | jq -e '.errorMessages' > /dev/null 2>&1; then
        echo -e "${RED}Error:${NC}" $(echo "$result" | jq -r '.errorMessages[]')
        return 1
    fi

    display_issue "$result"

    # Show description if available
    description=$(echo "$result" | jq -r '.fields.description // ""')
    if [ -n "$description" ] && [ "$description" != "null" ]; then
        echo -e "${BLUE}Description:${NC}"
        echo "$description" | head -20
        echo ""
    fi

    # Show comments
    comments=$(echo "$result" | jq -r '.fields.comment.comments | length')
    if [ "$comments" -gt 0 ]; then
        echo -e "${BLUE}Recent Comments ($comments):${NC}"
        echo "$result" | jq -r '.fields.comment.comments[-3:] | .[] | "  [\(.author.displayName)] \(.body)"' | head -20
    fi
}

# Command: comment
cmd_comment() {
    local issue_key="$1"
    shift
    local comment_text="$*"

    if [ -z "$issue_key" ] || [ -z "$comment_text" ]; then
        echo "Error: Issue key and comment text required"
        echo "Usage: jira comment [ISSUE-KEY] [comment text]"
        return 1
    fi

    data=$(jq -n --arg body "$comment_text" '{body: $body}')

    result=$(jira_api "issue/$issue_key/comment" "POST" "$data")

    if echo "$result" | jq -e '.errorMessages' > /dev/null 2>&1; then
        echo -e "${RED}Error:${NC}" $(echo "$result" | jq -r '.errorMessages[]')
        return 1
    fi

    echo -e "${GREEN}Comment added to $issue_key${NC}"
}

# Command: assign
cmd_assign() {
    local issue_key="$1"
    local username="$2"

    if [ -z "$issue_key" ] || [ -z "$username" ]; then
        echo "Error: Issue key and username required"
        echo "Usage: jira assign [ISSUE-KEY] [username]"
        return 1
    fi

    data=$(jq -n --arg name "$username" '{name: $name}')

    result=$(jira_api "issue/$issue_key/assignee" "PUT" "$data")

    if [ -n "$result" ] && echo "$result" | jq -e '.errorMessages' > /dev/null 2>&1; then
        echo -e "${RED}Error:${NC}" $(echo "$result" | jq -r '.errorMessages[]')
        return 1
    fi

    echo -e "${GREEN}$issue_key assigned to $username${NC}"
}

# Command: transition
cmd_transition() {
    local issue_key="$1"
    local status_name="$2"

    if [ -z "$issue_key" ] || [ -z "$status_name" ]; then
        echo "Error: Issue key and status required"
        echo "Usage: jira transition [ISSUE-KEY] [status]"
        return 1
    fi

    # Get available transitions
    transitions=$(jira_api "issue/$issue_key/transitions")

    # Find matching transition ID
    transition_id=$(echo "$transitions" | jq -r --arg status "$status_name" \
        '.transitions[] | select(.name | ascii_downcase == ($status | ascii_downcase)) | .id')

    if [ -z "$transition_id" ]; then
        echo -e "${RED}Error: Status '$status_name' not available${NC}"
        echo -e "\nAvailable transitions:"
        echo "$transitions" | jq -r '.transitions[] | "  - \(.name)"'
        return 1
    fi

    data=$(jq -n --arg id "$transition_id" '{transition: {id: $id}}')

    result=$(jira_api "issue/$issue_key/transitions" "POST" "$data")

    if [ -n "$result" ] && echo "$result" | jq -e '.errorMessages' > /dev/null 2>&1; then
        echo -e "${RED}Error:${NC}" $(echo "$result" | jq -r '.errorMessages[]')
        return 1
    fi

    echo -e "${GREEN}$issue_key transitioned to $status_name${NC}"
}

# Command: create
cmd_create() {
    local project="$1"
    local issue_type="$2"
    local summary="$3"
    shift 3
    local description="$*"

    if [ -z "$project" ] || [ -z "$issue_type" ] || [ -z "$summary" ]; then
        echo "Error: Project, issue type, and summary required"
        echo "Usage: jira create [PROJECT-KEY] [issue-type] [summary] [description]"
        echo "Example: jira create CDSIENG24 Task 'Fix bug in API' 'This is the description'"
        return 1
    fi

    data=$(jq -n \
        --arg project "$project" \
        --arg type "$issue_type" \
        --arg summary "$summary" \
        --arg description "$description" \
        '{
            fields: {
                project: {key: $project},
                issuetype: {name: $type},
                summary: $summary,
                description: $description
            }
        }')

    result=$(jira_api "issue" "POST" "$data")

    if echo "$result" | jq -e '.errorMessages' > /dev/null 2>&1; then
        echo -e "${RED}Error:${NC}" $(echo "$result" | jq -r '.errorMessages[]')
        echo -e "${RED}Errors:${NC}" $(echo "$result" | jq -r '.errors | to_entries[] | "\(.key): \(.value)"')
        return 1
    fi

    issue_key=$(echo "$result" | jq -r '.key')
    echo -e "${GREEN}Created issue: $issue_key${NC}"
    echo "$JIRA_URL/browse/$issue_key"
}

# Command: update
cmd_update() {
    local issue_key="$1"
    shift

    if [ -z "$issue_key" ]; then
        echo "Error: Issue key required"
        echo "Usage: jira update [ISSUE-KEY] --summary 'text' --description 'text' --priority 'High'"
        return 1
    fi

    local update_fields=""

    while [ $# -gt 0 ]; do
        case "$1" in
            --summary)
                update_fields="$update_fields,\"summary\":\"$2\""
                shift 2
                ;;
            --description)
                update_fields="$update_fields,\"description\":\"$2\""
                shift 2
                ;;
            --priority)
                update_fields="$update_fields,\"priority\":{\"name\":\"$2\"}"
                shift 2
                ;;
            *)
                echo "Unknown option: $1"
                return 1
                ;;
        esac
    done

    if [ -z "$update_fields" ]; then
        echo "Error: No fields to update"
        echo "Usage: jira update [ISSUE-KEY] --summary 'text' --description 'text' --priority 'High'"
        return 1
    fi

    # Remove leading comma
    update_fields="${update_fields:1}"

    data="{\"fields\":{$update_fields}}"

    result=$(jira_api "issue/$issue_key" "PUT" "$data")

    if [ -n "$result" ] && echo "$result" | jq -e '.errorMessages' > /dev/null 2>&1; then
        echo -e "${RED}Error:${NC}" $(echo "$result" | jq -r '.errorMessages[]')
        return 1
    fi

    echo -e "${GREEN}$issue_key updated${NC}"
}

# Command: link
cmd_link() {
    local issue_key="$1"
    local link_type="$2"
    local target_key="$3"

    if [ -z "$issue_key" ] || [ -z "$link_type" ] || [ -z "$target_key" ]; then
        echo "Error: Issue key, link type, and target key required"
        echo "Usage: jira link [ISSUE-KEY] [link-type] [TARGET-KEY]"
        echo "Common link types: relates to, blocks, is blocked by, duplicates"
        return 1
    fi

    data=$(jq -n \
        --arg type "$link_type" \
        --arg inward "$issue_key" \
        --arg outward "$target_key" \
        '{
            type: {name: $type},
            inwardIssue: {key: $inward},
            outwardIssue: {key: $outward}
        }')

    result=$(jira_api "issueLink" "POST" "$data")

    if echo "$result" | jq -e '.errorMessages' > /dev/null 2>&1; then
        echo -e "${RED}Error:${NC}" $(echo "$result" | jq -r '.errorMessages[]')
        return 1
    fi

    echo -e "${GREEN}Linked $issue_key to $target_key ($link_type)${NC}"
}

# Command: watch
cmd_watch() {
    local issue_key="$1"

    if [ -z "$issue_key" ]; then
        echo "Error: Issue key required"
        echo "Usage: jira watch [ISSUE-KEY]"
        return 1
    fi

    result=$(jira_api "issue/$issue_key/watchers" "POST" "\"$JIRA_USERNAME\"")

    if echo "$result" | jq -e '.errorMessages' > /dev/null 2>&1; then
        echo -e "${RED}Error:${NC}" $(echo "$result" | jq -r '.errorMessages[]')
        return 1
    fi

    echo -e "${GREEN}Now watching $issue_key${NC}"
}

# Command: unwatch
cmd_unwatch() {
    local issue_key="$1"

    if [ -z "$issue_key" ]; then
        echo "Error: Issue key required"
        echo "Usage: jira unwatch [ISSUE-KEY]"
        return 1
    fi

    result=$(jira_api "issue/$issue_key/watchers?username=$JIRA_USERNAME" "DELETE")

    if [ -n "$result" ] && echo "$result" | jq -e '.errorMessages' > /dev/null 2>&1; then
        echo -e "${RED}Error:${NC}" $(echo "$result" | jq -r '.errorMessages[]')
        return 1
    fi

    echo -e "${GREEN}Stopped watching $issue_key${NC}"
}

# Command: projects
cmd_projects() {
    echo -e "${BLUE}Fetching projects...${NC}\n"

    result=$(jira_api "project")

    if echo "$result" | jq -e '.errorMessages' > /dev/null 2>&1; then
        echo -e "${RED}Error:${NC}" $(echo "$result" | jq -r '.errorMessages[]')
        return 1
    fi

    echo "$result" | jq -r '.[] | "\(.key) - \(.name)"' | sort
}

# Command: sprint
cmd_sprint() {
    local board_id="$1"

    if [ -z "$board_id" ]; then
        echo "Error: Board ID required"
        echo "Usage: jira sprint [BOARD-ID]"
        return 1
    fi

    echo -e "${BLUE}Fetching active sprints for board $board_id...${NC}\n"

    result=$(jira_api "board/$board_id/sprint?state=active")

    if echo "$result" | jq -e '.errorMessages' > /dev/null 2>&1; then
        echo -e "${RED}Error:${NC}" $(echo "$result" | jq -r '.errorMessages[]')
        return 1
    fi

    echo "$result" | jq -r '.values[] | "Sprint: \(.name)\nID: \(.id)\nState: \(.state)\nStart: \(.startDate // "Not started")\nEnd: \(.endDate // "Not set")\n"'
}

# Command: worklog
cmd_worklog() {
    local issue_key="$1"
    local time_spent="$2"
    shift 2
    local comment="$*"

    if [ -z "$issue_key" ] || [ -z "$time_spent" ]; then
        echo "Error: Issue key and time spent required"
        echo "Usage: jira worklog [ISSUE-KEY] [time-spent] [comment]"
        echo "Example: jira worklog PROJ-123 2h 'Working on implementation'"
        echo "Time format: 1d, 2h, 30m"
        return 1
    fi

    data=$(jq -n \
        --arg time "$time_spent" \
        --arg comment "$comment" \
        '{
            timeSpent: $time,
            comment: $comment
        }')

    result=$(jira_api "issue/$issue_key/worklog" "POST" "$data")

    if echo "$result" | jq -e '.errorMessages' > /dev/null 2>&1; then
        echo -e "${RED}Error:${NC}" $(echo "$result" | jq -r '.errorMessages[]')
        return 1
    fi

    echo -e "${GREEN}Logged $time_spent on $issue_key${NC}"
}

# Command: labels
cmd_labels() {
    local issue_key="$1"
    shift
    local operation="$1"
    shift
    local labels="$@"

    if [ -z "$issue_key" ] || [ -z "$operation" ]; then
        echo "Error: Issue key and operation required"
        echo "Usage: jira labels [ISSUE-KEY] [add|remove|set] [label1] [label2] ..."
        return 1
    fi

    case "$operation" in
        add)
            local update_data=""
            for label in $labels; do
                update_data="$update_data,{\"add\":\"$label\"}"
            done
            update_data="${update_data:1}"
            data="{\"update\":{\"labels\":[$update_data]}}"
            ;;
        remove)
            local update_data=""
            for label in $labels; do
                update_data="$update_data,{\"remove\":\"$label\"}"
            done
            update_data="${update_data:1}"
            data="{\"update\":{\"labels\":[$update_data]}}"
            ;;
        set)
            local label_array=""
            for label in $labels; do
                label_array="$label_array,\"$label\""
            done
            label_array="${label_array:1}"
            data="{\"fields\":{\"labels\":[$label_array]}}"
            ;;
        *)
            echo "Error: Invalid operation. Use add, remove, or set"
            return 1
            ;;
    esac

    result=$(jira_api "issue/$issue_key" "PUT" "$data")

    if [ -n "$result" ] && echo "$result" | jq -e '.errorMessages' > /dev/null 2>&1; then
        echo -e "${RED}Error:${NC}" $(echo "$result" | jq -r '.errorMessages[]')
        return 1
    fi

    echo -e "${GREEN}Labels updated for $issue_key${NC}"
}

# Command: me
cmd_me() {
    result=$(jira_api "myself")

    if echo "$result" | jq -e '.errorMessages' > /dev/null 2>&1; then
        echo -e "${RED}Error:${NC}" $(echo "$result" | jq -r '.errorMessages[]')
        return 1
    fi

    echo -e "${BLUE}User Information:${NC}"
    echo "$result" | jq -r '"Name: \(.displayName)\nUsername: \(.name)\nEmail: \(.emailAddress)\nTimezone: \(.timeZone)\nActive: \(.active)"'
}

# Main command router
main() {
    local command="$1"
    shift

    case "$command" in
        search)
            cmd_search "$@"
            ;;
        view)
            cmd_view "$@"
            ;;
        comment)
            cmd_comment "$@"
            ;;
        assign)
            cmd_assign "$@"
            ;;
        transition)
            cmd_transition "$@"
            ;;
        create)
            cmd_create "$@"
            ;;
        update)
            cmd_update "$@"
            ;;
        link)
            cmd_link "$@"
            ;;
        watch)
            cmd_watch "$@"
            ;;
        unwatch)
            cmd_unwatch "$@"
            ;;
        projects)
            cmd_projects "$@"
            ;;
        sprint)
            cmd_sprint "$@"
            ;;
        worklog)
            cmd_worklog "$@"
            ;;
        labels)
            cmd_labels "$@"
            ;;
        me)
            cmd_me "$@"
            ;;
        help|--help|-h)
            echo "Jira Skill - Comprehensive Jira CLI Tool"
            echo ""
            echo "USAGE:"
            echo "  jira [command] [options]"
            echo ""
            echo "COMMANDS:"
            echo "  search [JQL]                    - Search for issues using JQL"
            echo "  view [ISSUE-KEY]                - View detailed issue information"
            echo "  create [PROJECT] [TYPE] [SUMMARY] [DESC] - Create new issue"
            echo "  update [ISSUE-KEY] --field val  - Update issue fields"
            echo "  comment [ISSUE-KEY] [text]      - Add comment to issue"
            echo "  assign [ISSUE-KEY] [username]   - Assign issue to user"
            echo "  transition [ISSUE-KEY] [status] - Change issue status"
            echo "  link [ISSUE-KEY] [type] [TARGET] - Link two issues"
            echo "  watch [ISSUE-KEY]               - Watch an issue"
            echo "  unwatch [ISSUE-KEY]             - Stop watching an issue"
            echo "  worklog [ISSUE-KEY] [time] [comment] - Log work time"
            echo "  labels [ISSUE-KEY] [add|remove|set] [labels] - Manage labels"
            echo "  projects                        - List all projects"
            echo "  sprint [BOARD-ID]               - View active sprints"
            echo "  me                              - Show current user info"
            echo "  help                            - Show this help message"
            echo ""
            echo "EXAMPLES:"
            echo "  jira search 'project=CDSIENG24 AND status=Open'"
            echo "  jira view CDSIENG24-599"
            echo "  jira create CDSIENG24 Task 'Fix bug' 'Description here'"
            echo "  jira update CDSIENG24-599 --summary 'New summary' --priority High"
            echo "  jira comment CDSIENG24-599 'This is a comment'"
            echo "  jira assign CDSIENG24-599 limr"
            echo "  jira transition CDSIENG24-599 'In Progress'"
            echo "  jira link CDSIENG24-599 'blocks' CDSIENG24-600"
            echo "  jira worklog CDSIENG24-599 2h 'Implementing feature'"
            echo "  jira labels CDSIENG24-599 add bugfix hotfix"
            ;;
        *)
            echo "Unknown command: $command"
            echo "Run 'jira help' for usage information"
            return 1
            ;;
    esac
}

main "$@"
