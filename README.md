# noema: AI-Native Note Taking with Emotional Intelligence

**Your AI companion that doesn't just capture your thoughts—it understands your emotions, remembers your context, and transforms your notes into personalized wisdom.**

[![iOS](https://img.shields.io/badge/iOS-17.0+-blue.svg)](https://www.apple.com/ios/)
[![Swift](https://img.shields.io/badge/Swift-6.0-orange.svg)](https://swift.org)
[![License](https://img.shields.io/badge/License-Proprietary-red.svg)](LICENSE)

---

## 🌟 Vision

**noema** is the first AI-native personal note-taking app that transforms raw thoughts into actionable insights while nurturing emotional wellness through intelligent mood tracking and gamified self-improvement.

We're building more than a note-taking app—we're creating a **personal wellness companion** that helps users understand themselves better through the power of AI and thoughtful design.

### What Makes noema Different?

🧠 **Emotional Intelligence**: AI analyzes not just *what* you're saying, but *how* you're feeling
🔒 **Privacy-First**: On-device AI processing as default, your thoughts stay private
🎮 **Gamified Growth**: Turn self-reflection into a rewarding journey with achievements and levels
🌈 **Mood Memory**: "Show me notes when I was feeling creative"—temporal emotional search
🏆 **Apple Design Awards**: We're targeting this level of polish from day one

---

## 📱 Key Features

### Core Intelligence
- **Real-time Voice Transcription**: 99%+ accuracy with on-device Whisper model
- **8-Dimension Emotion Detection**: Joy, sadness, anger, fear, surprise, disgust, trust, anticipation
- **Smart Summarization**: Adjustable detail levels (bullet points → deep dive)
- **Named Entity Recognition**: Automatically tag people, places, organizations
- **Action Item Extraction**: Never miss a follow-up

### Mood Intelligence (Unique)
- **Emotional Timeline**: Visualize mood patterns over weeks/months
- **Mood-Note Correlation**: "Your best ideas come when you're feeling peaceful"
- **Temporal Search**: "Show me all notes when I felt confident"
- **Weekly Wellness Reports**: Track emotional growth with actionable insights
- **Crisis Detection**: Empathetic intervention with professional resources

### Gamification (Unique)
- **Streak System**: Daily reflection streaks with visual rewards
- **50 Levels**: Progress from "Beginner" to "Legend"
- **100+ Achievements**: Unlock badges for milestones, streaks, wellness goals
- **Virtual Garden**: Digital garden that flourishes with balanced emotional states
- **Shareable Cards**: Beautiful achievement cards for Instagram/Twitter

### Platform Integration
- **HealthKit**: Correlate mood with sleep, exercise, heart rate variability
- **Calendar**: Pre/post-meeting mood patterns
- **Apple Music**: Mood-based playlist recommendations
- **Weather**: "You tend to feel contemplative on rainy days"

### Privacy & Security
- **On-Device AI**: 95% of processing happens locally (Core ML)
- **End-to-End Encryption**: AES-256 for cloud sync
- **Zero-Knowledge**: We can't read your notes even if we wanted to
- **GDPR/CCPA Compliant**: Full data export and deletion

---

## 🏗️ Project Structure

```
noema/
├── docs/                           # Comprehensive documentation
│   ├── product/
│   │   ├── STRATEGIC_PLAN_V1.md   # Full product strategy & market analysis
│   │   └── ETHICAL_AI_GUIDELINES.md # AI ethics & crisis protocols
│   ├── technical/
│   │   ├── ARCHITECTURE.md         # System architecture & patterns
│   │   └── DATABASE_SCHEMA.md      # Data models & Core Data schema
│   ├── roadmap/
│   │   └── PHASE1_IMPLEMENTATION.md # 6-month development roadmap
│   └── legal/
│       └── PRIVACY_POLICY.md       # [Coming soon]
│
├── noema-ios/                      # iOS app codebase
│   ├── Package.swift               # Swift Package Manager dependencies
│   ├── Sources/
│   │   ├── Domain/                 # Business logic (framework-independent)
│   │   │   ├── Entities/          # Core business objects (Note, MoodSnapshot, etc.)
│   │   │   ├── ValueObjects/      # Immutable values (EmotionalDimensions)
│   │   │   ├── RepositoryProtocols/ # Data access interfaces
│   │   │   ├── DomainServices/    # Business rules & algorithms
│   │   │   └── Enums/             # Domain enumerations
│   │   │
│   │   ├── Data/                  # Repositories & persistence
│   │   │   ├── Repositories/      # Repository implementations
│   │   │   ├── CoreData/          # Core Data stack & migrations
│   │   │   ├── CloudKit/          # Cloud sync engine
│   │   │   └── Cache/             # Caching strategies
│   │   │
│   │   ├── Presentation/          # UI layer
│   │   │   ├── Views/             # SwiftUI views
│   │   │   ├── ViewModels/        # View state & logic
│   │   │   ├── Coordinators/      # Navigation flow
│   │   │   └── Components/        # Reusable UI components
│   │   │
│   │   ├── Application/           # Use cases & services
│   │   │   ├── UseCases/          # Application-specific business logic
│   │   │   └── Services/          # Cross-cutting concerns (analytics, etc.)
│   │   │
│   │   └── AIProcessing/          # Machine learning pipeline
│   │       ├── OnDevice/          # Core ML models
│   │       ├── Cloud/             # Optional cloud AI (GPT-4)
│   │       ├── Preprocessing/     # Feature extraction
│   │       └── PostProcessing/    # Result refinement
│   │
│   ├── Tests/                     # Comprehensive test suite
│   │   ├── DomainTests/
│   │   ├── DataTests/
│   │   ├── PresentationTests/
│   │   └── ApplicationTests/
│   │
│   └── Resources/
│       ├── Assets.xcassets        # Images, colors, icons
│       └── Localizations/         # Multi-language support
│
└── README.md                      # This file
```

---

## 🛠️ Technical Stack

### iOS Development
- **Language**: Swift 6.0 (modern concurrency with async/await, actors)
- **UI Framework**: SwiftUI (primary) + UIKit (complex interactions)
- **Architecture**: MVVM-C (Model-View-ViewModel-Coordinator) + Clean Architecture
- **Minimum iOS**: iOS 17+ (for latest AI capabilities)
- **Target Devices**: iPhone 13+ (for Neural Engine performance)

### AI/ML Pipeline
- **On-Device Models** (Core ML):
  - Whisper-small (speech-to-text, 100MB quantized)
  - DistilBERT (emotion detection, 50MB)
  - Custom NER model (named entities, 30MB)
  - LSTM mood predictor (pattern forecasting, 20MB)

- **Cloud Models** (Optional, user-controlled):
  - GPT-4-turbo (advanced insights)
  - Custom fine-tuned models (personalized to user's style)

### Data & Persistence
- **Local Storage**: Core Data + SQLite with AES-256 encryption
- **Cloud Sync**: CloudKit with end-to-end encryption
- **Caching**: NSCache for in-memory, disk cache for media

### Dependencies (Swift Package Manager)
```swift
- Alamofire (networking)
- Nuke (image loading/caching)
- KeychainAccess (secure storage)
- swift-markdown (note rendering)
- Amplitude-Swift (analytics)
- Quick/Nimble (testing)
```

---

## 🚀 Getting Started

### Prerequisites
- **Xcode 15.2+** (with Swift 6 support)
- **macOS 14+** (Sonoma or later)
- **iOS 17+ device or simulator** (for testing)
- **Apple Developer Account** (for TestFlight/App Store)

### Installation

1. **Clone the repository**
```bash
git clone https://github.com/your-org/noema.git
cd noema
```

2. **Navigate to iOS project**
```bash
cd noema-ios
```

3. **Resolve dependencies**
```bash
swift package resolve
```

4. **Open in Xcode**
```bash
open Package.swift
# or
xed .
```

5. **Build and run**
- Select your target device/simulator
- Press ⌘R to build and run
- For tests: ⌘U

### Project Setup Checklist

- [ ] Configure signing & capabilities in Xcode
- [ ] Set up CloudKit container (if testing sync)
- [ ] Add HealthKit capabilities (for integrations)
- [ ] Configure app groups (for extensions)
- [ ] Set up API keys (for cloud AI, analytics)

---

## 🧪 Testing

### Run Tests
```bash
# All tests
swift test

# Specific test suite
swift test --filter DomainTests

# With coverage
swift test --enable-code-coverage
```

### Test Coverage Goals
- Domain Layer: >90%
- Data Layer: >85%
- Application Layer: >80%
- Presentation Layer: >70%

---

## 📚 Documentation

### Essential Reading

1. **[Strategic Plan](docs/product/STRATEGIC_PLAN_V1.md)** - Full product vision, market analysis, monetization
2. **[Technical Architecture](docs/technical/ARCHITECTURE.md)** - System design, patterns, tech stack
3. **[Database Schema](docs/technical/DATABASE_SCHEMA.md)** - Data models, relationships, queries
4. **[Ethical AI Guidelines](docs/product/ETHICAL_AI_GUIDELINES.md)** - Crisis protocols, bias prevention
5. **[Phase 1 Roadmap](docs/roadmap/PHASE1_IMPLEMENTATION.md)** - 6-month implementation plan

### Code Documentation

All public APIs are documented with:
- **Swift DocC** format for inline documentation
- **MARK** comments for code organization
- **Sample data** in `#if DEBUG` blocks for SwiftUI previews

---

## 🎯 Development Roadmap

### Phase 1: Foundation (Months 1-6) - **Current**
✅ Project setup & architecture
✅ Core documentation complete
🚧 Domain models implementation (in progress)
⏳ Basic note CRUD & UI
⏳ AI pipeline (transcription, emotion detection)
⏳ Mood intelligence MVP
⏳ Gamification engine
⏳ Platform integrations (HealthKit, Calendar, Music)
⏳ Beta testing (100 users)
⏳ **App Store Launch** 🚀

### Phase 2: Growth (Months 7-12)
- Android version
- Apple Watch app
- Advanced AI features (GPT-4 insights)
- Wellness Communities (opt-in social)
- Enterprise pilot (B2B wellness)
- API beta (for partners)

### Phase 3: Scale (Year 2+)
- International expansion (5+ languages)
- Apple Vision Pro exploration
- B2B enterprise product
- Developer API ecosystem
- Annual noema conference

---

## 🤝 Contributing

**Internal Team Only** (for now)

### Development Workflow
1. Create feature branch: `git checkout -b feature/your-feature`
2. Follow [Swift Style Guide](https://github.com/raywenderlich/swift-style-guide)
3. Run SwiftLint: `swiftlint`
4. Write tests (minimum 80% coverage for new code)
5. Create PR with detailed description
6. Get code review from 2+ engineers
7. Merge after CI passes

### Code Review Checklist
- [ ] Follows SOLID principles
- [ ] Proper error handling
- [ ] Unit tests included
- [ ] SwiftUI previews work
- [ ] No force unwraps (except in tests/previews)
- [ ] Accessibility labels for UI elements
- [ ] Privacy-first (no sensitive data logging)

---

## 📊 Success Metrics

### Product Goals (Launch + 30 Days)
- **Downloads**: 5,000+ (organic + TestFlight buzz)
- **DAU/MAU**: >40%
- **Day 7 Retention**: >50%
- **Day 30 Retention**: >30%
- **App Store Rating**: >4.7 stars
- **NPS**: >50

### Technical Goals
- **Crash-Free Sessions**: >99.9%
- **App Launch Time**: <1.0s (cold start)
- **AI Inference Time**: <500ms (mood detection)
- **Battery Usage**: <5% per hour active use
- **Test Coverage**: >85% overall

### Business Goals (Year 1)
- **Users**: 50,000 total
- **Paid Conversion**: >5%
- **ARR**: $2.4M
- **LTV:CAC**: >8:1
- **App Store Featuring**: "New Apps We Love"

---

## 🔐 Privacy & Security

**Privacy is not a feature—it's a fundamental right.**

### Our Commitments
- ✅ On-device AI processing as default (not opt-in)
- ✅ End-to-end encryption for cloud sync
- ✅ Zero-knowledge architecture (we can't read your notes)
- ✅ Granular privacy controls (per-feature permissions)
- ✅ Full data export (JSON, Markdown, PDF)
- ✅ Instant data deletion (no 30-day retention)
- ✅ No selling of user data (NEVER)

### Security Practices
- AES-256 encryption at rest (Data Protection API)
- TLS 1.3 for all network communication
- Certificate pinning for API calls
- Biometric authentication (Face ID/Touch ID)
- Regular security audits (quarterly)
- Bug bounty program ($10K for critical vulnerabilities)

---

## 📄 License

**Proprietary - All Rights Reserved**

Copyright © 2025 noema Inc. This software and associated documentation are proprietary and confidential. Unauthorized copying, distribution, or use is strictly prohibited.

For licensing inquiries: [email protected]

---

## 👥 Team

### Core Team (Phase 1)
- **Product Manager** (1): Vision, roadmap, stakeholder management
- **iOS Engineers** (6): Native development, AI integration, testing
- **AI/ML Engineers** (2): Model training, optimization, bias testing
- **Designers** (2): UI/UX, motion design, design systems
- **QA Engineer** (1): Testing, automation, quality assurance

### Advisors
- **Clinical Psychologist**: Ethical AI, crisis protocols
- **Privacy Consultant**: GDPR/CCPA compliance, security audits
- **Growth Marketer**: ASO, launch strategy, acquisition

---

## 📞 Contact

- **Website**: [noema.app](https://noema.app) (coming soon)
- **Email**: [email protected]
- **Twitter**: [@noemaapp](https://twitter.com/noemaapp)
- **Discord**: [discord.gg/noema](https://discord.gg/noema)

### Support
- **Bug Reports**: [email protected]
- **Feature Requests**: [email protected]
- **Privacy Questions**: [email protected]
- **Press Inquiries**: [email protected]

---

## 🙏 Acknowledgments

Built with:
- ❤️ **Passion** for emotional intelligence and mental wellness
- 🧠 **Respect** for user privacy and data ownership
- 🎨 **Commitment** to world-class design and user experience
- 🚀 **Ambition** to build the future of personal knowledge management

### Inspiration
- **Plutchik's Wheel of Emotions** - 8-dimension emotion model
- **Zettelkasten Method** - Connected note-taking philosophy
- **Apple Design Awards** - Target for design excellence
- **Headspace/Calm** - Wellness-first product design

---

## 🗺️ Roadmap Visualization

```
2025
────────────────────────────────────────────────────
Q1          Q2          Q3          Q4
────────────────────────────────────────────────────
Jan-Feb     Mar-Apr     May-Jun     Jul-Aug     Sep-Oct     Nov-Dec

📐 Setup   🧠 AI      😊 Mood    🎮 Gamif   🧪 Beta   🚀 LAUNCH
& Arch     Pipeline   Intel      & Polish   Testing   + Growth
────────────────────────────────────────────────────
         iOS App v1.0 Launch
                                                    Android
                                                    Beta
```

---

**Let's build the future of emotionally intelligent note-taking.** 🚀✨

*Last updated: 2025-11-17*
*Version: 1.0*
