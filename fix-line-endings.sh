#!/usr/bin/env bash

#-------------------------------------------------------
# Utility script to fix line endings in the project
# Author: GitHub Copilot
# Date: 2025-11-14
#-------------------------------------------------------

set -euo pipefail

readonly SCRIPT_NAME="$(basename "$0")"

echo "🔧 Line Endings Fix Utility"
echo "=========================="

# Function to check line endings
check_line_endings() {
    echo "📋 Checking current line endings..."
    echo ""

    # Check markdown files
    echo "Markdown files:"
    find . -name "*.md" -type f -exec file {} \; | head -10

    echo ""
    echo "Shell scripts:"
    find . -name "*.sh" -type f -exec file {} \; | head -10
}

# Function to fix CRLF in markdown files
fix_md_files() {
    echo "🔄 Converting CRLF to LF in markdown files..."

    local fixed=0
    while IFS= read -r -d '' file; do
        echo "Fixing $file..."
        sed -i '' 's/\r$//' "$file"
        fixed=$(( fixed + 1 ))
    done < <(find . -name "*.md" -type f -print0 | xargs -0 grep -l $'\r' 2>/dev/null || true)

    if [[ "$fixed" -gt 0 ]]; then
        echo "✅ $fixed markdown file(s) fixed!"
    else
        echo "✅ No CRLF line endings found in markdown files"
    fi
}

# Function to fix CRLF in shell scripts
fix_sh_files() {
    echo "🔄 Converting CRLF to LF in shell scripts..."

    local fixed=0
    while IFS= read -r -d '' file; do
        echo "Fixing $file..."
        sed -i '' 's/\r$//' "$file"
        fixed=$(( fixed + 1 ))
    done < <(find . -name "*.sh" -type f -print0 | xargs -0 grep -l $'\r' 2>/dev/null || true)

    if [[ "$fixed" -gt 0 ]]; then
        echo "✅ $fixed shell script(s) fixed!"
    else
        echo "✅ No CRLF line endings found in shell scripts"
    fi
}

# Main menu
case "${1:-}" in
    "check")
        check_line_endings
        ;;
    "fix-md")
        fix_md_files
        ;;
    "fix-sh")
        fix_sh_files
        ;;
    "fix-all")
        fix_md_files
        fix_sh_files
        ;;
    *)
        echo "Usage: $SCRIPT_NAME {check|fix-md|fix-sh|fix-all}"
        echo ""
        echo "Commands:"
        echo "  check    - Check current line endings"
        echo "  fix-md   - Fix CRLF in markdown files only"
        echo "  fix-sh   - Fix CRLF in shell scripts only"
        echo "  fix-all  - Fix CRLF in all files"
        echo ""
        echo "Examples:"
        echo "  $SCRIPT_NAME check"
        echo "  $SCRIPT_NAME fix-md"
        echo "  $SCRIPT_NAME fix-all"
        ;;
esac