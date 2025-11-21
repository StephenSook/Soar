# 🚀 Install Flutter on macOS

## Quick Install (Recommended Method)

You have two options: **Using Homebrew** (easiest) or **Manual Installation**.

---

## Method 1: Install with Homebrew (Easiest) ⭐

Since you already have Homebrew installed, this is the fastest method:

### Step 1: Install Flutter

```bash
# Install Flutter
brew install --cask flutter

# Verify installation
flutter --version
```

### Step 2: Run Flutter Doctor

```bash
flutter doctor
```

This will check your setup and tell you what else needs to be installed.

---

## Method 2: Manual Installation (More Control)

### Step 1: Download Flutter

```bash
# Create a directory for Flutter
cd ~
mkdir -p development
cd development

# Download Flutter SDK (Apple Silicon Mac)
curl -O https://storage.googleapis.com/flutter_infra_release/releases/stable/macos/flutter_macos_arm64_3.24.5-stable.zip

# Extract the zip file
unzip flutter_macos_arm64_3.24.5-stable.zip

# Remove the zip file
rm flutter_macos_arm64_3.24.5-stable.zip
```

**Note**: If you have an Intel Mac, use:
```bash
curl -O https://storage.googleapis.com/flutter_infra_release/releases/stable/macos/flutter_macos_3.24.5-stable.zip
unzip flutter_macos_3.24.5-stable.zip
```

### Step 2: Add Flutter to Your PATH

You're using **zsh** (macOS default), so edit your `~/.zshrc`:

```bash
# Open your zsh config
open -e ~/.zshrc

# Add this line at the end:
export PATH="$HOME/development/flutter/bin:$PATH"

# Save and reload
source ~/.zshrc
```

Or do it in one command:

```bash
echo 'export PATH="$HOME/development/flutter/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

### Step 3: Verify Installation

```bash
# Check Flutter version
flutter --version

# Run Flutter doctor
flutter doctor
```

---

## Step 3: Install Required Dependencies

After installing Flutter, run:

```bash
flutter doctor
```

You'll likely need to install:

### A. Xcode (for iOS development)

1. **Install Xcode from App Store** (it's free but large, ~12GB)
   - Search "Xcode" in App Store
   - Click "Get" or "Install"

2. **Accept Xcode license**:
   ```bash
   sudo xcodebuild -license accept
   ```

3. **Install Xcode Command Line Tools**:
   ```bash
   sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
   sudo xcodebuild -runFirstLaunch
   ```

4. **Install CocoaPods** (for iOS dependencies):
   ```bash
   sudo gem install cocoapods
   ```

### B. Android Studio (for Android development)

1. **Download Android Studio**:
   ```
   https://developer.android.com/studio
   ```

2. **Install Android Studio**:
   - Open the downloaded `.dmg` file
   - Drag Android Studio to Applications
   - Launch Android Studio

3. **Setup Android SDK**:
   - Open Android Studio
   - Go through the setup wizard
   - Install Android SDK, Android SDK Platform Tools, and Android SDK Build Tools

4. **Configure Flutter**:
   ```bash
   flutter config --android-studio-dir /Applications/Android\ Studio.app
   ```

5. **Accept Android licenses**:
   ```bash
   flutter doctor --android-licenses
   ```
   Press 'y' to accept all licenses.

---

## Step 4: Verify Everything Works

```bash
# Run flutter doctor to check status
flutter doctor -v

# You should see checkmarks ✓ for:
# ✓ Flutter
# ✓ Android toolchain
# ✓ Xcode
# ✓ Chrome (for web development)
# ✓ Android Studio
# ✓ VS Code or IntelliJ (if installed)
```

---

## Step 5: Install Your Project Dependencies

Once Flutter is installed:

```bash
# Navigate to your project
cd /Users/tylin/Soar

# Get dependencies
flutter pub get

# Run your app
flutter run
```

---

## Quick Command Reference

After installation, you'll use these commands:

```bash
# Check Flutter version
flutter --version

# Check system status
flutter doctor

# Get project dependencies
flutter pub get

# Run app (with device connected)
flutter run

# Build for iOS
flutter build ios

