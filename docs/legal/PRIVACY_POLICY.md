# Noema Privacy Policy Framework
## Privacy-First Personal Knowledge Management

**Last Updated**: January 2025
**Effective Date**: TBD (Upon Launch)

---

## Our Privacy Commitment

At Noema, **your privacy is not a feature—it's our foundation.** Your thoughts, emotions, and personal reflections are sacred. We've architected Noema from the ground up to ensure that your data remains yours, always.

**Core Principles:**
1. **Local-First**: Your data lives primarily on your device
2. **Zero-Knowledge**: We can't read your encrypted notes, even if we wanted to
3. **User Control**: You decide what syncs, what's shared, and what's processed
4. **Transparency**: No hidden data collection, no tracking, no ads
5. **Minimal Data**: We collect only what's necessary for functionality

---

## 1. Data We Collect & How We Use It

### 1.1 Data Stored Locally (On Your Device)

The following data is stored **only on your device** by default:

**Notes & Content:**
- Text content, voice recordings, transcriptions
- Photos and attachments
- AI-generated summaries
- User-created tags and folders

**Emotional Data:**
- Mood states (valence, arousal, energy, stress, etc.)
- Detected emotions from text and voice
- Biometric correlations (if HealthKit enabled)

**Knowledge Graph:**
- Detected entities (people, places, organizations, topics)
- Entity-emotion associations
- Relationships between entities
- Mention contexts

**Gamification:**
- XP, levels, achievements, quests
- Virtual garden state
- Streak counts

**How We Use It:**
- Provide core app functionality (note-taking, search, organization)
- Run on-device AI processing (transcription, sentiment analysis, NER)
- Generate insights and visualizations
- Track your progress and growth

**No Cloud Transmission**: By default, this data **never leaves your device** unless you explicitly enable cloud sync.

---

### 1.2 Data Synced to Cloud (User Opt-In)

If you enable **Cloud Sync**, the following data is synced to Apple's CloudKit:

**Synced Data:**
- Notes (encrypted with your key)
- Emotional states (encrypted, optional)
- Entities and relationships (encrypted, optional)
- Gamification progress (for cross-device consistency)

**Encryption:**
- **End-to-End Encryption (E2EE)**: All synced data is encrypted on your device using AES-256
- **Zero-Knowledge Architecture**: Encryption keys are stored in your device's Secure Enclave and never transmitted to our servers
- **Apple's Infrastructure**: We use Apple CloudKit, which is GDPR-compliant and highly secure

**You Control:**
- Enable/disable sync globally
- Choose which notes to sync (per-note toggle)
- Keep emotional data local-only (opt-out of emotional data sync)
- Delete all cloud data instantly from Privacy Dashboard

---

### 1.3 Account & Authentication Data

**If you create an account:**
- Apple ID (for Sign in with Apple) - we don't receive your email or name unless you consent
- Device identifier (anonymous, for device management)
- Subscription status (free, pro, family, lifetime)

**How We Use It:**
- Authenticate you across devices
- Manage subscription status
- Provide customer support (only if you contact us)

**What We Don't Collect:**
- No email or phone number required (Sign in with Apple hides this)
- No password (handled by Apple)
- No name or personal details

---

### 1.4 Optional Cloud AI Processing

If you use **cloud-based AI features** (advanced summarization, insights):

**Data Sent:**
- Encrypted note content (temporarily decrypted on server for processing)
- Encrypted knowledge graph data (for relationship inference)

**How We Use It:**
- Process through GPT-4 / Claude 3.5 for advanced summaries
- Generate deeper insights using larger AI models
- Perform graph neural network inference

**Privacy Protections:**
- Explicit opt-in for each feature
- Content encrypted in transit (TLS 1.3)
- Ephemeral processing: Content processed and immediately deleted (not stored)
- No data used for training our models (unless you explicitly consent)

**You Control:**
- Disable cloud AI entirely (use on-device only)
- Review what data is sent before transmission

---

### 1.5 Health & Biometric Data (HealthKit)

If you enable **HealthKit integration**:

**Data Accessed (Read-Only):**
- Sleep duration and quality
- Heart rate, heart rate variability
- Activity (steps, active energy, exercise minutes)
- Mindfulness minutes

**How We Use It:**
- Correlate with mood states to identify patterns
- Generate insights (e.g., "You're happier on days you exercise")

**Privacy Protections:**
- Read-only access (we never write to HealthKit)
- Data **never synced to cloud** (stays local)
- Data **never shared** with third parties
- You can revoke access anytime in iOS Settings

---

### 1.6 Location Data

If you enable **location services**:

**Data Collected:**
- Approximate location (city-level) when creating notes
- Specific location (coordinates) only if you explicitly save a place

**How We Use It:**
- Correlate mood with locations ("You're creative at coffee shops")
- Generate location-emotion heatmaps

**Privacy Protections:**
- Location **never synced to cloud** by default
- You can disable location for specific notes
- Background location tracking: **Never used**

---

### 1.7 Analytics & Diagnostics (Opt-In Only)

We collect **no analytics by default**. If you opt-in:

**Anonymous Usage Data:**
- App crashes (to fix bugs)
- Feature usage (to prioritize development)
- Performance metrics (load times, battery usage)

**What We Don't Collect:**
- Note content
- Emotional states
- Entity data
- Any personally identifiable information (PII)

**How to Control:**
- Opt-in during onboarding (off by default)
- Toggle in Settings → Privacy → Analytics

---

## 2. How We Share Your Data

