#!/usr/bin/env bash

#-------------------------------------------------------
# Utility script to fix line endings in the project
# Author: GitHub Copilot
# Date: 2025-11-14
#-------------------------------------------------------

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

    md_files=$(find . -name "*.md" -type f -exec grep -l $'\r' {} \;)

    if [ -n "$md_files" ]; then
        echo "Files to fix:"
        echo "$md_files"
        echo ""

        for file in $md_files; do
            echo "Fixing $file..."
            sed -i 's/\r$//' "$file"
        done

        echo "✅ All markdown files fixed!"
    else
        echo "✅ No CRLF line endings found in markdown files"
    fi
}

# Function to fix CRLF in shell scripts
fix_sh_files() {
    echo "🔄 Converting CRLF to LF in shell scripts..."

    sh_files=$(find . -name "*.sh" -type f -exec grep -l $'\r' {} \;)

    if [ -n "$sh_files" ]; then
        echo "Files to fix:"
        echo "$sh_files"
        echo ""

        for file in $sh_files; do
            echo "Fixing $file..."
            sed -i 's/\r$//' "$file"
        done

        echo "✅ All shell scripts fixed!"
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
        echo "Usage: $0 {check|fix-md|fix-sh|fix-all}"
        echo ""
        echo "Commands:"
        echo "  check    - Check current line endings"
        echo "  fix-md   - Fix CRLF in markdown files only"
        echo "  fix-sh   - Fix CRLF in shell scripts only"
        echo "  fix-all  - Fix CRLF in all files"
        echo ""
        echo "Examples:"
        echo "  $0 check"
        echo "  $0 fix-md"
        echo "  $0 fix-all"
        ;;
esac