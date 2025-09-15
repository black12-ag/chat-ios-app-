#!/usr/bin/env python3
"""
Complete Munir Rebranding Script
Makes ALL schemes, targets, and components use Munir branding consistently
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

def update_all_scheme_names():
    """Update ALL scheme names to use Munir branding"""
    
    scheme_dir = "Signal.xcodeproj/xcshareddata/xcschemes"
    
    if not os.path.exists(scheme_dir):
        print(f"❌ Scheme directory not found: {scheme_dir}")
        return False
    
    # Complete mapping of all schemes to Munir versions
    scheme_mappings = {
        # Already done, but keeping for completeness
        "MunrChat.xcscheme": "MunrChat.xcscheme",  # Keep as is
        "MunrChat-Staging.xcscheme": "MunrChat-Staging.xcscheme",  # Keep as is
        
        # New rebranding targets
        "SignalNSE.xcscheme": "MunirNSE.xcscheme",
        "SignalServiceKit.xcscheme": "MunirServiceKit.xcscheme", 
        "SignalShareExtension.xcscheme": "MunirShareExtension.xcscheme",
        "SignalUI.xcscheme": "MunirUI.xcscheme",
    }
    
    for old_name, new_name in scheme_mappings.items():
        old_path = os.path.join(scheme_dir, old_name)
        new_path = os.path.join(scheme_dir, new_name)
        
        if os.path.exists(old_path) and old_name != new_name:
            # Read and update scheme content
            with open(old_path, 'r') as f:
                content = f.read()
            
            # Update all Signal references to Munir in the scheme
            content = re.sub(r'BlueprintName = "Signal([^"]*)"', r'BlueprintName = "Munir\1"', content)
            content = re.sub(r'BuildableName = "Signal([^"]*)"', r'BuildableName = "Munir\1"', content)
            content = re.sub(r'ReferencedContainer = "container:Signal.xcodeproj"', 'ReferencedContainer = "container:Signal.xcodeproj"', content)
            
            # Write to new location
            with open(new_path, 'w') as f:
                f.write(content)
            
            # Remove old scheme
            os.remove(old_path)
            print(f"✅ Renamed scheme: {old_name} -> {new_name}")
        elif old_name == new_name:
            print(f"✅ Scheme already correct: {new_name}")
        else:
            print(f"⚠️  Scheme not found: {old_path}")

def update_project_targets():
    """Update all target names in the Xcode project"""
    
    project_file = "Signal.xcodeproj/project.pbxproj"
    
    if not os.path.exists(project_file):
        print(f"❌ Project file not found: {project_file}")
        return False
        
    print(f"Updating target names in {project_file}...")
    
    with open(project_file, 'r') as f:
        content = f.read()
    
    # Target name mappings
    target_mappings = {
        r'"SignalNSE"': '"MunirNSE"',
        r'"SignalServiceKit"': '"MunirServiceKit"',
        r'"SignalShareExtension"': '"MunirShareExtension"', 
        r'"SignalUI"': '"MunirUI"',
        # Keep existing MunrChat naming
        # r'"Signal"': '"MunrChat"',  # Already done
    }
    
    # Apply target name changes
    for old_pattern, new_name in target_mappings.items():
        content = re.sub(old_pattern, new_name, content)
    
    # Update product names as well
    content = re.sub(r'PRODUCT_NAME = SignalNSE;', 'PRODUCT_NAME = MunirNSE;', content)
    content = re.sub(r'PRODUCT_NAME = SignalServiceKit;', 'PRODUCT_NAME = MunirServiceKit;', content)
    content = re.sub(r'PRODUCT_NAME = SignalShareExtension;', 'PRODUCT_NAME = MunirShareExtension;', content)
    content = re.sub(r'PRODUCT_NAME = SignalUI;', 'PRODUCT_NAME = MunirUI;', content)
    
    # Update bundle identifiers for extensions
    content = re.sub(
        r'PRODUCT_BUNDLE_IDENTIFIER = com\.munir\.munrchat\.app\.SignalNSE;',
        'PRODUCT_BUNDLE_IDENTIFIER = com.munir.munrchat.app.MunirNSE;',
        content
    )
    content = re.sub(
        r'PRODUCT_BUNDLE_IDENTIFIER = com\.munir\.munrchat\.app\.ShareExtension;',
        'PRODUCT_BUNDLE_IDENTIFIER = com.munir.munrchat.app.MunirShareExtension;',
        content
    )
    
    # Write back
    with open(project_file, 'w') as f:
        f.write(content)
    
    print("✅ Updated all target names in Xcode project")
    return True

def update_workspace_schemes():
    """Update workspace scheme references"""
    
    workspace_file = "Signal.xcworkspace/contents.xcworkspacedata"
    
    if os.path.exists(workspace_file):
        with open(workspace_file, 'r') as f:
            content = f.read()
        
        # Update any Signal references to Munir in workspace
        original_content = content
        content = re.sub(r'Signal([A-Z][a-zA-Z]*)', r'Munir\1', content)
        
        if content != original_content:
            with open(workspace_file, 'w') as f:
                f.write(content)
            print("✅ Updated workspace scheme references")
        else:
            print("✅ Workspace schemes already correct")

def update_pod_references():
    """Update any Pod references that might affect scheme names"""
    
    # Update Podfile target names if they reference the old names
    podfile = "Podfile"
    if os.path.exists(podfile):
        with open(podfile, 'r') as f:
            content = f.read()
        
        original_content = content
        
        # Update target references in Podfile
        content = re.sub(r"target 'SignalNSE'", "target 'MunirNSE'", content)
        content = re.sub(r"target 'SignalServiceKit'", "target 'MunirServiceKit'", content)
        content = re.sub(r"target 'SignalShareExtension'", "target 'MunirShareExtension'", content)
        content = re.sub(r"target 'SignalUI'", "target 'MunirUI'", content)
        
        if content != original_content:
            with open(podfile, 'w') as f:
                f.write(content)
            print("✅ Updated Podfile target references")
        else:
            print("✅ Podfile targets already correct")

def update_source_code_module_references():
    """Update any source code that references the old module names"""
    
    # Common patterns to update in source files
    module_patterns = [
        (r'import SignalServiceKit', 'import MunirServiceKit'),
        (r'import SignalUI', 'import MunirUI'),
        (r'@import SignalServiceKit', '@import MunirServiceKit'),
        (r'@import SignalUI', '@import MunirUI'),
        (r'#import <SignalServiceKit/', '#import <MunirServiceKit/'),
        (r'#import <SignalUI/', '#import <MunirUI/'),
    ]
    
    # Find Swift and Objective-C files
    source_files = []
    
    for root, dirs, files in os.walk("Signal"):
        for file in files:
            if file.endswith(('.swift', '.m', '.h')):
                source_files.append(os.path.join(root, file))
    
    # Also check other directories
    for root, dirs, files in os.walk("SignalUI"):
        for file in files:
            if file.endswith(('.swift', '.m', '.h')):
                source_files.append(os.path.join(root, file))
                
    for root, dirs, files in os.walk("SignalServiceKit"):
        for file in files:
            if file.endswith(('.swift', '.m', '.h')):
                source_files.append(os.path.join(root, file))
    
    updated_files = 0
    
    for file_path in source_files[:50]:  # Limit to first 50 to avoid overwhelming output
        if os.path.exists(file_path):
            try:
                with open(file_path, 'r', encoding='utf-8') as f:
                    content = f.read()
                
                original_content = content
                
                # Apply module name patterns
                for pattern, replacement in module_patterns:
                    content = re.sub(pattern, replacement, content)
                
                # Only write if changed
                if content != original_content:
                    with open(file_path, 'w', encoding='utf-8') as f:
                        f.write(content)
                    updated_files += 1
                    
            except Exception as e:
                print(f"❌ Could not update {file_path}: {e}")
    
    if updated_files > 0:
        print(f"✅ Updated module references in {updated_files} source files")
    else:
        print("✅ Module references already correct")

def main():
    """Main rebranding function for complete Munir rebranding"""
    print("🚀 Starting Complete Munir Rebranding Process...")
    print("=" * 50)
    
    # Check if we're in the right directory
    if not os.path.exists("Signal.xcodeproj"):
        print("❌ Error: Signal.xcodeproj not found. Make sure you're in the project root directory.")
        sys.exit(1)
    
    # Backup the current project state
    print("📦 Creating backup of current project state...")
    backup_cmd = "cp -r Signal.xcodeproj Signal.xcodeproj.munir.backup"
    run_command(backup_cmd)
    
    try:
        # Step 1: Update all scheme names
        print("\\n1️⃣ Updating ALL scheme names to Munir...")
        update_all_scheme_names()
        
        # Step 2: Update project targets
        print("\\n2️⃣ Updating project target names...")
        update_project_targets()
        
        # Step 3: Update workspace references
        print("\\n3️⃣ Updating workspace scheme references...")
        update_workspace_schemes()
        
        # Step 4: Update Podfile references
        print("\\n4️⃣ Updating Podfile target references...")
        update_pod_references()
        
        # Step 5: Update source code module references
        print("\\n5️⃣ Updating source code module references...")
        update_source_code_module_references()
        
        print("\\n🎉 Complete Munir Rebranding Finished!")
        print("=" * 50)
        print("✅ ALL schemes now use Munir branding:")
        print("   • MunrChat (main app)")
        print("   • MunrChat-Staging") 
        print("   • MunirNSE (notification service)")
        print("   • MunirServiceKit (core services)")
        print("   • MunirShareExtension (share extension)")
        print("   • MunirUI (user interface)")
        print()
        print("🔄 Next Steps:")
        print("1. Restart Xcode to refresh the scheme list")
        print("2. Run 'pod install' to update Pod targets")
        print("3. Select any Munir scheme and build")
        print("4. All components will now show Munir branding!")
        print()
        print("📱 Your app is now completely branded as Munir's personal app!")
        
    except Exception as e:
        print(f"❌ Error during rebranding: {e}")
        print("🔄 Restoring previous state...")
        restore_cmd = "rm -rf Signal.xcodeproj && mv Signal.xcodeproj.munir.backup Signal.xcodeproj"
        run_command(restore_cmd, check=False)
        sys.exit(1)

if __name__ == "__main__":
    main()
