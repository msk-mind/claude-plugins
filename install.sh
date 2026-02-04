#!/bin/bash
# Claude Plugins Installer - MSK MIND
# https://github.com/msk-mind/claude-plugins

set -e

echo "MSK MIND Claude Plugins"
echo "======================="
echo ""
echo "To install these plugins, run the following command in Claude Code:"
echo ""
echo "  /install-plugin msk-mind/claude-plugins"
echo ""
echo "Or use the CLI:"
echo ""
echo "  claude plugin add marketplace github:msk-mind/claude-plugins"
echo ""
echo "Then install individual plugins:"
echo ""
echo "  claude plugin install jira-toolkit@msk-mind-plugins"
echo "  claude plugin install confluence-toolkit@msk-mind-plugins"
echo ""
echo "Setup required:"
echo "  Create ~/.atlassian_env with your credentials:"
echo ""
echo "    ATLASSIAN_DOMAIN=your-domain.atlassian.net"
echo "    ATLASSIAN_EMAIL=your-email@example.com"
echo "    ATLASSIAN_API_TOKEN=your-api-token"
echo ""
