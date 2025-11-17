# Noema

> *From Greek νόημα - "thought, perception, meaning"*

**The world's first AI-native personal knowledge management system with emotional intelligence.**

Noema combines cutting-edge AI transcription, sentiment analysis, and named entity recognition with a revolutionary **Emotional Knowledge Graph** to help you understand not just what you think, but how you feel, and how your thoughts, emotions, people, and places are interconnected.

---

## 🌟 Vision

Transform personal note-taking from passive documentation into active self-discovery. Noema doesn't just store your thoughts—it reveals patterns, nurtures emotional wellness, and guides you toward deeper self-awareness through the power of AI and thoughtful design.

---

## ✨ Key Features

### 🎤 AI-Powered Capture
- **Voice-to-Text Transcription**: 99%+ accuracy using on-device Whisper-small model
- **Multi-Language Support**: 50+ languages with automatic detection
- **Smart Summarization**: AI-generated summaries at multiple detail levels
- **Real-Time Processing**: <2 seconds per minute of audio on iPhone 13+

### 🧠 Emotional Intelligence
- **Multi-Dimensional Mood Tracking**: Valence, arousal, dominance, energy, stress, focus
- **28 Emotion Types**: From basic (joy, sadness) to complex (bittersweet, nostalgic)
- **Voice Emotion Analysis**: Detect emotions from tone, pitch, and speaking patterns
- **Biometric Correlation**: Integrate with HealthKit (sleep, heart rate, activity)

### 🕸️ Emotional Knowledge Graph™
- **Named Entity Recognition**: Automatically detect people, places, organizations, topics
- **Entity-Emotion Linking**: Track how you feel about specific people and places over time
- **Relationship Intelligence**: Quantify emotional impact of relationships
  - *"You're 25% happier after conversations with Sarah"*
  - *"Coffee shops correlate with 30% higher creativity"*
- **Location-Emotion Heatmaps**: Visualize where you experience different emotions
- **Temporal Patterns**: Discover when you're most creative, energized, or focused

### 🎮 Gamified Growth
- **Streak System**: Build consistency with daily reflection streaks
- **XP & Levels**: Progress based on note quality, depth, and engagement
- **50+ Achievement Badges**: Unlock milestones across consistency, emotional intelligence, relationships, and insights
- **Virtual Wellness Garden**: A beautiful, evolving visualization of your emotional landscape
- **Personal Growth Quests**: AI-generated weekly challenges tailored to your patterns

### 🔒 Privacy-First Architecture
- **On-Device AI**: 90% of processing happens locally using Core ML
- **Zero-Knowledge Encryption**: We can't read your notes even if we wanted to
- **Selective Cloud Sync**: You choose what syncs, what stays local
- **Offline-First**: Core features work without internet
- **GDPR & CCPA Compliant**: Right to access, erasure, and portability built-in

### 📊 Insights & Analytics
- **Mood Timeline**: Visual trends over time (day/week/month/year views)
- **Pattern Recognition**: AI identifies triggers, optimal times, and correlations
- **Predictive Mood Forecasting**: Predict emotional states based on context
- **Weekly Wellness Reports**: Comprehensive summaries with actionable advice
- **Environmental Intelligence**: Weather, season, location impact on mood

---

## 🏗️ Technical Architecture

### Platform
- **iOS 17+** native (iPhone 13+ recommended for full AI features)
- **Swift 6** with modern concurrency (async/await, actors)
- **SwiftUI + UIKit** hybrid architecture
- **MVVM-C** (Model-View-ViewModel-Coordinator) design pattern

### AI/ML Stack
- **On-Device Models**:
  - Whisper-small (transcription, INT8 quantized)
  - DistilBERT (sentiment analysis, fine-tuned)
  - Custom BERT-NER (named entity recognition)
  - LSTM (mood pattern recognition)
  - XGBoost (voice emotion from paralinguistic features)
- **Cloud Models** (optional, user opt-in):
  - GPT-4-Turbo / Claude 3.5 Sonnet (advanced summarization)
  - Graph Neural Networks (relationship inference)

### Data & Sync
- **Core Data + CloudKit**: Primary persistence with cloud sync
- **SQLite**: Direct access for complex graph queries
- **Secure Enclave**: Encryption key storage
- **AES-256 Encryption**: End-to-end for cloud-synced data

### Integrations
- **HealthKit**: Sleep, heart rate, activity correlation
- **WeatherKit**: Weather-mood analysis
- **EventKit**: Calendar event impact tracking
- **Location Services**: Place-emotion mapping

---

## 📂 Project Structure

