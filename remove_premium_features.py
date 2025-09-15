#!/usr/bin/env python3
"""
Remove Premium iOS Capabilities for Free Developer Account
Removes features that require paid Apple Developer account
"""

import re
import os

def remove_premium_capabilities():
    project_file = "MunrChat.xcodeproj/project.pbxproj"
    
    print("🔧 Removing premium capabilities for free developer account...")
    
    # Read the project file
    with open(project_file, 'r') as f:
        content = f.read()
    
    # Premium capabilities to remove
    premium_capabilities = [
        'com.apple.InAppPurchase',
        'com.apple.developer.applesignin',
        'com.apple.developer.associated-domains',
        'com.apple.developer.default-data-protection',
        'com.apple.developer.usernotifications.communication',
        'com.apple.external-accessory.wireless-configuration',
        'com.apple.security.application-groups',
        'push-notifications',
        'keychain-access-groups',
        'aps-environment'
    ]
    
    print("✅ Removing premium entitlements...")
    for capability in premium_capabilities:
        # Remove entire entitlement blocks
        content = re.sub(rf'<key>{capability}</key>\s*<[^>]+>[^<]*</[^>]+>', '', content)
        content = re.sub(rf'{capability}[^;]*;', '', content)
    
    # Remove entire SystemConfiguration.framework dependency (causes issues)
    print("✅ Removing problematic frameworks...")
    content = re.sub(r'SystemConfiguration\.framework[^;]*;', '', content)
    
    # Simplify bundle IDs to basic format
    print("✅ Simplifying bundle identifiers...")
    content = re.sub(r'com\.munir\.munrchat\.ios\.shareext', 'com.munir.munrchat.share', content)
    content = re.sub(r'com\.munir\.munrchat\.ios\.nse', 'com.munir.munrchat.notify', content)
    
    # Write the updated content back
    with open(project_file, 'w') as f:
        f.write(content)
    
    # Also clean up entitlements files
    entitlement_files = [
        "MunrChat/MunrChat.entitlements",
        "MunrChat/MunrChat-AppStore.entitlements"
    ]
    
    for ent_file in entitlement_files:
        if os.path.exists(ent_file):
            print(f"✅ Cleaning {ent_file}...")
            with open(ent_file, 'r') as f:
                ent_content = f.read()
            
            # Remove premium entitlements
            for capability in premium_capabilities:
                ent_content = re.sub(rf'<key>{capability}</key>\s*<[^>]+>[^<]*</[^>]+>', '', ent_content)
            
            with open(ent_file, 'w') as f:
                f.write(ent_content)
    
    print("🎉 All premium features removed!")
    print("📱 App should now build with free developer account!")

if __name__ == "__main__":
    remove_premium_capabilities()
