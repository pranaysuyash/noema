# noema: Phase 1 Implementation Roadmap (Months 1-6)

## Version 1.0 | Last Updated: 2025-11-17

## Overview

**Goal:** Ship feature-complete v1.0 to App Store with Apple Design Awards-level polish

**Timeline:** 6 months (24 weeks)
**Team:** 14 people (6 engineers, 3 product/design, 2 AI/ML, 3 advisors)
**Budget:** $3.27M Year 1

---

## Month 1: Foundation & Core Architecture

### Week 1-2: Project Setup & Architecture
**Deliverables:**
- [ ] Xcode project created with proper structure
- [ ] Swift Package Manager dependencies configured
- [ ] CI/CD pipeline (GitHub Actions) set up
- [ ] MVVM-C architecture implemented
- [ ] Clean Architecture layer separation
- [ ] Core Data stack with encryption
- [ ] Basic unit test framework

**Key Files:**
```
noema/
├── noema.xcodeproj
├── Package.swift
├── Sources/
│   ├── Domain/          # Business logic
│   ├── Data/            # Repositories, Core Data
│   ├── Presentation/    # SwiftUI views
│   ├── Application/     # Use cases, coordinators
│   └── AIProcessing/    # ML models
├── Tests/
│   ├── DomainTests/
│   ├── DataTests/
│   └── PresentationTests/
└── Resources/
    ├── Assets.xcassets
    └── Localizations/
```

**Engineering Tasks:**
- iOS Engineer 1: Project setup, CI/CD, architecture
- iOS Engineer 2: Core Data schema implementation
- Designer: Design system foundation (colors, typography, components)

**Success Criteria:**
- ✅ Project builds successfully
- ✅ All tests pass (even if few tests exist)
- ✅ CI/CD runs on every PR
- ✅ Code coverage >80%

---

### Week 3-4: Basic Note CRUD & Local Storage
**Deliverables:**
- [ ] Note domain model implemented
- [ ] Core Data Note entity with relationships
- [ ] Note repository (protocol + implementation)
- [ ] Create/Read/Update/Delete operations
- [ ] Local file storage for audio files
- [ ] Basic SwiftUI note list view
- [ ] Basic SwiftUI note editor view

**Key Components:**
```swift
// Domain
struct Note { ... }
protocol NoteRepositoryProtocol { ... }

// Data
class CoreDataNoteRepository: NoteRepositoryProtocol { ... }
class NoteEntity: NSManagedObject { ... }

// Presentation
struct NoteListView: View { ... }
struct NoteEditorView: View { ... }
class NoteEditorViewModel: ObservableObject { ... }
```

**Engineering Tasks:**
- iOS Engineer 1: Domain models, repository protocol
- iOS Engineer 2: Core Data implementation, file storage
- iOS Engineer 3: SwiftUI views, ViewModels
- Designer: Note list and editor UI mockups

**Success Criteria:**
- ✅ Can create text notes and save locally
- ✅ Can view list of notes sorted by date
- ✅ Can edit and delete notes
- ✅ Data persists across app restarts
- ✅ UI matches design system

---

## Month 2: AI Pipeline - On-Device

### Week 5-6: Audio Recording & Transcription
**Deliverables:**
- [ ] AVFoundation audio recording pipeline
- [ ] Audio waveform visualization
- [ ] Noise cancellation preprocessing
- [ ] Whisper Core ML model integration
- [ ] Real-time transcription display
- [ ] Transcription entity in Core Data
- [ ] Audio file management

**Key Components:**
```swift
actor AudioRecorder { ... }
actor TranscriptionEngine { ... }
class WhisperModel: MLModelProtocol { ... }
struct VoiceRecordingView: View { ... }
```

**Engineering Tasks:**
- ML Engineer 1: Whisper model conversion to Core ML
- iOS Engineer 1: Audio recording pipeline
- iOS Engineer 2: Transcription UI, real-time display
- Designer: Voice recording UI with waveform

**Success Criteria:**
- ✅ Can record audio with high quality
- ✅ Audio transcribed with >95% accuracy (clean audio)
- ✅ Transcription appears in real-time (<2s per minute)
- ✅ Audio files stored efficiently (<1MB per minute)
- ✅ UI shows recording status, waveform, progress

---

### Week 7-8: Emotion Detection & NER
**Deliverables:**
- [ ] DistilBERT emotion model (Core ML)
- [ ] 8-dimension emotion detection
- [ ] Named entity recognition model
- [ ] Mood snapshot entity in Core Data
- [ ] Mood analysis service
- [ ] Mood visualization UI

