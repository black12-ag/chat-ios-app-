#!/usr/bin/env python3
"""
Update App Icon for MunrChat
Replaces Signal icons with custom logo
"""

import os
import shutil
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

def find_logo_file():
    """Find the user's custom logo file"""
    
    # Common locations to check for logo files
    search_locations = [
        "/Users/munir011/Desktop/",
        "/Users/munir011/Downloads/",
        "/Users/munir011/Documents/",
        "/Users/munir011/Desktop/test/",
        "/Users/munir011/Desktop/test/MunrChat-iOS/",
    ]
    
    # Common logo file patterns
    logo_patterns = [
        "logo.*",
        "icon.*", 
        "app_icon.*",
        "munir_logo.*",
        "munrchat_logo.*",
        "chat_icon.*",
        "*.png",
        "*.jpg", 
        "*.jpeg",
        "*.svg",
    ]
    
    print("Searching for logo files...")
    
    for location in search_locations:
        if os.path.exists(location):
            print(f"Checking: {location}")
            
            try:
                files = os.listdir(location)
                for file in files:
                    # Check if file matches logo patterns
                    file_lower = file.lower()
                    if any(word in file_lower for word in ['logo', 'icon', 'chat', 'munir']):
                        if file_lower.endswith(('.png', '.jpg', '.jpeg', '.svg')):
                            full_path = os.path.join(location, file)
                            print(f"Found potential logo: {full_path}")
                            return full_path
            except PermissionError:
                continue
    
    return None

def create_icon_sizes(source_image_path):
    """Create all required icon sizes from the source image"""
    
    if not source_image_path or not os.path.exists(source_image_path):
        print("❌ Source image not found")
        return False
    
    print(f"Creating icon sizes from: {source_image_path}")
    
    # Required icon sizes for iOS apps
    icon_sizes = {
        "20": [20, 40, 60],      # iPhone Notification
        "29": [29, 58, 87],      # iPhone Settings  
        "40": [40, 80, 120],     # iPhone Spotlight
        "60": [120, 180],        # iPhone App
        "1024": [1024],          # App Store
        # iPad sizes
        "20": [20, 40],          # iPad Notification
        "29": [29, 58],          # iPad Settings
        "40": [40, 80],          # iPad Spotlight  
        "76": [76, 152],         # iPad App
        "83.5": [167],           # iPad Pro App
    }
    
    # Flattened list of all required sizes
    required_sizes = [20, 29, 40, 58, 60, 76, 80, 87, 120, 152, 167, 180, 1024]
    
    # Create temp directory for generated icons
    temp_dir = "temp_icons"
    os.makedirs(temp_dir, exist_ok=True)
    
    print("Generating icon sizes...")
    
    # Use sips (macOS built-in image tool) to resize
    for size in required_sizes:
        output_file = f"{temp_dir}/icon_{size}x{size}.png"
        
        # Use sips to resize the image
        cmd = f'sips -z {size} {size} "{source_image_path}" --out "{output_file}"'
        result = run_command(cmd, check=False)
        
        if os.path.exists(output_file):
            print(f"✅ Created {size}x{size} icon")
        else:
            print(f"❌ Failed to create {size}x{size} icon")
    
    return temp_dir

def update_app_icon_assets(temp_dir):
    """Update the app icon assets with the new icons"""
    
    if not temp_dir or not os.path.exists(temp_dir):
        print("❌ Temp directory not found")
        return False
    
    # Path to the app icon assets
    app_icon_path = "Signal/AppIcon.xcassets/AppIcon.appiconset"
    
    if not os.path.exists(app_icon_path):
        print(f"❌ App icon assets not found: {app_icon_path}")
        return False
    
    print(f"Updating app icon assets in: {app_icon_path}")
    
    # Icon filename mappings (based on Contents.json)
    icon_mappings = {
        "Signal_20x20.png": "icon_20x20.png",
        "Signal_29x29.png": "icon_29x29.png", 
        "Signal_40x40.png": "icon_40x40.png",
        "Signal_58x58.png": "icon_58x58.png",
        "Signal_60x60.png": "icon_60x60.png",
        "Signal_76x76.png": "icon_76x76.png",
        "Signal_80x80.png": "icon_80x80.png", 
        "Signal_87x87.png": "icon_87x87.png",
        "Signal_120x120.png": "icon_120x120.png",
        "Signal_152x152.png": "icon_152x152.png",
        "Signal_167x167.png": "icon_167x167.png",
        "Signal_180x180.png": "icon_180x180.png",
        "Signal_1024x1024.png": "icon_1024x1024.png",
    }
    
    # Copy the generated icons to replace Signal icons
    for signal_icon, temp_icon in icon_mappings.items():
        temp_icon_path = os.path.join(temp_dir, temp_icon)
        signal_icon_path = os.path.join(app_icon_path, signal_icon)
        
        if os.path.exists(temp_icon_path):
            try:
                shutil.copy2(temp_icon_path, signal_icon_path)
                print(f"✅ Updated {signal_icon}")
            except Exception as e:
                print(f"❌ Failed to update {signal_icon}: {e}")
        else:
            print(f"⚠️  Temp icon not found: {temp_icon}")
    
    return True

def cleanup_temp_files(temp_dir):
    """Clean up temporary files"""
    if temp_dir and os.path.exists(temp_dir):
        shutil.rmtree(temp_dir)
        print(f"✅ Cleaned up temp directory: {temp_dir}")

def main():
    """Main function to update app icon"""
    print("🎨 Updating MunrChat App Icon...")
    print("=" * 50)
    
    # Check if we're in the right directory
    if not os.path.exists("Signal/AppIcon.xcassets"):
        print("❌ Error: App icon assets not found. Make sure you're in the project root directory.")
        sys.exit(1)
    
    try:
        # Step 1: Find the user's logo
        print("\\n1️⃣ Finding your logo file...")
        logo_path = find_logo_file()
        
        if not logo_path:
            print("❌ No logo file found automatically.")
            print("\\n📁 Please place your logo file in one of these locations:")
            print("   • Desktop")
            print("   • Downloads") 
            print("   • This project folder")
            print("\\n💡 Supported formats: PNG, JPG, JPEG, SVG")
            print("   Recommended: Square PNG file, 1024x1024 pixels")
            
            # Ask user for manual path
            manual_path = input("\\n🖼️  Enter the full path to your logo file (or press Enter to skip): ").strip()
            if manual_path and os.path.exists(manual_path):
                logo_path = manual_path
            else:
                print("❌ Skipping icon update - no logo provided")
                return
        
        print(f"✅ Using logo: {logo_path}")
        
        # Step 2: Create all required icon sizes
        print("\\n2️⃣ Creating app icon sizes...")
        temp_dir = create_icon_sizes(logo_path)
        
        if not temp_dir:
            print("❌ Failed to create icon sizes")
            return
        
        # Step 3: Update app icon assets
        print("\\n3️⃣ Updating app icon assets...")
        success = update_app_icon_assets(temp_dir)
        
        if success:
            print("\\n🎉 App Icon Update Complete!")
            print("=" * 50)
            print("✅ Your custom logo is now the MunrChat app icon!")
            print("✅ All required icon sizes generated")
            print("✅ App icon assets updated")
            print()
            print("🔄 Next Steps:")
            print("1. Build and run your app")
            print("2. Your custom logo will appear on the home screen")
            print("3. The app will be branded as MunrChat with your icon!")
        
        # Step 4: Cleanup
        print("\\n4️⃣ Cleaning up...")
        cleanup_temp_files(temp_dir)
        
    except Exception as e:
        print(f"❌ Error during icon update: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()