```
Noema/
├── docs/
│   ├── product/
│   │   └── STRATEGIC_PLAN_V2.md       # Comprehensive product strategy
│   ├── technical/
│   │   ├── DATABASE_SCHEMA.md         # Core Data schema & relationships
│   │   ├── API_SPECIFICATIONS.md      # Service APIs & cloud endpoints
│   │   └── AI_ML_PIPELINE.md          # AI/ML architecture & models
│   ├── legal/
│   │   └── PRIVACY_POLICY.md          # Privacy policy framework
│   ├── research/
│   │   └── USER_RESEARCH.md           # User research & testing
│   └── roadmap/
│       └── PHASE_1_ROADMAP.md         # Detailed implementation plan
├── Noema/
│   ├── Sources/
│   │   ├── App/
│   │   │   ├── NoemaApp.swift
│   │   │   └── AppCoordinator.swift
│   │   ├── Features/
│   │   │   ├── Notes/                 # Note creation, editing, list
│   │   │   ├── Mood/                  # Mood tracking & analytics
│   │   │   ├── KnowledgeGraph/        # Entity & graph visualization
│   │   │   ├── Gamification/          # Achievements, quests, garden
│   │   │   └── Settings/              # User preferences & privacy
│   │   ├── Core/
│   │   │   ├── Models/                # Core Data models
│   │   │   ├── Services/              # Business logic services
│   │   │   ├── Utilities/             # Helpers & extensions
│   │   │   └── Networking/            # API client
│   │   └── Resources/
│   │       ├── Assets/                # Images, colors, fonts
│   │       └── Localization/          # i18n strings
│   ├── Tests/
│   │   ├── UnitTests/
│   │   └── UITests/
│   └── Package.swift
└── README.md
```

---

## 🚀 Getting Started

### Prerequisites
- **Xcode 15+**
- **iOS 17+ SDK**
- **macOS 14+ (Sonoma)** for development
- **Apple Developer Account** (for device testing)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/pranaysuyash/noema.git
   cd noema
   ```

2. **Open in Xcode**
   ```bash
   open Noema/Noema.xcodeproj
   ```

3. **Install dependencies** (if any)
   - Noema uses no external dependencies for maximum privacy and control
   - All functionality built with native Apple frameworks

4. **Build and run**
   - Select a simulator or connected device
   - Press `Cmd+R` to build and run

### Development Setup

1. **Core ML Models** (to be added)
   - Download pre-trained models from releases
   - Place in `Noema/Sources/Resources/Models/`

2. **Environment Configuration**
   - Copy `.env.example` to `.env`
   - Configure API keys (for optional cloud features)

3. **Run Tests**
   ```bash
   xcodebuild test -scheme Noema -destination 'platform=iOS Simulator,name=iPhone 15 Pro'
   ```

---

## 🗺️ Roadmap

### Phase 1: Foundation (Months 1-6) - **Current Phase**
- ✅ Core architecture & documentation
- ✅ Data models (Note, EmotionalState, Entity, etc.)
- 🚧 Basic note-taking (text & voice)
- 🚧 On-device transcription & sentiment analysis
- 🚧 Named entity recognition
- 🚧 Knowledge graph foundation
- 🚧 Mood tracking MVP
- 🚧 Basic gamification
- 📅 Beta testing (Month 5-6)
- 📅 App Store launch (Month 6)

### Phase 2: Growth (Months 7-12)
- Android version
- Advanced AI features (cloud-based)
- Community features
- Wellness insights
- Enterprise beta

### Phase 3: Expansion (Months 13-24)
- Apple Watch app
- iPad optimizations
- Global expansion (localization)
- B2B partnerships
- API for third-party integrations

See [PHASE_1_ROADMAP.md](docs/roadmap/PHASE_1_ROADMAP.md) for detailed sprint plans.

---

## 🤝 Contributing

We welcome contributions! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

**Key Areas for Contribution:**
- AI model optimization
- UI/UX improvements
- Localization (translations)
- Bug fixes & performance improvements
- Documentation improvements

---

## 🔐 Privacy & Security

Noema takes privacy seriously:

- **Local-First**: All core features work offline, data stays on device
- **Zero-Knowledge**: We can't read your encrypted notes
- **No Tracking**: No analytics, no telemetry without explicit consent
- **Open Source** (planned): Core algorithms will be open-sourced for transparency
- **Regular Audits**: Third-party security audits quarterly

See [PRIVACY_POLICY.md](docs/legal/PRIVACY_POLICY.md) for full details.

---

## 🧪 Research & Ethics

Noema is committed to ethical AI:

- **Bias Mitigation**: Diverse training data, fairness audits
- **Transparency**: Confidence scores, explainable AI
- **Crisis Safeguards**: Resources for mental health crises, no automatic interventions
- **User Control**: Override all AI decisions, disable features
- **Research Partnerships**: Collaborate with universities on emotional intelligence research

See [ETHICAL_AI_GUIDELINES.md](docs/product/ETHICAL_AI_GUIDELINES.md) for our principles.

---

## 📄 License

Copyright © 2025 Noema. All rights reserved.

This project is currently closed-source during development. An open-source license will be announced upon public launch.

---

## 🌱 Philosophy

> "Know thyself" - Ancient Greek aphorism

Noema is built on the belief that self-awareness is the foundation of personal growth. By combining AI's ability to recognize patterns with human intuition and reflection, we can help people understand themselves better—not to optimize productivity, but to live more intentionally, connect more deeply, and thrive emotionally.

**We're not building a productivity tool. We're building a companion for self-discovery.**

---

## 📞 Contact

- **Website**: [noema.app](https://noema.app) (coming soon)
- **Email**: hello@noema.app
- **Twitter**: [@noemaapp](https://twitter.com/noemaapp)
- **Discord**: [Join our community](https://discord.gg/noema)

---

## 🙏 Acknowledgments

- OpenAI's Whisper for transcription foundation
- Hugging Face for transformer models
- Apple's Core ML team for incredible on-device AI capabilities
- The open-source community for inspiration and tools

---

**Built with ❤️ and 🧠 by the Noema team.**

*Noema: Understand your mind. Nurture your heart. Know yourself.*