**Short Answer: We don't.**

**Longer Answer:**
- We **never sell** your data to advertisers, data brokers, or anyone else
- We **never share** your personal notes, emotions, or insights with third parties
- We **never use** your data to train AI models for other users (unless you explicitly consent to contribute anonymized data)

**Exceptions:**
- **Apple CloudKit**: If you enable sync, data is stored on Apple's infrastructure (encrypted)
- **Cloud AI Providers** (OpenAI, Anthropic): If you use cloud AI features, encrypted content is sent for processing (ephemeral, immediately deleted)
- **Legal Obligations**: We may disclose data if required by law (subpoena, court order) - but since we use zero-knowledge encryption, we physically cannot decrypt your notes

---

## 3. Your Rights (GDPR, CCPA, and Beyond)

You have complete control over your data:

### 3.1 Right to Access
- **Export all data** in machine-readable formats (JSON, CSV)
- Available in Settings → Privacy → Export Data

### 3.2 Right to Erasure ("Right to Be Forgotten")
- **Delete your account** and all associated data
- Available in Settings → Privacy → Delete Account
- Cloud data deleted within 30 days
- Local data deleted immediately

### 3.3 Right to Portability
- Export your data to use in other apps
- Open formats: JSON (structured), Markdown (notes), CSV (analytics)

### 3.4 Right to Rectification
- Edit or correct any data (notes, emotions, entities)
- Retrain AI on corrections (improving accuracy for you)

### 3.5 Right to Restrict Processing
- Disable cloud AI features
- Disable on-device AI features (use as plain note app)
- Disable analytics and diagnostics

### 3.6 Right to Object
- Object to any data processing (we'll comply)
- Opt-out of any feature that makes you uncomfortable

---

## 4. Data Retention

**Active Data:**
- Notes, emotions, entities: Retained indefinitely (you control deletion)
- AI insights: Regenerated on-demand (not permanently stored)

**Deleted Data:**
- **Soft delete**: 30-day grace period (can recover)
- **Hard delete**: After 30 days, permanently deleted (unrecoverable)
- **Immediate purge**: On account deletion

**Backups:**
- CloudKit backups retained by Apple for 30 days (encrypted)
- After deletion, data is removed from backups within 30 days

---

## 5. Security Measures

We employ industry-leading security practices:

### 5.1 Encryption
- **At Rest**: AES-256 encryption for local data (FileVault on macOS, Data Protection on iOS)
- **In Transit**: TLS 1.3 for all network communications
- **End-to-End**: User-controlled encryption keys, stored in Secure Enclave

### 5.2 Access Controls
- **Zero-Knowledge**: We can't access your encrypted data
- **Minimal Permissions**: App requests only necessary permissions
- **No Third-Party SDKs**: No analytics, advertising, or tracking SDKs

### 5.3 Security Audits
- **Quarterly third-party penetration testing**
- **Annual security audits** by independent firms
- **Bug bounty program**: Up to $10,000 for critical vulnerabilities

### 5.4 Incident Response
- **Notification within 24 hours** in case of data breach (though zero-knowledge architecture minimizes risk)
- **Transparent post-mortems** published publicly

---

## 6. Children's Privacy (COPPA Compliance)

Noema is **not intended for children under 13** (or under 16 in the EU).

- We do not knowingly collect data from children
- If we discover a child's data, we will delete it immediately
- Parents: Contact us at privacy@noema.app if you believe your child has used Noema

---

## 7. International Data Transfers

**CloudKit Infrastructure:**
- Data stored in Apple's data centers (US, EU, or user's region)
- Apple complies with GDPR and international data protection laws

**Cloud AI Processing:**
- If you use cloud AI, data may be processed in US data centers (OpenAI, Anthropic)
- Encrypted in transit, ephemeral processing, immediately deleted

**Your Control:**
- Disable cloud features to keep all data local

---

## 8. Changes to This Privacy Policy

We may update this policy as Noema evolves:

- **Notification**: We'll notify you via in-app alert and email (if provided)
- **Opt-In for Material Changes**: If we significantly change data practices, we'll require opt-in
- **Version History**: All versions archived and accessible

---

## 9. Contact Us

Questions about privacy? We're here to help:

- **Email**: privacy@noema.app
- **Privacy Dashboard**: In-app, Settings → Privacy
- **Data Protection Officer**: dpo@noema.app (EU users)

**Response Time**: Within 48 hours for privacy inquiries

---

## 10. Legal Framework

**Compliance:**
- **GDPR** (General Data Protection Regulation) - EU
- **CCPA** (California Consumer Privacy Act) - California, US
- **PIPEDA** (Personal Information Protection and Electronic Documents Act) - Canada
- **Apple App Store Guidelines** - Section 5.1 (Privacy)

**Jurisdiction:**
- Noema Inc. is incorporated in [State, Country]
- Governed by the laws of [Jurisdiction]

---

## Summary: Your Privacy in Practice

✅ **What We Do:**
- Process data locally on your device
- Encrypt synced data end-to-end
- Give you complete control and transparency
- Delete data when you ask
- Prioritize privacy over profit

❌ **What We Don't Do:**
- Sell your data to advertisers
- Track you across the web or other apps
- Use your notes to train AI for others
- Store unencrypted data on our servers
- Require personal information to use the app

---

**Your data. Your control. Your privacy.**

*Noema is built on trust. If you have any concerns, please reach out—we're listening.*

---

**Last Updated**: January 2025
**Version**: 1.0 (Pre-Launch Draft)
