#!/usr/bin/env python3
"""
MunrChat Rebranding Script
Converts Signal app to MunrChat with custom branding
"""

import os
import re
import subprocess
import sys
from pathlib import Path

def run_command(cmd, check=True):
    """Run shell command and return result"""
    print(f"Running: {cmd}")
    result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
    if check and result.returncode != 0:
        print(f"Error: {result.stderr}")
        return False
    return result.stdout.strip()

def update_info_plist_hardcoded_values():
    """Update Info.plist files with hardcoded display names"""
    info_plist_files = [
        "Signal/Signal-Info.plist",
        "SignalNSE/Info.plist", 
        "SignalShareExtension/Info.plist"
    ]
    
    for plist_file in info_plist_files:
        if os.path.exists(plist_file):
            print(f"Updating {plist_file}...")
            
            # Read the file
            with open(plist_file, 'r') as f:
                content = f.read()
            
            # Replace Signal references with MunrChat
            content = re.sub(
                r'<string>Signal</string>', 
                '<string>MunrChat</string>', 
                content
            )
            
            # Update email to your custom support email
            content = re.sub(
                r'<string>support@signal\.org</string>',
                '<string>support@munrchat.com</string>',
                content
            )
            
            # Update app transport security domains if needed
            content = re.sub(
                r'<key>signal\.org</key>',
                '<key>munrchat.com</key>',
                content
            )
            
            # Write back
            with open(plist_file, 'w') as f:
                f.write(content)
            
            print(f"✅ Updated {plist_file}")
        else:
            print(f"❌ File not found: {plist_file}")

def update_xcode_build_settings():
    """Update Xcode project build settings for rebranding"""
    
    # Read the project file
    project_file = "Signal.xcodeproj/project.pbxproj"
    
    if not os.path.exists(project_file):
        print(f"❌ Project file not found: {project_file}")
        return False
        
    print(f"Updating {project_file}...")
    
    with open(project_file, 'r') as f:
        content = f.read()
    
    # Update product names
    content = re.sub(
        r'PRODUCT_NAME = Signal;',
        'PRODUCT_NAME = MunrChat;',
        content
    )
    
    # Update bundle identifier prefix
    content = re.sub(
        r'SIGNAL_BUNDLEID_PREFIX = org\.whispersystems;',
        'SIGNAL_BUNDLEID_PREFIX = com.munir.munrchat;',
        content
    )
    
    # Update main bundle identifier
    content = re.sub(
        r'PRODUCT_BUNDLE_IDENTIFIER = org\.whispersystems\.signal;',
        'PRODUCT_BUNDLE_IDENTIFIER = com.munir.munrchat.app;',
        content
    )
    
    # Update extension bundle identifiers
    content = re.sub(
        r'org\.whispersystems\.signal\.SignalNSE',
        'com.munir.munrchat.app.SignalNSE',
        content
    )
    
    content = re.sub(
        r'org\.whispersystems\.signal\.ShareExtension',
        'com.munir.munrchat.app.ShareExtension',
        content
    )
    
    # Write back
    with open(project_file, 'w') as f:
        f.write(content)
    
    print("✅ Updated Xcode project build settings")
    return True

def update_scheme_names():
    """Update Xcode scheme names from Signal to MunrChat"""
    
    scheme_dir = "Signal.xcodeproj/xcshareddata/xcschemes"
    
    if not os.path.exists(scheme_dir):
        print(f"❌ Scheme directory not found: {scheme_dir}")
        return False
    
    # Rename scheme files
    scheme_files = {
        "Signal.xcscheme": "MunrChat.xcscheme",
        "Signal-Staging.xcscheme": "MunrChat-Staging.xcscheme"
    }
    
    for old_name, new_name in scheme_files.items():
        old_path = os.path.join(scheme_dir, old_name)
        new_path = os.path.join(scheme_dir, new_name)
        
        if os.path.exists(old_path):
            # Read and update scheme content
            with open(old_path, 'r') as f:
                content = f.read()
            
            # Update references inside the scheme
            content = re.sub(r'BlueprintName = "Signal"', 'BlueprintName = "MunrChat"', content)
            content = re.sub(r'BuildableName = "Signal.app"', 'BuildableName = "MunrChat.app"', content)
            content = re.sub(r'ReferencedContainer = "container:Signal.xcodeproj"', 'ReferencedContainer = "container:Signal.xcodeproj"', content)
            
            # Write to new location
            with open(new_path, 'w') as f:
                f.write(content)
            
            # Remove old scheme
            os.remove(old_path)
            print(f"✅ Renamed scheme: {old_name} -> {new_name}")
        else:
            print(f"❌ Scheme not found: {old_path}")

