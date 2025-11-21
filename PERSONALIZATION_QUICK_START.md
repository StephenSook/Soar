# Personalization System - Quick Start Guide

## 🚀 Testing the New Personalization Feature

### Running the App
```bash
cd /Users/tylin/Soar
flutter pub get
flutter run -d chrome  # or -d macos
```

## 📋 Test Checklist

### ✅ Test 1: New User Onboarding
1. **Sign up** with a new account
2. **Verify** you're redirected to personalization questionnaire (not home)
3. **Check progress bar** shows 5 steps at top
4. **Complete Page 1 (Interests)**
   - Select multiple interests (e.g., Meditation, Journaling)
   - Verify chips turn gradient orange/yellow when selected
   - Tap "Next"
5. **Complete Page 2 (Mental Health)**
   - Select focus areas (e.g., Anxiety, Stress)
   - Verify visual feedback on selection
   - Tap "Next"
6. **Complete Page 3 (Content)**
   - Toggle content preferences on/off
   - Verify switches work smoothly
   - Tap "Next"
7. **Complete Page 4 (Reminder Time)**
   - View default time (9:00 AM)
   - Tap "Change Time" button
   - Select custom time
   - Tap "Next"
8. **Complete Page 5 (App Blocking)**
   - Select apps to block (optional)
   - Read info message
   - Tap "Complete"
9. **Verify** you're redirected to home screen
10. **Check** mood check-in dialog appears

### ✅ Test 2: Skip Functionality
1. **Sign up** with a new account
2. **Tap "Skip"** in top-right of questionnaire
3. **Verify** you go directly to home screen
4. **Check** you can still access preferences later

### ✅ Test 3: Back Navigation
1. Start personalization questionnaire
2. Advance to page 3
3. **Tap "Back" button**
4. **Verify** you return to page 2
5. **Check** previous selections are preserved

### ✅ Test 4: Edit Preferences (Existing User)
1. **Log in** with existing account
2. Go to **Profile** tab (bottom navigation)
3. Tap **"My Preferences"** in Account section
4. **Verify** three tabs appear: Interests, Focus Areas, Content
5. **Switch between tabs**
   - Check all tabs load correctly
   - Verify current selections are shown
6. **Make changes**:
   - Tap an interest to deselect it
   - Toggle a content preference off
   - Change reminder time
7. **Tap "Save"** in top-right
8. **Verify** success message appears

### ✅ Test 5: Personalized Recommendations
1. **Set specific preferences**:
   - Interests: Meditation, Stress Relief
   - Mental Health: Anxiety
   - Content: All enabled
2. **Complete mood check-in** with "Anxious" mood
3. Go to **Explore/Recommendations** tab
4. **Verify recommendations**:
   - Should see anxiety-related books
   - Calming meditation videos
   - Stress-relief content
   - Nutrition tips for anxiety
5. **Check** relevance scores (higher for matching content)

### ✅ Test 6: Content Filtering
1. **Edit preferences**
2. **Disable "videos"** content preference
3. **Save changes**
4. **Go to recommendations**
5. **Verify** no video recommendations appear
6. **Enable videos again** and verify they return

