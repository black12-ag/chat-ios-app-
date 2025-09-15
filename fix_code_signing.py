#!/usr/bin/env python3
"""
Fix Code Signing and Bundle ID Issues for MunrChat
Resolves provisioning profile errors and team settings
"""

import os
import re
import subprocess
import sys

def run_command(cmd, check=True):
    """Run shell command and return result"""
    print(f"Running: {cmd}")
    result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
    if check and result.returncode != 0:
        print(f"Error: {result.stderr}")
        return False
    return result.stdout.strip()

def get_development_team():
    """Get the development team ID from available certificates"""
    print("Finding available development teams...")
    
    # Get signing identities
    result = run_command('security find-identity -v -p codesigning', check=False)
    print(f"Available identities:\n{result}")
    
    # Try to get team ID from provisioning profiles
    profiles_dir = os.path.expanduser("~/Library/MobileDevice/Provisioning Profiles/")
    if os.path.exists(profiles_dir):
        print(f"Checking provisioning profiles in: {profiles_dir}")
        profiles = os.listdir(profiles_dir)
        print(f"Found {len(profiles)} provisioning profiles")
    
    # For now, we'll use automatic signing which should work with any Apple ID
    return "AUTOMATIC"

def fix_bundle_identifiers():
    """Fix bundle identifier issues in the Xcode project"""
    
    project_file = "Signal.xcodeproj/project.pbxproj"
    
    if not os.path.exists(project_file):
        print(f"❌ Project file not found: {project_file}")
        return False
    
    print("Fixing bundle identifiers...")
    
    with open(project_file, 'r') as f:
        content = f.read()
    
    # Fix the problematic bundle IDs
    bundle_id_fixes = [
        # Main app - simplified bundle ID
        (r'PRODUCT_BUNDLE_IDENTIFIER = com\.munir\.munrchat\.signal;', 
         'PRODUCT_BUNDLE_IDENTIFIER = com.munir.munrchat;'),
        
        # NSE Extension
        (r'PRODUCT_BUNDLE_IDENTIFIER = com\.munir\.munrchat\.signal\.SignalNSE;',
         'PRODUCT_BUNDLE_IDENTIFIER = com.munir.munrchat.nse;'),
        
        # Share Extension  
        (r'PRODUCT_BUNDLE_IDENTIFIER = com\.munir\.munrchat\.signal\.shareextension;',
         'PRODUCT_BUNDLE_IDENTIFIER = com.munir.munrchat.share;'),
        
        # Any remaining .signal references
        (r'com\.munir\.munrchat\.signal\.',
         'com.munir.munrchat.'),
         
        # Fix app bundle ID
        (r'PRODUCT_BUNDLE_IDENTIFIER = com\.munir\.munrchat\.app;',
         'PRODUCT_BUNDLE_IDENTIFIER = com.munir.munrchat;'),
    ]
    
    for old_pattern, new_value in bundle_id_fixes:
        content = re.sub(old_pattern, new_value, content)
    
    # Enable automatic signing for all targets
    automatic_signing_fixes = [
        # Enable automatic signing
        (r'PROVISIONING_PROFILE_SPECIFIER = [^;]*;',
         'PROVISIONING_PROFILE_SPECIFIER = "";'),
        (r'CODE_SIGN_IDENTITY = [^;]*;',
         'CODE_SIGN_IDENTITY = "Apple Development";'),
        (r'DEVELOPMENT_TEAM = [^;]*;',
         'DEVELOPMENT_TEAM = "";'),
        # Add automatic provisioning
        (r'(PRODUCT_BUNDLE_IDENTIFIER = [^;]*;)',
         r'\1\n\t\t\t\tCODE_SIGN_STYLE = Automatic;'),
    ]
    
    for pattern, replacement in automatic_signing_fixes:
        content = re.sub(pattern, replacement, content)
    
    with open(project_file, 'w') as f:
        f.write(content)
    
    print("✅ Fixed bundle identifiers and enabled automatic signing")
    return True

def clean_derived_data():
    """Clean Xcode derived data to force refresh"""
    print("Cleaning derived data...")
    
    derived_data_path = os.path.expanduser("~/Library/Developer/Xcode/DerivedData/")
    
    # Find Signal-related derived data folders
    if os.path.exists(derived_data_path):
        for folder in os.listdir(derived_data_path):
            if "Signal" in folder:
                folder_path = os.path.join(derived_data_path, folder)
                print(f"Removing: {folder_path}")
                run_command(f'rm -rf "{folder_path}"', check=False)
    
    print("✅ Cleaned derived data")

def main():
    """Main function to fix code signing issues"""
    print("🔧 Fixing Code Signing and Bundle ID Issues...")
    print("=" * 50)
    
    # Check if we're in the right directory
    if not os.path.exists("Signal.xcodeproj"):
        print("❌ Error: Signal.xcodeproj not found. Make sure you're in the project root directory.")
        sys.exit(1)
    
    # Backup the project
    print("📦 Creating backup...")
    backup_cmd = "cp -r Signal.xcodeproj Signal.xcodeproj.signing.backup"
    run_command(backup_cmd)
    
    try:
        # Step 1: Fix bundle identifiers
        print("\\n1️⃣ Fixing bundle identifiers...")
        fix_bundle_identifiers()
        
        # Step 2: Clean derived data
        print("\\n2️⃣ Cleaning derived data...")
        clean_derived_data()
        
        # Step 3: Get development team info
        print("\\n3️⃣ Getting development team info...")
        team = get_development_team()
        
        print("\\n🎉 Code Signing Fixes Complete!")
        print("=" * 50)
        print("✅ Bundle identifiers simplified:")
        print("   • Main app: com.munir.munrchat") 
        print("   • NSE: com.munir.munrchat.nse")
        print("   • Share: com.munir.munrchat.share")
        print()
        print("✅ Automatic code signing enabled")
        print("✅ Derived data cleaned")
        print()
        print("🔄 Next Steps:")
        print("1. Open Xcode")
        print("2. Select the MunrChat target")
        print("3. Go to Signing & Capabilities")
        print("4. Sign in with your Apple ID")
        print("5. Enable 'Automatically manage signing'")
        print("6. Select your team")
        print("7. Build and run!")
        
    except Exception as e:
        print(f"❌ Error during fixes: {e}")
        print("🔄 Restoring backup...")
        restore_cmd = "rm -rf Signal.xcodeproj && mv Signal.xcodeproj.signing.backup Signal.xcodeproj"
        run_command(restore_cmd, check=False)
        sys.exit(1)

if __name__ == "__main__":
    main()
