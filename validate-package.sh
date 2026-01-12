#!/bin/bash

# Validation script for tmux ASUSTOR package
# This script checks if all files mentioned in config.json exist
# and warns about unexpected files in bin, lib, and share directories

PACKAGE_DIR="$(pwd)/apkg"
CONFIG_FILE="${PACKAGE_DIR}/CONTROL/config.json"

echo "================================================"
echo "Validating tmux ASUSTOR Package"
echo "================================================"
echo ""

# Check if config.json exists
if [ ! -f "$CONFIG_FILE" ]; then
    echo "ERROR: config.json not found at $CONFIG_FILE"
    exit 1
fi

# Check if jq is available
if ! command -v jq &> /dev/null; then
    echo "ERROR: jq is not installed. Please install jq to run validation."
    exit 1
fi

VALIDATION_FAILED=0
WARNINGS=0

# Function to validate files in a directory
validate_directory() {
    local dir_name=$1
    local json_path=$2
    local dir_path="${PACKAGE_DIR}/${dir_name}"
    
    echo "Checking ${dir_name}/ directory..."
    
    # Get expected files from config.json
    if ! expected_files=$(jq -r "${json_path}[]" "$CONFIG_FILE" 2>/dev/null); then
        echo "  WARNING: Could not read file list from config.json at ${json_path}"
        WARNINGS=$((WARNINGS + 1))
        return
    fi
    
    # Check if directory exists
    if [ ! -d "$dir_path" ]; then
        echo "  ERROR: Directory $dir_path does not exist!"
        VALIDATION_FAILED=1
        return
    fi
    
    # Check if all expected files exist
    local missing_count=0
    while IFS= read -r file; do
        if [ -n "$file" ]; then
            if [ ! -e "${dir_path}/${file}" ]; then
                echo "  ERROR: Expected file missing: ${file}"
                missing_count=$((missing_count + 1))
                VALIDATION_FAILED=1
            fi
        fi
    done <<< "$expected_files"
    
    if [ $missing_count -eq 0 ]; then
        echo "  ✓ All expected files present"
    else
        echo "  ✗ $missing_count file(s) missing"
    fi
    
    # Check for unexpected files
    local unexpected_count=0
    for actual_file in "${dir_path}/"*; do
        if [ -e "$actual_file" ]; then
            local filename=$(basename "$actual_file")
            local is_expected=0
            
            while IFS= read -r expected_file; do
                if [ "$filename" = "$expected_file" ]; then
                    is_expected=1
                    break
                fi
            done <<< "$expected_files"
            
            if [ $is_expected -eq 0 ]; then
                echo "  WARNING: Unexpected file found: ${filename}"
                unexpected_count=$((unexpected_count + 1))
                WARNINGS=$((WARNINGS + 1))
            fi
        fi
    done
    
    if [ $unexpected_count -gt 0 ]; then
        echo "  ⚠ $unexpected_count unexpected file(s) found (not in config.json)"
    fi
    
    echo ""
}

# Validate each directory
validate_directory "bin" '.register."symbolic-link"."/bin"'
validate_directory "lib" '.register."symbolic-link"."/lib"'

# Summary
echo "================================================"
echo "Validation Summary"
echo "================================================"

if [ $VALIDATION_FAILED -eq 1 ]; then
    echo "✗ VALIDATION FAILED"
    echo "  Some expected files are missing from the package."
    echo "  Please check the errors above."
    exit 1
elif [ $WARNINGS -gt 0 ]; then
    echo "⚠ VALIDATION PASSED WITH WARNINGS"
    echo "  $WARNINGS warning(s) found."
    echo "  Some unexpected files were found in the package."
    echo "  Consider updating config.json if these files should be included."
    exit 0
else
    echo "✓ VALIDATION PASSED"
    echo "  All expected files are present and no unexpected files found."
    exit 0
fi
