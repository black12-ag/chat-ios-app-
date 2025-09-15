#!/usr/bin/env python3
"""
Automated Xcode Project Signing Fix
Fixes all signing and bundle ID issues for MunrChat iOS deployment
"""

import re
import os
import subprocess

def fix_project_settings():
    project_file = "MunrChat.xcodeproj/project.pbxproj"
    
    print("🔧 Fixing MunrChat iOS project signing settings...")
    
    # Read the project file
    with open(project_file, 'r') as f:
        content = f.read()
    
    # Your development team ID (from security command)
    new_team_id = "7GLX25YPH8"  # Your team ID from the certificate
    
    # Fix 1: Replace old team ID with new one
    print("✅ Updating development team ID...")
    content = re.sub(r'DEVELOPMENT_TEAM = U68MSDN6DR;', f'DEVELOPMENT_TEAM = {new_team_id};', content)
    content = re.sub(r'"U68MSDN6DR"', f'"{new_team_id}"', content)
    
    # Fix 2: Update bundle identifiers
    print("✅ Updating bundle identifiers...")
    bundle_id_mappings = {
        'org.munrchat.munrchat': 'com.munir.munrchat.ios',
        'org.munrchat.munrchat.shareextension': 'com.munir.munrchat.ios.shareext',
        'org.munrchat.munrchat.MunrChatNSE': 'com.munir.munrchat.ios.nse'
    }
    
    for old_id, new_id in bundle_id_mappings.items():
        content = re.sub(re.escape(old_id), new_id, content)
    
    # Fix 3: Enable automatic signing
    print("✅ Enabling automatic code signing...")
    content = re.sub(r'CODE_SIGN_STYLE = Manual;', 'CODE_SIGN_STYLE = Automatic;', content)
    content = re.sub(r'ProvisioningStyle = Manual;', 'ProvisioningStyle = Automatic;', content)
    
    # Fix 4: Set code signing identity
    print("✅ Setting code signing identity...")
    content = re.sub(r'CODE_SIGN_IDENTITY = ".*";', 'CODE_SIGN_IDENTITY = "Apple Development";', content)
    
    # Write the updated content back
    with open(project_file, 'w') as f:
        f.write(content)
    
    print("🎉 All project settings fixed!")
    print("📱 Ready for device deployment!")

if __name__ == "__main__":
    fix_project_settings()