**Key Components:**
```swift
actor EmotionDetectionModel: MLModelProtocol { ... }
actor NERModel: MLModelProtocol { ... }
actor MoodAnalysisEngine { ... }
struct MoodPicker: View { ... }
struct EmotionChart: View { ... }
```

**Engineering Tasks:**
- ML Engineer 1: Emotion model training & conversion
- ML Engineer 2: NER model training & conversion
- iOS Engineer 1: Mood analysis service integration
- iOS Engineer 2: Mood UI components (picker, chart)
- Designer: Mood visualization design

**Success Criteria:**
- ✅ Emotion detected from text with >85% accuracy
- ✅ NER extracts people, places, organizations
- ✅ Mood analysis completes in <500ms
- ✅ Mood UI is intuitive and beautiful
- ✅ Mood data persists with notes

---

## Month 3: Mood Intelligence MVP

### Week 9-10: Mood Timeline & Correlation Engine
**Deliverables:**
- [ ] Mood timeline view (Swift Charts)
- [ ] Mood-note correlation algorithm
- [ ] Weekly mood insights generation
- [ ] Mood-based search functionality
- [ ] Mood dashboard with analytics

**Key Components:**
```swift
class MoodCorrelationService: DomainService { ... }
class WellnessCalculator: DomainService { ... }
struct MoodTimelineView: View { ... }
struct MoodDashboardView: View { ... }
```

**Engineering Tasks:**
- iOS Engineer 1: Correlation algorithm implementation
- iOS Engineer 2: Swift Charts integration, timeline view
- iOS Engineer 3: Dashboard UI, insights display
- Designer: Dashboard layout, data visualization

**Success Criteria:**
- ✅ Mood timeline shows 30 days of data
- ✅ Correlation identifies patterns (e.g., "You're creative when joyful")
- ✅ Weekly insights are actionable and empathetic
- ✅ Mood search works ("show notes when I was anxious")
- ✅ Dashboard loads in <200ms

---

### Week 11-12: Crisis Detection & Intervention
**Deliverables:**
- [ ] Crisis detection algorithm
- [ ] Crisis keyword database
- [ ] Crisis intervention modal UI
- [ ] Crisis resource directory
- [ ] Analytics for intervention effectiveness

**Key Components:**
```swift
class CrisisDetector: DomainService { ... }
struct CrisisInterventionView: View { ... }
class CrisisResourceProvider { ... }
```

**Engineering Tasks:**
- ML Engineer 1: Crisis detection model refinement
- iOS Engineer 1: Crisis detection service
- iOS Engineer 2: Intervention UI (modal, resources)
- Clinical Advisor: Review crisis protocols
- Designer: Empathetic crisis intervention UI

**Success Criteria:**
- ✅ Crisis detected with >95% sensitivity
- ✅ False positive rate <5%
- ✅ Resources displayed in <10 seconds
- ✅ User can contact crisis line with one tap
- ✅ Clinical advisor approval on all messaging

---

## Month 4: Gamification & Polish

### Week 13-14: Achievement System
**Deliverables:**
- [ ] Achievement entity in Core Data
- [ ] Achievement rule engine
- [ ] 50+ achievements designed
- [ ] Achievement unlock animations
- [ ] Achievement cards (shareable)
- [ ] Level progression system

**Key Components:**
```swift
actor GamificationEngine { ... }
struct AchievementCardView: View { ... }
struct LevelProgressView: View { ... }
```

**Engineering Tasks:**
- iOS Engineer 1: Achievement rule engine
- iOS Engineer 2: Achievement UI, animations
- iOS Engineer 3: Social sharing integration
- Designer: Achievement badge designs, cards
- Product Manager: Achievement balancing, progression curve

**Success Criteria:**
- ✅ 100+ achievements implemented
- ✅ Unlock animations are delightful
- ✅ Achievement cards are Instagram-worthy
- ✅ Level progression feels balanced
- ✅ Achievements drive engagement (A/B test)

---

### Week 15-16: Streak Tracking & Virtual Garden
**Deliverables:**
- [ ] Daily streak calculation
- [ ] Streak protection feature
- [ ] Virtual garden visualization
- [ ] Garden growth tied to emotional balance
- [ ] Push notifications for streaks

**Key Components:**
```swift
struct VirtualGardenView: View { ... }
class StreakManager { ... }
class NotificationService { ... }
```

**Engineering Tasks:**
- iOS Engineer 1: Streak logic, notifications
- iOS Engineer 2: Virtual garden rendering (SpriteKit or SwiftUI)
- Designer: Garden visual design, plant illustrations

