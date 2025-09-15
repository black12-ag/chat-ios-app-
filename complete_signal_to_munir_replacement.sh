#!/bin/bash

# Complete Signal to Munir Replacement Script
# This script replaces ALL occurrences of "Signal" with "Munir" in files, folders, and content

set -e

echo "======================================"
echo "Complete Signal to Munir Replacement"
echo "======================================"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_colored() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Create backup
print_colored $YELLOW "Creating backup..."
BACKUP_DIR="../MunrChat-iOS-signal-to-munir-backup-$(date +%Y%m%d-%H%M%S)"
cp -r . "$BACKUP_DIR"
print_colored $GREEN "Backup created at: $BACKUP_DIR"

# Function to replace content in files
replace_in_files() {
    print_colored $YELLOW "Replacing content in files..."
    
    # Find all text files and replace Signal with Munir (case-sensitive)
    find . -type f \( \
        -name "*.swift" -o \
        -name "*.m" -o \
        -name "*.h" -o \
        -name "*.mm" -o \
        -name "*.cpp" -o \
        -name "*.c" -o \
        -name "*.plist" -o \
        -name "*.xml" -o \
        -name "*.json" -o \
        -name "*.yml" -o \
        -name "*.yaml" -o \
        -name "*.md" -o \
        -name "*.txt" -o \
        -name "*.strings" -o \
        -name "*.xcconfig" -o \
        -name "*.xcscheme" -o \
        -name "*.pbxproj" -o \
        -name "*.storyboard" -o \
        -name "*.xib" -o \
        -name "Podfile*" -o \
        -name "Gemfile*" -o \
        -name "Makefile" -o \
        -name "*.sh" -o \
        -name "*.py" -o \
        -name "*.rb" \
    \) -not -path "./.git/*" -not -path "./Pods/*" -not -path "./build/*" | while read file; do
        if [ -f "$file" ]; then
            # Skip binary files
            if file "$file" | grep -q text; then
                # Replace various Signal references
                sed -i '' \
                    -e 's/Signal-iOS/Munir-iOS/g' \
                    -e 's/Signal-Android/Munir-Android/g' \
                    -e 's/SignalMessaging/MunirMessaging/g' \
                    -e 's/SignalServiceKit/MunirServiceKit/g' \
                    -e 's/SignalShareExtension/MunirShareExtension/g' \
                    -e 's/SignalNSE/MunirNSE/g' \
                    -e 's/SignalUI/MunirUI/g' \
                    -e 's/SignalApp/MunirApp/g' \
                    -e 's/SignalCall/MunirCall/g' \
                    -e 's/Signal\.app/Munir.app/g' \
                    -e 's/Signal App/Munir App/g' \
                    -e 's/Signal iOS/Munir iOS/g' \
                    -e 's/Signal Private Messenger/Munir Private Messenger/g' \
                    -e 's/Signal Foundation/Munir Foundation/g' \
                    -e 's/Signal Messenger/Munir Messenger/g' \
                    -e 's/org\.whispersystems\.signal/com.munir.chat/g' \
                    -e 's/Signal Protocol/Munir Protocol/g' \
                    -e 's/Signal Desktop/Munir Desktop/g' \
                    -e 's/Signal Server/Munir Server/g' \
                    -e 's/Signal Web/Munir Web/g' \
                    -e 's/\bSignal\b/Munir/g' \
                    "$file"
                
                # Show progress
                echo "Updated: $file"
            fi
        fi
    done
}

# Function to rename directories
rename_directories() {
    print_colored $YELLOW "Renaming directories with Signal in their names..."
    
    # Find directories with Signal in name and rename them (deepest first)
    find . -type d -name "*Signal*" -not -path "./.git/*" -not -path "./Pods/*" | sort -r | while read dir; do
        if [ -d "$dir" ]; then
            new_dir=$(echo "$dir" | sed 's/Signal/Munir/g')
            if [ "$dir" != "$new_dir" ]; then
                print_colored $GREEN "Renaming directory: $dir -> $new_dir"
                mv "$dir" "$new_dir"
            fi
        fi
    done
}

# Function to rename files
rename_files() {
    print_colored $YELLOW "Renaming files with Signal in their names..."
    
    # Find files with Signal in name and rename them
    find . -type f -name "*Signal*" -not -path "./.git/*" -not -path "./Pods/*" | while read file; do
        if [ -f "$file" ]; then
            dir=$(dirname "$file")
            filename=$(basename "$file")
            new_filename=$(echo "$filename" | sed 's/Signal/Munir/g')
            
            if [ "$filename" != "$new_filename" ]; then
                new_file="$dir/$new_filename"
                print_colored $GREEN "Renaming file: $file -> $new_file"
                mv "$file" "$new_file"
            fi
        fi
    done
}

