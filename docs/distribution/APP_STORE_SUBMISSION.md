# noema: App Store Submission Guide

## Version 1.0 | Last Updated: 2025-11-18

Complete guide for submitting noema to the Apple App Store.

---

## Prerequisites Checklist

Before submitting, ensure you have:

- [ ] **Apple Developer Account** ($99/year)
  - Individual or Organization account
  - Active membership

- [ ] **App Store Connect Access**
  - Admin or App Manager role
  - Two-factor authentication enabled

- [ ] **Certificates & Profiles**
  - Development certificate
  - Distribution certificate
  - App Store provisioning profile

- [ ] **Testing Complete**
  - All features tested on real devices
  - No critical bugs
  - Performance meets standards (see ARCHITECTURE.md)

- [ ] **Legal & Compliance**
  - Privacy Policy published
  - Terms of Service published
  - EULA if applicable
  - Age rating determined

---

## Phase 1: Pre-Submission (1-2 Weeks)

### 1.1 Final Code Preparation

1. **Update Version Numbers**
   ```bash
   # In Xcode:
   # General → Identity
   # Version: 1.0
   # Build: 1
   ```

2. **Remove Debug Code**
   - Remove all `print()` statements
   - Remove test data generators
   - Remove backdoors or debug features

3. **Enable Production Mode**
   - Disable analytics in development
   - Point to production backend URLs
   - Enable crash reporting (if using)

4. **Code Signing**
   - Select "Generic iOS Device" target
   - Product → Archive
   - Verify signing with Distribution certificate

### 1.2 App Store Connect Setup

1. **Log in to App Store Connect**
   - Go to https://appstoreconnect.apple.com
   - Navigate to "My Apps"
   - Click "+" → New App

2. **Create App Record**
   ```
   Platform: iOS
   Name: noema
   Primary Language: English (U.S.)
   Bundle ID: com.noema.app (must match Xcode)
   SKU: noema-001 (unique identifier)
   User Access: Full Access
   ```

3. **App Information**
   ```
   Name: noema
   Subtitle: AI-Powered Emotional Wellness
   Category: Primary: Health & Fitness
            Secondary: Productivity
   ```

### 1.3 Prepare Marketing Assets

#### Screenshots (Required)

**iPhone 6.7" (iPhone 15 Pro Max):**
- 1290 x 2796 pixels
- 3 minimum, 10 maximum
- Show key features:
  1. Onboarding/Welcome
  2. Note taking with mood detection
  3. Mood dashboard
  4. Achievements/Progress
  5. Virtual garden

**iPhone 6.5" (iPhone 15 Plus):**
- 1284 x 2778 pixels
- Same as above

**iPad Pro 12.9" (Optional but recommended):**
- 2048 x 2732 pixels
- Same features

**Creation Tips:**
- Use real app UI (not mockups)
- Add localized text overlays
- Show value proposition clearly
- Use consistent design language

#### App Preview Video (Optional but recommended)

**Specifications:**
- Resolution: 1080p or 4K
- Duration: 15-30 seconds
- Format: .mov or .m4v
- Frame rate: 29.97 fps or 30 fps
- Aspect ratio: 16:9 or 9:16

**Content:**
1. Opening hook (3s): "Meet noema"
2. Feature showcase (20s): Core features
3. Call to action (2s): "Download now"

#### App Icon

- **Size:** 1024 x 1024 pixels
- **Format:** PNG or JPEG (no alpha channel)
- **Color space:** RGB
- **No text, no rounded corners** (applied by Apple)

### 1.4 Write App Store Description

#### Name (30 characters max)
```
noema
```

#### Subtitle (30 characters max)
```
AI-Powered Emotional Wellness
```

#### Promotional Text (170 characters, updateable without review)
```
New in 1.0: Voice notes, mood patterns, virtual garden, and 100+ achievements. Start your emotional wellness journey today!
```

#### Description (4000 characters max)