**Success Criteria:**
- ✅ Streak calculated correctly (time zone aware)
- ✅ Streak protection works (1 free skip per week)
- ✅ Garden is visually appealing
- ✅ Garden growth motivates users
- ✅ Notifications sent at optimal times

---

## Month 5: Integration & Testing

### Week 17-18: Platform Integrations (HealthKit, Calendar, Music)
**Deliverables:**
- [ ] HealthKit integration (sleep, exercise, HRV)
- [ ] Calendar integration (event mood correlation)
- [ ] Apple Music integration (mood-based playlists)
- [ ] Privacy controls for each integration
- [ ] Correlation dashboard

**Key Components:**
```swift
class HealthKitManager { ... }
class CalendarManager { ... }
class MusicRecommendationEngine { ... }
```

**Engineering Tasks:**
- iOS Engineer 1: HealthKit integration
- iOS Engineer 2: Calendar integration
- iOS Engineer 3: Music integration
- Privacy Consultant: Review data permissions

**Success Criteria:**
- ✅ HealthKit data correlates with mood
- ✅ Pre/post-meeting mood patterns identified
- ✅ Music recommendations match current mood
- ✅ Privacy controls are granular and clear
- ✅ All integrations are opt-in

---

### Week 19-20: Beta Testing with 100 Users
**Deliverables:**
- [ ] TestFlight beta build
- [ ] Beta tester onboarding flow
- [ ] In-app feedback mechanism
- [ ] Bug tracking system
- [ ] Usage analytics dashboard

**Engineering Tasks:**
- All engineers: Bug fixes
- QA Engineer: Manual testing, regression tests
- Designer: Polish UI based on feedback
- Product Manager: Prioritize feedback, roadmap adjustments

**Success Criteria:**
- ✅ 100 beta testers recruited
- ✅ >80% weekly active usage
- ✅ <10 critical bugs reported
- ✅ NPS score >50
- ✅ App Store rating (beta) >4.5

---

## Month 6: Launch Preparation

### Week 21-22: Cloud Sync (CloudKit)
**Deliverables:**
- [ ] End-to-end encryption implementation
- [ ] CloudKit schema configured
- [ ] Sync engine with conflict resolution
- [ ] Selective sync controls
- [ ] Sync status UI

**Key Components:**
```swift
class CloudKitManager { ... }
class SyncEngine { ... }
class EncryptionService { ... }
```

**Engineering Tasks:**
- Backend Engineer: CloudKit setup, schema
- iOS Engineer 1: Encryption, key management
- iOS Engineer 2: Sync engine, conflict resolution
- iOS Engineer 3: Sync UI, privacy controls

