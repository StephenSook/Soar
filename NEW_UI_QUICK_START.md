# Quick Start Guide - New UI

## Testing the Redesigned SOAR App

### Prerequisites
- Flutter SDK installed
- Web browser for testing (Chrome recommended)
- All dependencies from `pubspec.yaml` installed

### Running the App

#### Option 1: Web (Recommended for UI Testing)
```bash
# Navigate to project directory
cd /Users/tylin/Soar

# Get dependencies
flutter pub get

# Run on web
flutter run -d chrome
```

#### Option 2: iOS Simulator
```bash
flutter run -d "iPhone 15 Pro"
```

#### Option 3: macOS Desktop
```bash
flutter run -d macos
```

### What to Look For

#### 1. Splash Screen (3 seconds)
- **Warm gradient** background (orange → golden → yellow)
- **Glowing logo** with shadow effects
- **Smooth animations** (fade + scale)
- **Loading indicator** at bottom

#### 2. Onboarding (First Time Only)
- **Beautiful images** from soar-images folder
- **Lakeside scene** on first page
- **Beach scene** on second page
- **Landscape scenes** on subsequent pages
- **Smooth page transitions**
- **Colored progress indicators**
- **Back/Next navigation**

To see onboarding again:
```dart
// Clear app data or modify SharedPreferences
// Or just run: flutter run --clear-cache
```

#### 3. Login Screen
- **Clean white input boxes** with soft shadows
- **Gradient button** (orange to golden)
- **Logo with gradient background**
- **Warm overall feel**

#### 4. Home Screen (Main Feature)
- **Hero image** at top (lakeside)
  - Scroll up to collapse
  - Shows "Hello, [name]!" greeting
  - Dynamic message based on time of day

- **Mood Check-In Card**
  - Gradient background if not checked in
  - Green gradient if complete
  - Action button appears when needed

- **Progress Stats**
  - Three columns: Streak, Check-ins, Avg Mood
  - Color-coded icons
  - Separated by dividers

- **Daily Inspiration**
  - Large image card with quote
  - Changes daily
  - Beautiful overlay text

- **Wellness Tools**
  - Horizontal scroll
  - Gradient cards for each tool:
    - Meditation (orange/golden)
    - Journal (golden/yellow)
    - Breathe (yellow/orange)
    - Crisis Help (red)

- **Bottom Navigation**
  - Rounded active indicators
  - Smooth animations
  - Custom styling

### Color Verification

The new warm color scheme should be visible everywhere:
- **Primary Orange**: `#FF8C42` - Main buttons, active states
- **Golden Yellow**: `#FFD54F` - Accents, gradients
- **Warm White**: `#FFFBF5` - Background
- **Rich Black**: `#1A1A1A` - Primary text

### Image Loading

If images don't load, you should see:
- **Gradient fallbacks** that match the color scheme
- **No broken image icons**
- **Graceful degradation**

To ensure images load:
```bash
# Verify images exist
ls -la soar-images/
# Should show: beach.jpg, lakeside-pic.jpg, landscape1.jpg, landscape2.jpg

# Clean and rebuild
flutter clean
flutter pub get
flutter run -d chrome
```

### Testing Different States

#### To Test Mood Check-In Flow:
1. Open app
2. Dismiss or complete the check-in dialog
3. Navigate to Home
4. Click "Check In Now" button
5. Complete the mood check-in
6. Return to home to see updated card

#### To Test Different Times of Day:
Change system time to see different greetings:
- Before 12pm: "Good morning! Ready to start your day?"
- 12pm-5pm: "Good afternoon! How are you feeling?"
- After 5pm: "Good evening! Time to unwind."

#### To Test Quick Actions:
1. Scroll to "Wellness Tools"
2. Tap each card to navigate
3. Notice gradient backgrounds and smooth transitions

### Responsive Behavior

Test different window sizes:
```bash
# Web: Resize browser window
# Should maintain good layout at various sizes

# Desktop: Try different screen resolutions
# Layout should adapt gracefully
```

### Performance Checks

- **Smooth scrolling** on home screen
- **Quick page transitions** in onboarding
- **Instant button feedback**
- **Smooth animations** (no jank)

### Common Issues & Solutions

#### Issue: Images Not Showing
```bash
# Solution 1: Clean build
flutter clean
flutter pub get

# Solution 2: Check pubspec.yaml has:
assets:
  - soar-images/

# Solution 3: Hot restart (R key) instead of hot reload (r key)
```

#### Issue: Colors Look Wrong
```bash
# Clear cache and restart
flutter clean
flutter run -d chrome
```

#### Issue: Layout Looks Broken
```bash
# Check you're running latest code
git status
# Ensure no local modifications to theme.dart or screen files
```

### Key Features to Demo

1. **Hero Image Collapse**: Scroll home screen up and down
2. **Onboarding Flow**: Clear data and restart to see full flow
3. **Gradient Buttons**: Hover/tap to see effects
4. **Card Shadows**: Notice subtle elevation on cards
5. **Progress Stats**: Check the three-column layout
6. **Daily Inspiration**: Beautiful overlay on image
7. **Wellness Tools**: Horizontal scroll with gradients
8. **Bottom Nav**: Tap different tabs to see animation

### Browser DevTools (Web Testing)

Press F12 to open DevTools:
- **Responsive Mode**: Test different screen sizes
- **Performance**: Check frame rates (should be 60fps)
- **Console**: Verify no errors
- **Network**: Check image loading

### Screenshots to Take

For documentation:
1. Splash screen with gradient
2. Onboarding page with lakeside image
3. Login screen with gradient button
4. Home screen - full view
5. Home screen - scrolled with hero collapsed
6. Mood check-in card - both states
7. Progress stats section
8. Daily inspiration card
9. Wellness tools cards
10. Bottom navigation with active state

### Feedback Points

When reviewing the new design, consider:
- **Warmth**: Does it feel inviting and comfortable?
- **Clarity**: Is information easy to find and read?
- **Flow**: Are transitions smooth and logical?
- **Images**: Do they enhance the emotional experience?
- **Colors**: Are warm tones consistent throughout?
- **Spacing**: Does everything have room to breathe?
- **Accessibility**: Is text readable and touch targets adequate?

### Next Steps After Testing

If you want to:
1. **Adjust colors**: Edit `/lib/utils/theme.dart`
2. **Change images**: Replace files in `soar-images/` folder
3. **Modify layouts**: Edit specific screen files
4. **Update copy**: Edit text in screen files
5. **Add features**: Build on the new design foundation

### Support

If something doesn't look right:
1. Check console for errors
2. Verify all dependencies installed
3. Try clean build
4. Check that images exist in soar-images/
5. Ensure running on supported platform (web, iOS, macOS)

---

**Enjoy the new warm, beautiful UI! 🌅**