# Function to update Xcode project references
update_xcode_references() {
    print_colored $YELLOW "Updating Xcode project references..."
    
    # Update project.pbxproj files
    find . -name "project.pbxproj" -not -path "./.git/*" -not -path "./Pods/*" | while read pbxfile; do
        if [ -f "$pbxfile" ]; then
            print_colored $GREEN "Updating Xcode project file: $pbxfile"
            sed -i '' \
                -e 's/Signal\.xcodeproj/Munir.xcodeproj/g' \
                -e 's/Signal\.xcworkspace/Munir.xcworkspace/g' \
                -e 's/Signal-/Munir-/g' \
                -e 's/SignalShareExtension/MunirShareExtension/g' \
                -e 's/SignalNSE/MunirNSE/g' \
                -e 's/SignalServiceKit/MunirServiceKit/g' \
                -e 's/SignalUI/MunirUI/g' \
                -e 's/SignalMessaging/MunirMessaging/g' \
                -e 's/\bSignal\b/Munir/g' \
                "$pbxfile"
        fi
    done
    
    # Update scheme files
    find . -name "*.xcscheme" -not -path "./.git/*" -not -path "./Pods/*" | while read scheme; do
        if [ -f "$scheme" ]; then
            print_colored $GREEN "Updating scheme file: $scheme"
            sed -i '' \
                -e 's/Signal\.app/Munir.app/g' \
                -e 's/SignalShareExtension/MunirShareExtension/g' \
                -e 's/SignalNSE/MunirNSE/g' \
                -e 's/\bSignal\b/Munir/g' \
                "$scheme"
        fi
    done
}

# Function to update bundle identifiers and Info.plist files
update_bundle_identifiers() {
    print_colored $YELLOW "Updating bundle identifiers and Info.plist files..."
    
    find . -name "Info.plist" -o -name "*-Info.plist" | while read plist; do
        if [ -f "$plist" ]; then
            print_colored $GREEN "Updating plist file: $plist"
            sed -i '' \
                -e 's/org\.whispersystems\.signal/com.munir.chat/g' \
                -e 's/Signal Private Messenger/Munir Private Messenger/g' \
                -e 's/Signal iOS/Munir iOS/g' \
                -e 's/Signal App/Munir App/g' \
                -e 's/\bSignal\b/Munir/g' \
                "$plist"
        fi
    done
}

# Function to update Podfile and dependencies
update_podfile() {
    print_colored $YELLOW "Updating Podfile and dependency files..."
    
    if [ -f "Podfile" ]; then
        sed -i '' \
            -e "s/target 'Signal'/target 'Munir'/g" \
            -e "s/target 'SignalShareExtension'/target 'MunirShareExtension'/g" \
            -e "s/target 'SignalNSE'/target 'MunirNSE'/g" \
            -e 's/Signal\.xcworkspace/Munir.xcworkspace/g' \
            "Podfile"
        print_colored $GREEN "Updated Podfile"
    fi
    
    if [ -f "Podfile.lock" ]; then
        sed -i '' \
            -e 's/Signal\.xcworkspace/Munir.xcworkspace/g' \
            "Podfile.lock"
        print_colored $GREEN "Updated Podfile.lock"
    fi
}

# Function to update README and documentation
update_documentation() {
    print_colored $YELLOW "Updating documentation files..."
    
    find . -name "README*" -o -name "*.md" -o -name "*.txt" | while read doc; do
        if [ -f "$doc" ]; then
            sed -i '' \
                -e 's/Signal-iOS/Munir-iOS/g' \
                -e 's/Signal-Android/Munir-Android/g' \
                -e 's/Signal Private Messenger/Munir Private Messenger/g' \
                -e 's/Signal Foundation/Munir Foundation/g' \
                -e 's/Signal Messenger/Munir Messenger/g' \
                -e 's/Signal Protocol/Munir Protocol/g' \
                -e 's/Signal Desktop/Munir Desktop/g' \
                -e 's/Signal Server/Munir Server/g' \
                -e 's/\bSignal\b/Munir/g' \
                "$doc"
            print_colored $GREEN "Updated documentation: $doc"
        fi
    done
}

# Main execution
print_colored $GREEN "Starting complete Signal to Munir replacement..."
echo ""

# Step 1: Replace content in files first
replace_in_files
print_colored $GREEN "✓ Content replacement completed"

# Step 2: Rename files
rename_files
print_colored $GREEN "✓ File renaming completed"

# Step 3: Rename directories
rename_directories
print_colored $GREEN "✓ Directory renaming completed"

# Step 4: Update Xcode project references
update_xcode_references
print_colored $GREEN "✓ Xcode references updated"

# Step 5: Update bundle identifiers
update_bundle_identifiers
print_colored $GREEN "✓ Bundle identifiers updated"

# Step 6: Update Podfile
update_podfile
print_colored $GREEN "✓ Podfile updated"

# Step 7: Update documentation
update_documentation
print_colored $GREEN "✓ Documentation updated"

echo ""
print_colored $GREEN "======================================"
print_colored $GREEN "Signal to Munir replacement completed!"
print_colored $GREEN "======================================"
echo ""
print_colored $YELLOW "Summary of changes:"
echo "• All file contents updated (Signal -> Munir)"
echo "• All file names renamed"
echo "• All directory names renamed"
echo "• Xcode project files updated"
echo "• Bundle identifiers updated"
echo "• Podfile and dependencies updated"
echo "• Documentation updated"
echo ""
print_colored $YELLOW "Backup location: $BACKUP_DIR"
echo ""
print_colored $GREEN "Ready to commit changes to Git!"