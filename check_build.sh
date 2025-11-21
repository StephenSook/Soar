#!/bin/bash
# Script to check if your Flutter app is building

echo "🔍 Checking Flutter build status..."
echo ""

# Check if Flutter is running
FLUTTER_RUNNING=$(ps aux | grep "flutter run" | grep -v grep | wc -l)
if [ $FLUTTER_RUNNING -gt 0 ]; then
    echo "✅ Flutter build is RUNNING"
    echo ""
    ps aux | grep "flutter run" | grep -v grep | head -3
else
    echo "❌ Flutter build is NOT running"
fi

echo ""
echo "---"
echo ""

# Check if Xcode is building
XCODE_RUNNING=$(ps aux | grep "xcodebuild" | grep -v grep | wc -l)
if [ $XCODE_RUNNING -gt 0 ]; then
    echo "✅ Xcode build is RUNNING"
    echo ""
    ps aux | grep "xcodebuild" | grep -v grep | head -2
else
    echo "❌ Xcode build is NOT running"
fi

echo ""
echo "---"
echo ""

# Check device connection
echo "📱 Connected devices:"
flutter devices | grep "Ty (2)"

echo ""
echo "---"
echo ""
echo "💡 To manually start the build, run:"
echo "   cd /Users/tylin/Soar"
echo "   flutter run -d 00008140-001E75880CF0801C"