**Success Criteria:**
- ✅ Notes sync across devices in <5s
- ✅ Encryption is end-to-end (we can't read notes)
- ✅ Conflict resolution works correctly
- ✅ User can choose what syncs
- ✅ Sync status is transparent

---

### Week 23: App Store Assets & Submission
**Deliverables:**
- [ ] App Store screenshots (all sizes)
- [ ] App preview video (30 seconds)
- [ ] App Store description (5 languages)
- [ ] Privacy nutrition label
- [ ] App Store featuring pitch
- [ ] Press kit (for journalists)

**Engineering Tasks:**
- Designer: Screenshots, video, graphics
- Product Manager: Description copy, keywords
- Privacy Consultant: Nutrition label review
- Marketing Contractor: ASO optimization

**Success Criteria:**
- ✅ Screenshots follow 3-frame rule
- ✅ Video is compelling (30s)
- ✅ Description is clear and compelling
- ✅ ASO keywords targeted
- ✅ Privacy label is accurate

---

### Week 24: Public Launch
**Deliverables:**
- [ ] App Store submission
- [ ] Launch day marketing (Product Hunt, press, social)
- [ ] Monitoring dashboard (analytics, crashes)
- [ ] Customer support channels
- [ ] Post-launch hotfix plan

**Engineering Tasks:**
- All engineers: On-call for launch issues
- Product Manager: Launch coordination
- Marketing Contractor: Social media, press outreach

**Success Criteria:**
- ✅ App approved by Apple
- ✅ Launch day: 1,000+ downloads
- ✅ Crash rate <0.1%
- ✅ App Store rating >4.7
- ✅ Featured in "New Apps We Love" (target)

---

## Milestones & Checkpoints

### Month 1 Checkpoint
- ✅ Project compiles and runs
- ✅ Basic note CRUD works
- ✅ Architecture is solid

### Month 2 Checkpoint
- ✅ Voice transcription works
- ✅ Mood detection is accurate
- ✅ AI pipeline is performant

### Month 3 Checkpoint
- ✅ Mood dashboard is compelling
- ✅ Crisis detection is validated
- ✅ User testing shows value

### Month 4 Checkpoint
- ✅ Gamification drives engagement
- ✅ Achievements are delightful
- ✅ Viral mechanics are working

### Month 5 Checkpoint
- ✅ Integrations add value
- ✅ Beta feedback is positive
- ✅ Bugs are under control

### Month 6 Checkpoint
- ✅ Cloud sync is reliable
- ✅ App Store submission approved
- ✅ Launch is successful

---

## Risk Mitigation

### Technical Risks
**Risk:** On-device AI is too slow on iPhone 13
**Mitigation:** Graceful degradation to cloud AI, optimize model quantization

**Risk:** CloudKit sync conflicts are common
**Mitigation:** Implement operational transform or CRDTs for conflict-free merges

**Risk:** Battery drain from continuous AI processing
**Mitigation:** Batch processing, low-power mode optimizations

### Product Risks
**Risk:** Gamification feels manipulative
**Mitigation:** User testing, option to disable, focus on intrinsic motivation

**Risk:** Crisis detection false positives annoy users
**Mitigation:** Conservative thresholds, user feedback loop, clinical validation

**Risk:** Low conversion rate (free to paid)
**Mitigation:** Free tier limitations, value-based pricing, testimonials

### Schedule Risks
**Risk:** Features take longer than estimated
**Mitigation:** 20% buffer built into timeline, ruthless prioritization, weekly sprint reviews

**Risk:** App Store rejection
**Mitigation:** Pre-submission review with Apple expert, privacy compliance audit

---

## Team Allocation

### iOS Engineers (6)
- **Engineer 1 (Senior):** Architecture, Core Data, complex features
- **Engineer 2 (Senior):** AI integration, performance optimization
- **Engineer 3 (Mid):** SwiftUI views, animations, polish
- **Engineer 4 (Mid):** HealthKit, Calendar, integrations
- **Engineer 5 (Mid):** CloudKit, sync, backend
- **Engineer 6 (QA):** Testing, automation, quality assurance

### AI/ML Engineers (2)
- **ML Engineer 1:** Model training, optimization, on-device deployment
- **ML Engineer 2:** NLP pipeline, crisis detection, bias testing

### Product/Design (3)
- **Product Manager:** Roadmap, prioritization, stakeholder management
- **Senior Designer:** UI/UX, design system, visual polish
- **Design Researcher:** User testing, interviews, feedback analysis

### Advisors (3)
- **Clinical Psychologist:** Crisis protocols, ethical AI review
- **Privacy Consultant:** GDPR/CCPA compliance, security audits
- **Growth Marketer:** ASO, launch strategy, acquisition

---

## Success Metrics (End of Phase 1)

### Product Metrics
- **Features Shipped:** 100% of v1.0 scope
- **Bug Count:** <20 known issues (all P3 or lower)
- **Test Coverage:** >85% code coverage
- **Performance:** All targets met (see architecture doc)

### User Metrics (First 30 Days)
- **Downloads:** 5,000+ (from TestFlight + launch buzz)
- **DAU/MAU:** >40%
- **Retention (Day 7):** >50%
- **Retention (Day 30):** >30%
- **NPS:** >50

### Business Metrics
- **Free to Paid Conversion:** >3% (first month)
- **App Store Rating:** >4.7 stars
- **Reviews:** >100 reviews (target 4.8+ average)
- **Press Coverage:** 3+ major publications (TechCrunch, Verge, 9to5Mac)

---

## Phase 2 Preview (Months 7-12)

**Focus:** Growth, refinement, platform expansion

**Key Deliverables:**
- Android version (Months 7-9)
- Apple Watch app (Month 8)
- iPad native app (Month 9)
- Advanced AI features (GPT-4 insights, custom models)
- Wellness Communities (opt-in social features)
- Enterprise pilot (B2B version)
- API beta (for partners)

---

## Document Control

**Version:** 1.0
**Last Updated:** 2025-11-17
**Status:** Active Roadmap

**Review Schedule:**
- Weekly: Sprint planning
- Bi-weekly: Milestone reviews
- Monthly: Executive updates

**Contributors:**
- Product Manager
- Engineering Lead
- Design Lead

---

*This roadmap is ambitious but achievable with the right team and focus. Ship with excellence.* 🚀
