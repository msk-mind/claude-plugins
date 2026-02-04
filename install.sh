#!/bin/bash
# Claude Plugins Installer - MSK MIND
# https://github.com/msk-mind/claude-plugins

set -e

REPO_URL="https://github.com/msk-mind/claude-plugins.git"
INSTALL_DIR="${HOME}/.claude/plugins/msk-mind"

echo "Installing MSK MIND Claude Plugins..."

# Create plugins directory if it doesn't exist
mkdir -p "${HOME}/.claude/plugins"

# Clone or update the repository
if [ -d "$INSTALL_DIR" ]; then
    echo "Updating existing installation..."
    cd "$INSTALL_DIR"
    git pull origin main
else
    echo "Cloning repository..."
    git clone "$REPO_URL" "$INSTALL_DIR"
fi

echo ""
echo "Installation complete!"
echo ""
echo "Installed plugins:"
echo "  - jira-toolkit: Work with Jira issues"
echo "  - confluence-toolkit: Work with Confluence pages"
echo ""
echo "Setup required:"
echo "  Create ~/.atlassian_env with your credentials:"
echo ""
echo "    ATLASSIAN_DOMAIN=your-domain.atlassian.net"
echo "    ATLASSIAN_EMAIL=your-email@example.com"
echo "    ATLASSIAN_API_TOKEN=your-api-token"
echo ""
echo "Restart Claude Code to use the plugins."