# Build for Android
flutter build apk

# Clean build cache
flutter clean
```

---

## Troubleshooting

### "Command not found: flutter"

**Solution 1**: Reload your shell
```bash
source ~/.zshrc
```

**Solution 2**: Check PATH
```bash
echo $PATH
# Should include /path/to/flutter/bin
```

**Solution 3**: Manually add to current session
```bash
export PATH="$HOME/development/flutter/bin:$PATH"
```

### Xcode Issues

```bash
# Reset Xcode command line tools
sudo xcode-select --reset

# Switch to Xcode
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer

# Run first launch
sudo xcodebuild -runFirstLaunch
```

### CocoaPods Issues

```bash
# Update CocoaPods
sudo gem install cocoapods

# Update repo
pod repo update

# In your project
cd /Users/tylin/Soar/ios
pod install
```

### Android License Issues

```bash
# Accept all licenses
flutter doctor --android-licenses

# Press 'y' for each license
```

---

## System Requirements

- **macOS**: 10.14 (Mojave) or later (you have 25.1.0 ✓)
- **Disk Space**: At least 2.8 GB (not including IDE)
- **Tools**: bash, curl, git, mkdir, rm, unzip, which, zip

---

## What Gets Installed

### With Flutter:
- ✓ Dart SDK (included with Flutter)
- ✓ Flutter command-line tools
- ✓ Flutter framework

### You Need to Install:
- Xcode (for iOS development)
- Android Studio (for Android development)
- CocoaPods (for iOS dependencies)

---

## Recommended: Install VS Code Flutter Extension

If you use VS Code:

1. Open VS Code
2. Go to Extensions (Cmd+Shift+X)
3. Search for "Flutter"
4. Install the official Flutter extension
5. Install the Dart extension (usually installs automatically)

---

## Quick Start After Installation

```bash
# 1. Navigate to your project
cd /Users/tylin/Soar

# 2. Get dependencies
flutter pub get

# 3. Check what devices are available
flutter devices

# 4. Run on a device
flutter run

# Or specify a device
flutter run -d chrome        # Web
flutter run -d macos         # macOS app
flutter run -d ios           # iOS simulator
flutter run -d android       # Android emulator
```

---

## Estimated Installation Time

| Component | Time |
|-----------|------|
| Flutter SDK | 5-10 minutes |
| Xcode | 30-60 minutes (large download) |
| Android Studio | 15-30 minutes |
| Setup & Config | 10-20 minutes |
| **Total** | **~1-2 hours** |

---

## Next Steps After Installation

1. ✅ Verify: `flutter doctor` shows all green checkmarks
2. ✅ Install dependencies: `cd /Users/tylin/Soar && flutter pub get`
3. ✅ Test run: `flutter run`
4. ✅ Follow the API setup guides in your project

---

## Quick Install Script (All-in-One)

If you want to automate the Homebrew method:

```bash
#!/bin/bash

echo "Installing Flutter..."

# Install Flutter
brew install --cask flutter

# Accept licenses
flutter doctor --android-licenses

# Install CocoaPods
sudo gem install cocoapods

# Setup project
cd /Users/tylin/Soar
flutter pub get

echo "✅ Flutter installation complete!"
echo "Run 'flutter doctor' to check status"
```

Save this as `install_flutter.sh`, make it executable, and run:

```bash
chmod +x install_flutter.sh
./install_flutter.sh
```

---

## Important Notes

1. **Xcode is REQUIRED for iOS development** - It's a large download (~12GB)
2. **Android Studio is REQUIRED for Android development** - Also large (~1GB+)
3. **CocoaPods is REQUIRED for iOS dependencies** - Installs via Ruby gems
4. **You can develop for macOS and web without Xcode/Android Studio**

---

## Resources

- [Official Flutter Installation Guide](https://docs.flutter.dev/get-started/install/macos)
- [Flutter Documentation](https://docs.flutter.dev/)
- [Flutter YouTube Channel](https://www.youtube.com/c/flutterdev)
- [Flutter Discord Community](https://discord.com/invite/flutter)

---

**Ready to install? Start with Method 1 (Homebrew) - it's the easiest!** 🚀

