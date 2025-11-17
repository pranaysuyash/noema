# noema: Ethical AI Guidelines & Crisis Intervention Protocols

## Version 1.0 | Last Updated: 2025-11-17

## Table of Contents
1. [Ethical Principles](#ethical-principles)
2. [Crisis Detection & Intervention](#crisis-detection--intervention)
3. [Bias Prevention & Fairness](#bias-prevention--fairness)
4. [Privacy & Data Ethics](#privacy--data-ethics)
5. [Transparency & Explainability](#transparency--explainability)
6. [Clinical Validation](#clinical-validation)
7. [Governance & Accountability](#governance--accountability)

---

## 1. Ethical Principles

### 1.1 Core Commitment

**noema is a wellness tool, not a medical device.**

We acknowledge that:
- AI cannot replace human therapists or medical professionals
- Emotional data is deeply personal and requires extraordinary protection
- Mental health is culturally contextual and cannot be "one-size-fits-all"
- Users must maintain agency over their emotional data and interpretation

### 1.2 Guiding Principles

**Primum Non Nocere (First, Do No Harm)**
- AI features must never worsen a user's mental health
- When in doubt, we err on the side of caution
- User safety takes precedence over engagement metrics

**User Autonomy**
- Users control what data is processed and where
- AI suggestions are always optional, never prescriptive
- Users can disable any AI feature without losing core functionality

**Informed Consent**
- Users understand what AI models do before activation
- Plain-language explanations, not legal jargon
- Opt-in for any data that leaves the device

**Beneficence**
- AI should actively contribute to user wellbeing
- Features must pass "wellness audit" before launch
- Regular user surveys on mental health impact

**Justice & Fairness**
- AI must work equitably across demographics
- Affordable pricing ensures access regardless of income
- Localization goes beyond translation to cultural adaptation

---

## 2. Crisis Detection & Intervention

### 2.1 Crisis Definition

A **mental health crisis** in noema context includes:
- Explicit suicidal ideation or planning
- Self-harm intentions or descriptions
- Severe depressive episodes with hopelessness
- Acute psychotic symptoms
- Substance abuse crisis indicators

### 2.2 Detection Methodology

**Multi-Signal Approach:**
```
Crisis Score = weighted_average(
  text_keywords: 0.30,      // "suicide", "end it all", "no point"
  sentiment_severity: 0.25, // Extreme negative valence
  behavioral_changes: 0.20, // Sudden pattern shifts
  voice_analysis: 0.15,     // Monotone, slow speech
  context_window: 0.10      // Time of day, recent history
)

Threshold for intervention: Crisis Score > 0.75
```

**Keyword Lists (Continuously Updated):**
- **High-risk**: "suicide", "kill myself", "not worth living", "end it all"
- **Medium-risk**: "can't go on", "no hope", "everyone better off", "self-harm"
- **Context-dependent**: "tired of everything", "give up", "done trying"

**Behavioral Signals:**
- 3+ days of exclusively negative mood logs
- Sudden cessation of note-taking after consistent use
- Notes created at unusual hours (3-5 AM) with negative sentiment
- Dramatic mood swings (joy to despair within hours)

### 2.3 Intervention Protocol

**Level 1: High Crisis (Score > 0.85)**
```
Immediate Actions:
1. Display full-screen crisis resource modal (cannot be dismissed for 10 seconds)
2. Show local crisis hotlines (geo-located)
3. Offer to call emergency services (988 in US, 112 in EU)
4. Disable note-saving until user confirms safety
5. Log intervention (encrypted, for product improvement only)

Resources Shown:
- 988 Suicide & Crisis Lifeline (US): Call/Text
- Crisis Text Line: Text HOME to 741741
- International Association for Suicide Prevention: www.iasp.info
- Local emergency: "If in immediate danger, call 911"
```

**Level 2: Elevated Concern (Score 0.75-0.84)**
```
Gentle Intervention:
1. Display empathetic message: "It sounds like you're going through a difficult time"
2. Suggest professional resources (therapist directories, BetterHelp, Talkspace)
3. Offer guided breathing exercise
4. Recommend contacting trusted friend/family
5. Save note with "check-in" reminder in 24 hours
```

**Level 3: Monitoring (Score 0.60-0.74)**
```
Passive Support:
1. Subtle encouragement: "You've been reflective today. Take care of yourself."
2. Suggest positive past notes: "Revisit a moment when you felt strong?"
3. Increase wellness insights frequency
4. No explicit crisis messaging (avoid false positives/alarm fatigue)
```

### 2.4 False Positive Mitigation

**Risk**: Users discussing crisis academically, writing fiction, or quoting others.

**Mitigations:**
1. **Context Analysis**: "I'm writing a story about suicide" ≠ suicidal ideation
2. **User Feedback**: "Was this detection helpful?" → Train model
3. **Temporal Patterns**: One-time mention < repeated patterns
4. **Tone Analysis**: Clinical tone vs. personal distress
5. **User History**: Academic users flagged differently

**Target Metrics:**
- **False Positive Rate**: <5% (1 in 20 interventions is unnecessary)
- **False Negative Rate**: <1% (miss 1 in 100 true crises) - CRITICAL
- **User Annoyance Score**: <2/10 on feedback surveys

### 2.5 Legal & Ethical Boundaries

**What noema DOES:**
- Detect potential crises and provide resources
- Encourage professional help
- Document interventions for product improvement

**What noema DOES NOT DO:**
- Diagnose mental health conditions
- Provide therapy or medical advice
- Contact emergency services without user consent
- Share crisis data with third parties (including family)

**Liability Protection:**
- Clear disclaimers in onboarding and crisis modals
- "Good Samaritan" framing: We help connect users to resources
- Legal review of all crisis messaging
- $5M professional liability insurance

### 2.6 Post-Intervention Follow-Up

**24-Hour Check-In:**
```
Gentle notification: "Thinking of you. How are you feeling today?"
Options:
- "I'm doing better" → Positive reinforcement
- "Still struggling" → Suggest professional help again
- "Don't want to answer" → Respect privacy, try again in 48 hours
```

**Weekly Wellness Check (for users with past interventions):**
- "Would you like to review your emotional journey this week?"
- Highlight positive trends if present
- Never punish or shame negative patterns

### 2.7 Partner Resources

**Integrated Directories:**
- **Psychology Today**: Therapist finder API integration
- **BetterHelp/Talkspace**: Affiliate partnerships (ethical disclosure)
- **NAMI**: National Alliance on Mental Illness resources
- **The Trevor Project**: LGBTQ+ youth crisis support

**Regional Customization:**
```
US: 988 Lifeline
UK: Samaritans (116 123)
AU: Lifeline Australia (13 11 14)
EU: 112 + local resources
Asia-Pacific: Localized crisis centers
```

---

## 3. Bias Prevention & Fairness

### 3.1 Known Bias Risks in Emotion AI

**Gender Bias:**
- Risk: Models trained on data where women express emotion more openly → underdetect male distress
- Mitigation: Gender-balanced training data, separate validation sets

**Cultural Bias:**
- Risk: Western emotional expression norms don't transfer to Asian, African, Middle Eastern cultures
- Mitigation: Cultural consultants, region-specific model fine-tuning

**Age Bias:**
- Risk: Youth slang ("I'm dead" = funny) vs. literal interpretation
- Mitigation: Age-cohort training data, generational language models

**Neurodiversity Bias:**
- Risk: Autism spectrum users may have different emotional expression patterns
- Mitigation: Opt-in "neurodivergent mode" with adjusted models

### 3.2 Bias Testing Framework

**Pre-Launch Testing:**
```
1. Demographic Parity:
   - Equal crisis detection rates across genders (±5%)
   - Equal mood detection accuracy across age groups (±10%)
   - Equal NPS scores across ethnicities (±5 points)

2. Calibration Testing:
   - 1,000 labeled notes from each demographic
   - Human expert labels vs. AI predictions
   - Report discrepancies >10%

3. Adversarial Testing:
   - Intentionally biased inputs
   - Edge cases (e.g., gender-neutral pronouns, code-switching)
```

**Ongoing Monitoring:**
```
Monthly Reports:
- Mood detection accuracy by demographic (gender, age, location)
- Crisis intervention rates by group
- User satisfaction scores (NPS) by segment
- Feature usage patterns across demographics

Alert Thresholds:
- >10% accuracy gap → Immediate model review
- >20% intervention rate variance → Clinical review
- <4.0 NPS for any group → UX deep dive
```

### 3.3 Inclusive Training Data

**Data Collection Strategy:**
```
Target Training Data Composition:
- Gender: 45% female, 45% male, 10% non-binary/other
- Age: 20% Gen Z, 40% Millennial, 30% Gen X, 10% Boomer+
- Geography: 40% US, 30% Europe, 20% Asia-Pacific, 10% Other
- Ethnicity: Reflects global internet population, not just US
- Neurodiversity: 15% self-identified neurodivergent users
```

**Synthetic Data Augmentation:**
- Use GPT-4 to generate demographically diverse training examples
- Validate synthetic data with cultural consultants
- Label generation process for transparency

### 3.4 Cultural Adaptation

**Localization Beyond Translation:**

**Japanese Market:**
- Emotion: Subtle expression, value harmony over individual feelings
- Adaptation: Softer mood prompts, group-oriented insights
- Example: "Your reflections contribute to collective wisdom" vs. "Level up!"

**Latin American Market:**
- Emotion: Expressive, family-oriented, spiritual themes common
- Adaptation: Family wellness features, gratitude prompts
- Example: Include "gratitude" as default mood dimension

**Middle Eastern Market:**
- Emotion: Honor/shame dynamics, religious considerations
- Adaptation: Privacy-ultra-first, spiritual reflection prompts
- Example: Integrate Islamic calendar for Ramadan reflection patterns

**Northern European Market:**
- Emotion: Reserved, value rationality and self-sufficiency
- Adaptation: Data-driven insights, less gamification
- Example: "Analytics" framing vs. "Emotional journey"

---

## 4. Privacy & Data Ethics

### 4.1 Data Minimization Principle

**We Collect Only What's Needed:**
```
Absolutely Required:
- Note content (stored locally)
- Mood dimensions (local, optionally synced)
- Usage analytics (anonymized)

Optional (User Consent Required):
- Cloud sync (encrypted notes)
- Cloud AI processing (for advanced features)
- Crash reports (anonymized)

Never Collected:
- Biometric data beyond mood (no facial recognition)
- Location beyond city-level for weather (no GPS tracking)
- Contacts, messages, or other apps' data
```

### 4.2 Data Storage & Encryption

**Local Storage (Default):**
```
- Encryption: AES-256 with device-specific key (Keychain)
- Access: Requires device unlock (Face ID/Touch ID)
- Deletion: User can wipe all data instantly
- Backup: Local encrypted backups only (iCloud Keychain)
```

**Cloud Storage (Opt-In):**
```
- Encryption: End-to-end (E2EE) with user-controlled key
- Key Management: User's key never touches our servers
- Zero-Knowledge: We cannot decrypt user notes
- Deletion: 30-day deletion window, then permanent
- Jurisdictional: User chooses data residency (US, EU, Asia)
```

### 4.3 AI Processing Transparency

**On-Device Processing (Default):**
```
What Happens Locally:
- Speech-to-text (Whisper model)
- Emotion detection (DistilBERT)
- Named entity recognition (Custom NER)
- Summarization (Extractive model)

User Visibility:
- Green "🔒 On-Device" badge during processing
- Battery/performance impact shown in settings
```

**Cloud Processing (Opt-In Only):**
```
What Goes to Cloud:
- Note text (encrypted in transit, decrypted server-side)
- Prompt for GPT-4 insights

What Stays Private:
- User identity (we only see random UUID)
- Full note history (only current note sent)
- Mood data (never sent to cloud AI)

User Visibility:
- Orange "☁️ Cloud AI" badge during processing
- Explicit consent modal first time
- Usage metrics (MB sent, cost to user)
```

### 4.4 Data Retention & Deletion

**User-Controlled Retention:**
```
Options:
- Keep forever (default)
- Auto-delete after 1 year
- Auto-delete after 6 months
- Delete notes older than X days

Manual Deletion:
- Individual note deletion (immediate)
- Bulk deletion by date range
- Nuclear option: "Delete all data" (requires confirmation)
```

**Our Retention (for product improvement):**
```
Anonymous Analytics:
- Aggregated usage stats: 2 years
- Crash reports: 90 days
- A/B test data: 1 year post-experiment

Identifiable Data:
- Email (for account): Until account deletion + 30 days
- Payment info: Required by law (7 years for tax), stored by Stripe

Deletion Guarantee:
- User requests deletion → 30 days grace period → permanent deletion
- GDPR/CCPA compliant (respond within 30 days)
```

### 4.5 Third-Party Data Sharing

**We NEVER Sell Data. Period.**

**Limited Sharing (with explicit consent):**
```
Analytics Partners (Anonymized Only):
- Amplitude: Product analytics (no notes content)
- Crashlytics: Crash reports (no personal data)
- Stripe: Payment processing (name, email, payment method)

Optional Integrations (User Initiated):
- HealthKit: User shares fitness data with noema
- Therapist Export: User emails notes to their therapist
- Social Sharing: User shares achievement card publicly

Legal Requirements:
- Comply with valid subpoenas (notify user unless prohibited)
- Report child abuse if legally mandated (we train staff to recognize)
```

---

## 5. Transparency & Explainability

### 5.1 AI Explanations (XAI - Explainable AI)

**Every AI Output Includes "Why":**

**Example: Mood Detection**
```
Detected Mood: Anxious (82% confidence)

Why?
- Keywords: "worried", "nervous", "can't stop thinking" (40%)
- Sentence structure: Short, fragmented sentences (25%)
- Voice tone: Elevated pitch, faster speech (20%)
- Context: Similar patterns in past anxious notes (15%)

Confidence: 82% (High)
```

**Example: Summary Generation**
```
Summary: "Discussed upcoming work presentation and strategies to manage anxiety"

How we created this:
- Extracted main topic: "work presentation" (appears 5 times)
- Identified emotion: "anxiety" (detected in 4 paragraphs)
- Action items: "practice speech" (mentioned twice)

Source sentences: [Highlighted in original note]
```

### 5.2 Model Cards (Public Documentation)

**For Each AI Model, We Publish:**
```
- Model Name & Version
- Training Data Sources (anonymized demographics)
- Performance Metrics (accuracy, bias scores)
- Known Limitations
- Intended Use Cases
- Inappropriate Use Cases
- Last Updated Date
```

**Example: Emotion Detection Model v2.1**
```
Training Data: 500K anonymized notes from 10K users (opt-in)
Accuracy: 89.3% (validated against human experts)
Gender Bias: 2.1% variance (within acceptable range)
Known Limitations:
  - Less accurate on sarcasm (73% accuracy)
  - Cultural adaptation needed for APAC (in progress)
Inappropriate Uses:
  - NOT for clinical diagnosis
  - NOT for employment decisions
  - NOT for law enforcement
```

### 5.3 User Control Dashboard

**Privacy Dashboard Features:**
```
Real-Time Monitoring:
- "AI Activity Log": Shows every AI operation in last 24 hours
- "Data Sent to Cloud": MB count and timestamps
- "Battery Impact": AI processing battery usage

Controls:
- Toggle on-device vs. cloud AI per feature
- Download all data (JSON export)
- Request account data report (GDPR)
- Delete specific data types
- Disable specific AI features

Transparency Reports:
- Monthly email: "Your AI Usage Summary"
- Shows: Notes created, moods logged, AI features used
- Privacy score: "100% on-device this month"
```

---

## 6. Clinical Validation

### 6.1 Validation Requirements

**Before Launch:**
```
1. Expert Review:
   - 3 licensed clinical psychologists review crisis protocols
   - Ethics board approval (external members)
   - Legal review of all disclaimers

2. Pilot Study (N=100 users, 3 months):
   - Compare noema mood detection vs. daily self-reports
   - Track mental health outcomes (validated scales: PHQ-9, GAD-7)
   - Qualitative interviews on user experience

3. Crisis Protocol Testing:
   - Simulate 100 crisis scenarios with actors
   - Measure intervention timing and resource quality
   - Ensure <10 second response time
```

**Ongoing Validation:**
```
Annual Studies:
- Partner with university research labs
- Publish findings in peer-reviewed journals
- Open-source anonymized datasets (with user consent)

Monthly Audits:
- Clinical advisor reviews crisis interventions
- Identify false positives/negatives
- Update keyword lists and thresholds
```

### 6.2 Validated Measurement Scales

**Mood Tracking Validation:**
- **Benchmark**: PANAS (Positive and Negative Affect Schedule)
- **Target Correlation**: r > 0.75 with PANAS scores
- **Frequency**: Monthly user surveys

**Wellness Score Validation:**
- **Benchmark**: WHO-5 Well-Being Index
- **Target Correlation**: r > 0.70
- **Frequency**: Quarterly user surveys

---

## 7. Governance & Accountability

### 7.1 Ethics Review Board

**Composition:**
```
Internal Members (3):
- Chief Product Officer
- Lead AI Engineer
- Head of Design

External Members (4):
- Licensed Clinical Psychologist (mental health expertise)
- AI Ethics Researcher (academic, no financial ties)
- Privacy Attorney (GDPR/CCPA specialist)
- User Representative (elected from community, 1-year term)
```

**Responsibilities:**
- Review all new AI features before launch
- Quarterly review of bias metrics
- Approve crisis protocol changes
- Investigate user complaints about AI ethics

**Decision-Making:**
- Majority vote required for feature approval
- Any member can veto on ethical grounds (requires full board discussion)
- Meetings: Monthly (first Tuesday)
- Minutes: Published publicly (redacted for user privacy)

### 7.2 Incident Response

**AI Harm Incident Definition:**
- User reports mental health worsened due to app
- Crisis intervention failure (false negative)
- Major bias discovered post-launch
- Privacy breach (data exposure)

**Response Protocol:**
```
1. Detection (within 24 hours):
   - User reports, internal monitoring, press coverage

2. Assessment (within 48 hours):
   - Severity score (1-5, where 5 = life-threatening)
   - Scope (how many users affected)
   - Root cause analysis

3. Immediate Action (within 72 hours):
   - Severity 5: Disable feature immediately, notify all users
   - Severity 3-4: Roll back to previous version, investigate
   - Severity 1-2: Monitor closely, plan fix

4. Long-Term Fix (within 30 days):
   - Update model/feature
   - Publish incident report (transparency)
   - Compensate affected users (refund, free months)

5. Prevention (within 90 days):
   - Update testing protocols
   - Retrain team
   - External audit if needed
```

### 7.3 Public Transparency

**Annual Transparency Report:**
```
Published Data:
- Total users, growth rate
- Crisis interventions (aggregate, no personal data)
  - Total interventions: X
  - Follow-up response rate: Y%
  - User feedback on helpfulness: Z/10
- Bias audit results (by demographic)
- Government data requests (number, type, how we responded)
- Privacy incidents (if any, with full details)
- Model performance metrics
- Ethical review board decisions (summary)
```

**Quarterly Blog Posts:**
- "Behind the AI": How a feature works
- User stories (with permission)
- Research findings
- Product roadmap updates

### 7.4 User Feedback & Complaints

**Feedback Channels:**
```
In-App:
- "Report AI Issue" button in every AI feature
- Mood detection feedback: "Was this accurate?"
- Crisis intervention feedback: "Was this helpful?"

External:
- ethics@noema.app (monitored 24/7)
- Public form on website
- Discord/Reddit community

Response SLA:
- Crisis-related: 4 hours
- Privacy concerns: 24 hours
- Bias reports: 48 hours
- General feedback: 7 days
```

**Complaint Tracking:**
```
Dashboard Metrics:
- Complaints per 1,000 users
- Resolution time (average)
- User satisfaction with resolution
- Repeat complainers (indicates systemic issue)

Escalation:
- >10 complaints on same issue → Product team alerted
- Unresolved complaint >30 days → Executive review
- Ethics board review quarterly
```

---

## Appendix A: Crisis Resource Database

### United States
- **988 Suicide & Crisis Lifeline**: 988 (call/text)
- **Crisis Text Line**: Text HOME to 741741
- **SAMHSA National Helpline**: 1-800-662-4357
- **Veterans Crisis Line**: 1-800-273-8255, Press 1
- **Trevor Project (LGBTQ Youth)**: 1-866-488-7386

### International
- **International Association for Suicide Prevention**: www.iasp.info/resources
- **Befrienders Worldwide**: www.befrienders.org

### By Region
[Complete database to be maintained in `resources/crisis_hotlines.json`]

---

## Appendix B: Glossary

**Crisis Intervention**: Immediate support provided when AI detects potential self-harm or suicide risk.

**Bias Audit**: Systematic testing of AI models across demographic groups to ensure fairness.

**Zero-Knowledge Architecture**: System design where service provider cannot access user data even if compelled.

**Model Card**: Standardized documentation of AI model characteristics, performance, and limitations.

**Explainable AI (XAI)**: Techniques to make AI decisions interpretable to users.

**False Positive (Crisis Detection)**: AI flags a crisis when user is not in crisis.

**False Negative (Crisis Detection)**: AI fails to detect actual crisis (more dangerous).

---

## Document Control

**Version History:**
- v1.0 (2025-11-17): Initial comprehensive guidelines

**Review Schedule:**
- **Quarterly**: Crisis protocols, resource database
- **Bi-Annually**: Bias testing procedures, privacy policies
- **Annually**: Full document review by ethics board

**Approval:**
- Ethics Review Board: [Pending]
- Legal Team: [Pending]
- Clinical Advisor: [Pending]

**Contact:**
- Ethics questions: ethics@noema.app
- Clinical feedback: clinical@noema.app
- Privacy concerns: privacy@noema.app

---

*This document represents noema's commitment to building AI that respects human dignity, privacy, and mental health. It is a living document and will evolve as we learn from users, research, and the broader AI ethics community.*