```
UNDERSTAND YOUR EMOTIONS. IMPROVE YOUR WELLBEING.

noema is the AI-native note-taking app that helps you understand your emotional patterns and improve your mental wellbeing through intelligent journaling.

🧠 EMOTIONAL INTELLIGENCE
• AI analyzes your notes to detect emotions
• Track mood over time with beautiful visualizations
• Discover patterns in your emotional wellbeing
• 8-dimensional emotion model for nuanced insights

✍️ POWERFUL NOTE-TAKING
• Write or speak your thoughts
• Voice-to-text transcription
• Auto-summarization with AI
• Smart entity extraction (people, places, events)
• Search notes by mood or content

📊 INSIGHTFUL ANALYTICS
• Mood timeline and trends
• Emotion distribution charts
• Correlation between activities and mood
• Weekly and monthly insights
• Export data for therapy sessions

🎮 ENGAGING GAMIFICATION
• 50-level progression system
• 100+ achievements to unlock
• Streak tracking (don't break the chain!)
• Virtual garden that grows with your progress
• Beautiful achievement cards to share

🔒 PRIVACY FIRST
• On-device AI processing by default
• End-to-end encryption
• No data sold to third parties
• GDPR & CCPA compliant
• Export or delete your data anytime

🌟 BEAUTIFUL DESIGN
• Elegant, intuitive interface
• Dark mode support
• Customizable themes
• Smooth animations
• Apple Design Awards quality

PERFECT FOR:
• Emotional self-awareness
• Mental health journaling
• Therapy preparation
• Stress management
• Personal growth
• Creative inspiration

FREE FEATURES:
• Unlimited notes
• Basic mood tracking
• 7-day mood history
• Core achievements
• On-device AI

PRO FEATURES: ($9.99/month or $79.99/year)
• Advanced mood analytics
• Unlimited mood history
• Cloud sync across devices
• Priority AI processing
• Export to PDF/CSV
• Custom themes
• Premium achievements
• Virtual garden expansions
• Priority support

noema uses state-of-the-art AI models running on your device to protect your privacy while providing intelligent insights. Our emotional intelligence engine understands the nuance of human emotion, helping you make sense of your feelings.

Whether you're working with a therapist, practicing mindfulness, or simply curious about your emotional patterns, noema is your AI companion for emotional wellness.

Download noema today and start your journey to better emotional understanding.

---

Terms of Service: https://noema.app/terms
Privacy Policy: https://noema.app/privacy
Support: [email protected]
```

#### Keywords (100 characters max, comma-separated)

```
journal,mood,wellness,mental health,emotions,therapy,mindfulness,AI,self-care,diary,feelings
```

#### Support URL
```
https://noema.app/support
```

#### Marketing URL (Optional)
```
https://noema.app
```

#### Privacy Policy URL
```
https://noema.app/privacy
```

---

## Phase 2: Build & Upload (1 Day)

### 2.1 Create Archive

1. **Clean Build Folder**
   - Product → Clean Build Folder (⇧⌘K)

2. **Select Generic iOS Device**
   - In toolbar, select "Any iOS Device (arm64)"

3. **Archive**
   - Product → Archive
   - Wait for build to complete

4. **Validate Archive**
   - Window → Organizer
   - Select archive
   - Click "Validate App"
   - Fix any issues

### 2.2 Upload to App Store Connect

1. **Distribute App**
   - Click "Distribute App"
   - Select "App Store Connect"
   - Click "Upload"

2. **Distribution Options**
   - ☑ Include bitcode: No (deprecated)
   - ☑ Upload your app's symbols: Yes
   - ☑ Manage Version and Build Number: Xcode managed

3. **Wait for Processing**
   - Usually 10-60 minutes
   - Check email for processing notifications
   - Status visible in App Store Connect

---

## Phase 3: App Store Connect Configuration (2-3 Hours)

### 3.1 Version Information

**What's New in This Version** (4000 characters max):
```
Welcome to noema 1.0!

NEW FEATURES:
• Voice notes with AI transcription
• Mood pattern detection
• Virtual garden visualization
• 100+ achievements
• Streak tracking
• Cloud sync (Pro)
• Advanced analytics (Pro)

HIGHLIGHTS:
• On-device AI for privacy
• Beautiful, intuitive interface
• Export data for therapy
• Dark mode support
• Customizable themes

Start your emotional wellness journey today!
```

### 3.2 App Review Information