def update_source_code_references():
    """Update source code references to Signal branding"""
    
    # Common files that might contain app name references
    source_files = []
    
    # Find Swift files that might contain hardcoded app names
    for root, dirs, files in os.walk("Signal"):
        for file in files:
            if file.endswith(('.swift', '.m', '.h')):
                source_files.append(os.path.join(root, file))
    
    # Also check other common locations
    source_files.extend([
        "SignalServiceKit/src/Util/AppContext.swift",
        "SignalUI/Utils/Theme.swift"
    ])
    
    app_name_patterns = [
        (r'"Signal"', '"MunrChat"'),
        (r"'Signal'", "'MunrChat'"),
        (r'Signal Messenger', 'MunrChat Messenger'),
        (r'NSLocalizedString\(@"Signal"', 'NSLocalizedString(@"MunrChat"'),
    ]
    
    updated_files = 0
    
    for file_path in source_files:
        if os.path.exists(file_path):
            try:
                with open(file_path, 'r', encoding='utf-8') as f:
                    content = f.read()
                
                original_content = content
                
                # Apply patterns
                for pattern, replacement in app_name_patterns:
                    content = re.sub(pattern, replacement, content)
                
                # Only write if changed
                if content != original_content:
                    with open(file_path, 'w', encoding='utf-8') as f:
                        f.write(content)
                    updated_files += 1
                    print(f"✅ Updated app name references in: {file_path}")
                    
            except Exception as e:
                print(f"❌ Could not update {file_path}: {e}")
    
    print(f"✅ Updated app name references in {updated_files} source files")

def main():
    """Main rebranding function"""
    print("🚀 Starting MunrChat Rebranding Process...")
    print("=" * 50)
    
    # Check if we're in the right directory
    if not os.path.exists("Signal.xcodeproj"):
        print("❌ Error: Signal.xcodeproj not found. Make sure you're in the project root directory.")
        sys.exit(1)
    
    # Backup the original project
    print("📦 Creating backup of original project...")
    backup_cmd = "cp -r Signal.xcodeproj Signal.xcodeproj.original.backup"
    run_command(backup_cmd)
    
    try:
        # Step 1: Update Info.plist files with hardcoded values
        print("\\n1️⃣ Updating Info.plist files...")
        update_info_plist_hardcoded_values()
        
        # Step 2: Update Xcode project build settings
        print("\\n2️⃣ Updating Xcode build settings...")
        update_xcode_build_settings()
        
        # Step 3: Update scheme names
        print("\\n3️⃣ Updating Xcode schemes...")
        update_scheme_names()
        
        # Step 4: Update source code references (optional, be careful)
        print("\\n4️⃣ Updating source code references...")
        update_source_code_references()
        
        print("\\n🎉 MunrChat Rebranding Complete!")
        print("=" * 50)
        print("✅ App will now display as 'MunrChat' instead of 'Signal'")
        print("✅ Bundle ID changed to: com.munir.munrchat.app")
        print("✅ Schemes updated to MunrChat")
        print("✅ Source code references updated")
        print()
        print("🔄 Next Steps:")
        print("1. Open Signal.xcworkspace in Xcode")
        print("2. Select the MunrChat scheme")  
        print("3. Update code signing with your Apple ID")
        print("4. Build and test the rebranded app")
        print()
        print("⚠️  Note: You may need to update additional branding elements like:")
        print("   - App icon (Signal/AppIcon.xcassets)")
        print("   - Launch screen assets")
        print("   - Custom UI strings and localizations")
        
    except Exception as e:
        print(f"❌ Error during rebranding: {e}")
        print("🔄 Restoring original project...")
        restore_cmd = "rm -rf Signal.xcodeproj && mv Signal.xcodeproj.original.backup Signal.xcodeproj"
        run_command(restore_cmd, check=False)
        sys.exit(1)

if __name__ == "__main__":
    main()
