#!/usr/bin/env bash

#-------------------------------------------------------
# Script to initialize Git hooks for the project
# Author: GitHub Copilot
# Date: 2025-11-14
#-------------------------------------------------------

set -euo pipefail

readonly SCRIPT_NAME="$(basename "$0")"

echo "🔧 Initializing Git hooks for .dotfiles project..."
echo ""

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "❌ Error: Not in a Git repository"
    exit 1
fi

# Copy pre-commit hook
if [[ -f ".git/hooks/pre-commit" ]]; then
    echo "✅ Pre-commit hook already exists"
    exit 1
fi

# Create hooks directory if it doesn't exist
mkdir -p .git/hooks

echo "📝 Creating pre-commit hook..."
cat > .git/hooks/pre-commit << 'EOF'
#!/usr/bin/env bash

#-------------------------------------------------------
# Pre-commit hook: Check for CRLF line endings in markdown files
# Author: GitHub Copilot
# Date: 2025-11-14
#-------------------------------------------------------

set -euo pipefail

echo "🔍 Checking for CRLF line endings in markdown files..."

# Find all markdown files with CRLF endings
crlf_files=$(find . -name "*.md" -type f -exec grep -l $'\r' {} \;)

if [[ -n "$crlf_files" ]]; then
    echo "❌ ERROR: CRLF line endings found in the following markdown files:"
    echo "$crlf_files"
    echo ""
    echo "💡 To fix this, run one of the following commands:"
    echo "   # Convert CRLF to LF for all .md files:"
    echo "   find . -name \"*.md\" -type f -exec sed -i '' 's/\\r$//' {} \\;"
    echo ""
    echo "   # Or for a specific file:"
    echo "   sed -i '' 's/\\r$//' path/to/file.md"
    echo ""
    echo "   # Check current line endings:"
    echo "   file filename.md"
    exit 1
else
    echo "✅ No CRLF line endings found in markdown files"
fi
EOF
chmod +x .git/hooks/pre-commit
echo "✅ Pre-commit hook created and made executable"

# Vérification de la présence du fichier pre-push 
if [[ -f ".git/hooks/pre-push" ]]; then
    echo "✅ Pre-push hook already exists"
    exit 1
fi

echo "📝 Creating pre-push hook..."
cat > .git/hooks/pre-push << 'EOF'
#!/usr/bin/env bash

#-------------------------------------------------------
# Pre-push hook: Additional check for CRLF line endings
# Author: GitHub Copilot
# Date: 2025-11-14
#-------------------------------------------------------

set -euo pipefail

echo "🚀 Running pre-push checks..."

# Run the same check as pre-commit
if ! ./.git/hooks/pre-commit; then
    echo "❌ Pre-push checks failed - fix the issues before pushing"
    exit 1
fi

echo "✅ All pre-push checks passed"
EOF

chmod +x .git/hooks/pre-push
echo "✅ Pre-push hook created and made executable"

echo ""
echo "🎉 Git hooks initialized successfully!"
echo ""
echo "📋 What these hooks do:"
echo "   • pre-commit: Checks for CRLF line endings in .md files before commits"
echo "   • pre-push: Runs additional checks before pushing to remote"
echo ""
echo "🛠️  If you need to fix line endings, use:"
echo "   ./fix-line-endings.sh check    # Check current status"
echo "   ./fix-line-endings.sh fix-all  # Fix all files"