**Contact Information:**
```
First Name: [Your First Name]
Last Name: [Your Last Name]
Phone: [Your Phone]
Email: [email protected]
```

**Demo Account (if login required):**
```
Username: [email protected]
Password: demo123456
Note: This is a demo account with sample data
```

**Notes:**
```
noema is an AI-powered emotional wellness app. All AI processing happens on-device by default for user privacy.

Key features to test:
1. Create a note (tap + button)
2. View mood detection (automatic after note creation)
3. View mood dashboard (Mood tab)
4. Log manual mood (Mood tab → Log Mood)
5. Check achievements (Progress tab)

The app does not require account creation for initial testing - you can use "Continue as Guest" in the authentication screen.

No subscription required for core features, but in-app purchase for Pro features is available for testing.
```

**Attachment (Optional):**
- Demo video showing app flow
- Special instructions PDF

### 3.3 Age Rating

**Questionnaire:**
```
Cartoon or Fantasy Violence: No
Realistic Violence: No
Prolonged Graphic or Sadistic Violence: No
Profanity or Crude Humor: No
Mature/Suggestive Themes: No
Horror/Fear Themes: No
Medical/Treatment Information: Yes
  Context: Mental health journaling and mood tracking
Alcohol, Tobacco, or Drug Use: No
Gambling: No
Sexual Content or Nudity: No
Unrestricted Web Access: No
```

**Result:** 4+ (All ages)

### 3.4 In-App Purchases

**Product 1: noema Pro Monthly**
```
Type: Auto-Renewable Subscription
Reference Name: noema Pro Monthly
Product ID: com.noema.app.pro.monthly
Duration: 1 Month
Price: $9.99 USD

Display Name: noema Pro
Description: Unlock all Pro features including advanced analytics, unlimited history, cloud sync, and premium themes.

Subscription Group: noema Pro
```

**Product 2: noema Pro Yearly**
```
Type: Auto-Renewable Subscription
Reference Name: noema Pro Yearly
Product ID: com.noema.app.pro.yearly
Duration: 1 Year
Price: $79.99 USD (save 33%)

Display Name: noema Pro (Annual)
Description: Best value! Unlock all Pro features for a full year.

Subscription Group: noema Pro
```

**Free Trial:**
- 7 days free trial
- Cancel anytime

### 3.5 App Privacy

**Data Collection:**

**Contact Info:**
- Email Address: Yes (for account, optional)
- Name: Yes (for profile, optional)
- Linked to user: Yes
- Used for tracking: No

**Health & Fitness:**
- Mood: Yes
- Emotional data: Yes
- Linked to user: Yes
- Used for tracking: No

**User Content:**
- Text notes: Yes
- Audio notes: Yes
- Linked to user: Yes
- Used for tracking: No

**Identifiers:**
- User ID: Yes
- Device ID: Yes
- Linked to user: No
- Used for tracking: No

**Usage Data:**
- Product Interaction: Yes
- Crash Data: Yes
- Performance Data: Yes
- Linked to user: No
- Used for tracking: No

**Privacy Policy URL:**
```
https://noema.app/privacy
```

---

## Phase 4: Submit for Review (Same Day)

### 4.1 Final Checks

- [ ] All screenshots uploaded
- [ ] App icon uploaded
- [ ] Description complete
- [ ] Keywords optimized
- [ ] Pricing set correctly
- [ ] In-app purchases configured
- [ ] Age rating set
- [ ] Privacy details complete
- [ ] Build selected

### 4.2 Submit

1. **Select Build**
   - Choose the uploaded build
   - Add to this version

2. **Export Compliance**
   ```
   Does your app use encryption? Yes
   Is your app exempt from encryption regulations? No
   Does your app implement any standard encryption? Yes

   ECCN: 5D002 (standard encryption)
   ```

3. **Advertising Identifier (IDFA)**
   ```
   Does this app use the Advertising Identifier? No
   ```

4. **Content Rights**
   - ☑ I certify that I have all rights to uploaded content

5. **Submit for Review**
   - Click "Submit for Review"
   - App enters "Waiting for Review" status

---

## Phase 5: App Review Process (1-7 Days)