### ✅ Test 7: UI Consistency
Check warm color scheme throughout:
- ✅ Orange/yellow gradients on selected items
- ✅ Warm backgrounds (#FFFBF5)
- ✅ Consistent button styling
- ✅ Smooth animations
- ✅ Proper shadows and elevation

## 🎯 What to Look For

### Visual Design
- [ ] **Progress bar** fills correctly (1/5, 2/5, etc.)
- [ ] **Selected chips** have gradient background + shadow
- [ ] **Deselected chips** are white with gray border
- [ ] **Icons** are appropriate for each option
- [ ] **Time picker** displays in large, readable format
- [ ] **Switches** have orange accent when on
- [ ] **Save button** shows loading spinner when saving

### Functionality
- [ ] **All selections** persist across page navigation
- [ ] **Back button** restores previous page state
- [ ] **Skip button** always accessible
- [ ] **Time picker** opens modal dialog
- [ ] **App checkboxes** toggle correctly
- [ ] **Save** updates Firebase immediately
- [ ] **Success message** appears after save

### Data Integration
- [ ] **User profile** contains all preference data
- [ ] **Recommendations** change based on preferences
- [ ] **Content filtering** works (disabled types don't appear)
- [ ] **Relevance boosting** prioritizes matching content
- [ ] **Queries** incorporate user interests

## 🐛 Common Issues & Solutions

### Issue: Stuck on Personalization Screen
**Solution**: Check that route is properly configured in `main.dart`
```dart
'/personalization': (context) => const PersonalizationScreen(),
```

### Issue: Preferences Not Saving
**Solution**: 
1. Check Firebase connection
2. Verify user is authenticated
3. Check console for errors
4. Ensure `AuthService.updateUserProfile()` is called

### Issue: Recommendations Not Personalized
**Solution**:
1. Verify preferences are saved in Firestore
2. Check recommendation service receives user profile
3. Look for boost calculations in console logs
4. Ensure content preferences are being checked

### Issue: Images Not Loading
**Solution**: This is expected - onboarding images removed, gradients used
```dart
// Fallback gradients automatically used
Container(
  decoration: BoxDecoration(
    gradient: LinearGradient(colors: [...]),
  ),
)
```

## 📱 User Interface Tour

### Personalization Questionnaire
```
┌─────────────────────────────────────┐
│  [Skip]                              │
│  ▰▰▰▰▰▱▱▱▱▱ Progress (3/5)          │
├─────────────────────────────────────┤
│                                      │
│  What are you interested in?         │
│  Select all that apply...            │
│                                      │
│  [🧘 Meditation] [📖 Journaling]    │
│  [😌 Stress Relief] [😴 Sleep]     │
│  [💪 Fitness] [👥 Social]          │
│  [📈 Growth] [🌬️ Breathing]       │
│                                      │
│                                      │
├─────────────────────────────────────┤
│  [← Back]     [Next →]              │
└─────────────────────────────────────┘
```

### Preferences Screen
```
┌─────────────────────────────────────┐
│  ← My Preferences         [Save]     │
│  ─────────────────────────────────  │
│  Interests  Focus Areas  Content     │
│  ▔▔▔▔▔▔▔▔                           │
├─────────────────────────────────────┤
│                                      │
│  What are you interested in?         │
│  Select all to personalize...        │
│                                      │
│  [🧘 Meditation] [📖 Journaling]    │
│  [😌 Stress Relief] [😴 Sleep]     │
│                                      │
│  (scroll for more)                   │
│                                      │
└─────────────────────────────────────┘
```

## 🔍 Debugging Tips

### Enable Verbose Logging
```dart
// In recommendation_service.dart
debugPrint('Boosted "$title" by $boost points');
debugPrint('Building query from interests: $interests');
```

### Check Firebase Data
```bash
# Open Firebase Console
# Navigate to Firestore
# Find users/{userId}
# Verify these fields exist:
# - interests: []
# - mentalHealthHistory: []
# - contentPreferences: {}
# - moodCheckInTime: "HH:MM"
```

### Test Individual Components
```dart
// Test AuthService update
await authService.updateUserProfile(
  interests: ['test'],
);
print(authService.currentUserModel?.interests);

// Test recommendation filtering
final prefs = {'videos': false};
// Verify videos don't appear
```

## ✨ Success Criteria

Your personalization system is working correctly when:

1. ✅ **New users** complete questionnaire before reaching home
2. ✅ **Existing users** can edit preferences anytime from profile
3. ✅ **All preferences** save to Firebase correctly
4. ✅ **Recommendations** filter based on content preferences
5. ✅ **Relevance scores** boost for matching interests
6. ✅ **UI is consistent** with warm color scheme throughout
7. ✅ **Navigation flows** smoothly (back/next/skip)
8. ✅ **No errors** in console during normal operation

## 📊 Expected Behavior

### Recommendation Scenarios

#### Anxiety + Meditation User
**Preferences**: Mental Health: Anxiety | Interests: Meditation
**Expected**:
- Books about "anxiety relief mindfulness"
- Videos: "calming meditation anxiety relief"
- Nutrition: "Try chamomile tea and omega-3s"
- **Boost**: +2.0 for anxiety content, +1.5 for meditation

#### Sleep Issues User
**Preferences**: Mental Health: Sleep Issues | Interests: Better Sleep
**Expected**:
- Books about "better sleep"
- Movies: Documentary & History (relaxing)
- Nutrition: "Avoid caffeine after 2pm, try magnesium"
- **Boost**: +2.0 for sleep content

#### Personal Growth User
**Preferences**: Interests: Personal Growth | Content: Articles only
**Expected**:
- Only books/articles (no videos)
- Books about "personal development"
- Movies: Drama & Documentary
- **Boost**: +1.5 for growth content

## 🎉 You're Ready!

The personalization system is fully functional and integrated. Test it thoroughly and enjoy the warm, personalized user experience!

**Questions?** Refer to `PERSONALIZATION_SYSTEM.md` for detailed documentation.