### Status Lifecycle

1. **Waiting for Review** (1-3 days)
   - In queue
   - No action needed

2. **In Review** (1-2 days)
   - Being tested by Apple
   - Monitor email for questions

3. **Possible Outcomes:**
   - **Approved**: Ready for Sale → Releases automatically (or when you choose)
   - **Rejected**: Fix issues and resubmit
   - **Metadata Rejected**: Fix App Store info only
   - **Developer Rejected**: You can withdraw

### Common Rejection Reasons

**Guideline 2.1 - Performance**
- App crashes or has bugs
- **Fix:** Test thoroughly, use TestFlight

**Guideline 2.3 - Accurate Metadata**
- Screenshots don't match app
- **Fix:** Use actual app screenshots

**Guideline 4.3 - Spam**
- Similar to existing apps
- **Fix:** Highlight unique features

**Guideline 5.1.1 - Privacy**
- Missing privacy policy
- **Fix:** Add valid privacy policy URL

**Guideline 5.1.2 - Privacy: Data Use and Sharing**
- Unclear data usage
- **Fix:** Complete App Privacy section accurately

### Responding to Rejection

1. **Read Carefully**
   - Review rejection message
   - Check Resolution Center in App Store Connect

2. **Fix Issues**
   - Address all concerns
   - Update build if code changes needed
   - Update metadata if info changes needed

3. **Respond in Resolution Center**
   - Explain what you fixed
   - Be polite and professional
   - Resubmit for review

---

## Phase 6: Post-Approval (Launch Day)

### 6.1 Release

**Manual Release:**
- You control when app goes live
- Good for coordinating with marketing

**Automatic Release:**
- Goes live immediately after approval
- Fastest to market

### 6.2 Monitor Launch

**First 24 Hours:**
- Monitor crash reports
- Check user reviews
- Respond to support emails
- Watch social media mentions

**Analytics to Track:**
- Downloads
- Conversion rate (installs → users)
- Retention (D1, D7, D30)
- Crash-free users %
- Average rating

### 6.3 Marketing Launch

**Press Release:**
- Send to tech blogs
- Post on Product Hunt
- Share on social media

**App Store Optimization:**
- Monitor keyword rankings
- Test different screenshots (via A/B testing)
- Update promotional text weekly

---

## Phase 7: Post-Launch Updates

### Update Cycle

**Version 1.1** (2-4 weeks after 1.0):
- Bug fixes
- Minor improvements
- Based on user feedback

**Version 1.2** (6-8 weeks after 1.0):
- New features
- Performance improvements
- Major bug fixes

**Update Process:**
1. Increment version number
2. Update "What's New"
3. Create new archive
4. Upload to App Store Connect
5. Submit for review (faster than initial review)

---

## Appendix A: Checklist

### Pre-Submission
- [ ] Code complete and tested
- [ ] Version numbers set
- [ ] All certificates valid
- [ ] Privacy policy live
- [ ] Terms of service live

### Assets
- [ ] App icon (1024x1024)
- [ ] Screenshots (all sizes)
- [ ] App preview video
- [ ] Description written
- [ ] Keywords optimized

### Configuration
- [ ] App Store Connect app created
- [ ] In-app purchases configured
- [ ] Age rating complete
- [ ] App privacy details complete
- [ ] Contact info accurate

### Upload
- [ ] Archive validated
- [ ] Build uploaded
- [ ] Build processing complete
- [ ] Build selected for version

### Submit
- [ ] Export compliance answered
- [ ] Content rights certified
- [ ] Submitted for review

### Launch
- [ ] Approved by Apple
- [ ] Marketing ready
- [ ] Support team ready
- [ ] Analytics configured

---

## Appendix B: Resources

**Official Apple:**
- [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- [App Store Connect Help](https://help.apple.com/app-store-connect/)
- [Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)

**noema Specific:**
- Privacy Policy: https://noema.app/privacy
- Terms of Service: https://noema.app/terms
- Support: [email protected]

---

**Document Control:**
- Version: 1.0
- Last Updated: 2025-11-18
- Next Review: After first submission
- Owner: Product Manager

---

*Good luck with your App Store submission! 🚀*

