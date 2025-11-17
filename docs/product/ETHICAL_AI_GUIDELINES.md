# Noema Ethical AI Guidelines
## Building AI That Understands Emotions Responsibly

**Version**: 1.0
**Last Updated**: January 2025

---

## Our Ethical Commitment

Noema uses AI to analyze emotions, detect patterns, and provide insights into users' mental and emotional states. This is a profound responsibility. We are committed to building AI that **empowers, not manipulates; supports, not exploits; and respects human agency above all.**

These guidelines govern how we design, train, deploy, and evaluate AI systems in Noema.

---

## 1. Core Principles

### 1.1 Human Agency & Control

**Principle**: AI suggests, humans decide. Users must always have the final say.

**In Practice:**
- ✅ All AI outputs (emotions, insights, summaries) are presented as suggestions, not facts
- ✅ Users can override any AI decision (e.g., correct detected emotions)
- ✅ Users can disable any AI feature without losing core functionality
- ✅ Explainability: AI decisions are explained (e.g., "Detected 'joy' based on words: 'excited', 'amazing'")
- ❌ No manipulation: AI never nudges users toward specific emotional states or behaviors

**Example:**
```
AI Suggestion: "It seems like you're feeling anxious. Is that accurate?"
User Options: [Yes] [No, I'm actually...] [I don't know]
```

---

### 1.2 Transparency & Explainability

**Principle**: Users deserve to know how AI works and why it makes decisions.

**In Practice:**
- ✅ Confidence scores shown for all AI outputs (e.g., "85% confidence")
- ✅ Explainable AI: Show which features influenced a decision
  - "Emotion 'sadness' detected due to words: 'disappointed', 'frustrated'"
  - "Speaking rate was 20% slower than usual, indicating low energy"
- ✅ Model cards: Document AI models (training data, limitations, biases)
- ✅ Open-source core algorithms (planned): Allow independent audits
- ❌ No "black box" AI that users can't understand

**Transparency Dashboard:**
- Show users exactly what data is being processed
- Explain how on-device vs cloud processing works
- Provide links to technical documentation

---

### 1.3 Privacy & Data Minimization

**Principle**: Use the minimum data necessary, process locally when possible, never misuse personal data.

**In Practice:**
- ✅ On-device AI: 90% of processing happens locally (no data transmission)
- ✅ Zero-knowledge architecture: We can't access users' encrypted notes
- ✅ Opt-in cloud AI: Users explicitly consent before any data is sent to cloud
- ✅ Ephemeral processing: Cloud-processed data is immediately deleted
- ✅ No data sales: We never sell user data to third parties
- ✅ No training on user data without consent: User data is not used to improve models for others unless explicitly opted in
- ❌ No hidden data collection or tracking

**See**: [Privacy Policy](../legal/PRIVACY_POLICY.md) for full details.

---

### 1.4 Fairness & Non-Discrimination

**Principle**: AI must work equally well for all users, regardless of demographics.

**In Practice:**
- ✅ Diverse training data: Include multiple cultures, languages, ages, genders, neurodiversities
- ✅ Bias testing: Evaluate models on demographic slices (age, gender, ethnicity, language)
- ✅ Culturally sensitive emotion detection: Recognize that emotional expression varies by culture
  - Example: Western cultures may express emotions more directly; East Asian cultures may be more reserved
- ✅ Accessibility: Full support for VoiceOver, dynamic text, high contrast modes
- ❌ No discriminatory outcomes: Ensure AI doesn't favor or penalize specific groups

**Fairness Audits:**
- Quarterly fairness audits on production AI models
- Measure accuracy across demographic groups
- Address disparities with targeted model improvements

---

### 1.5 Beneficence & Non-Maleficence

**Principle**: AI should help, not harm. Do good, avoid harm.

**In Practice:**
- ✅ Positive psychology framing: Focus on growth, not deficits
  - Instead of "You're not happy enough," say "Here's when you felt most energized"
- ✅ Supportive, non-judgmental tone in all AI-generated text
- ✅ Avoid reinforcing negative patterns: If AI detects prolonged sadness, offer resources, not just data
- ✅ Crisis intervention: Detect self-harm indicators and provide resources (see Section 2)
- ❌ No emotional manipulation: AI doesn't exploit vulnerabilities to increase engagement
- ❌ No gamification abuse: Streaks and achievements are motivating, not guilt-inducing

**Example: Positive Framing**
- ❌ Bad: "You've been stressed for 7 days. This is concerning."
- ✅ Good: "You've navigated a challenging week. What helped you cope?"

---

### 1.6 User Well-Being Over Engagement

**Principle**: We optimize for user well-being, not screen time or engagement metrics.

**In Practice:**
- ✅ Gentle nudges: Reflection prompts are supportive, not nagging
- ✅ Streak freezes: Life happens—users get 2 streak freezes per month
- ✅ No dark patterns: No manipulative design to keep users in the app
- ✅ Encourage breaks: If user is using app excessively, suggest taking a break
- ❌ No infinite scroll or addictive mechanics

**Metrics We Don't Optimize For:**
- Session duration (longer isn't better)
- Daily active users (quality over quantity)
- Notification click-through rate (respect user time)

**Metrics We Do Optimize For:**
- User-reported well-being improvements
- Quality of reflections (depth, insight)
- Emotional balance (healthy variance, not flatline)

---

## 2. Crisis Intervention Protocols

### 2.1 Detecting Crisis Indicators

**AI may detect:**
- Text containing self-harm or suicidal ideation keywords
- Prolonged extreme negative mood (>7 days of very low valence)
- Sudden drastic mood changes (anomaly detection)

**Important**: AI is not perfect. False positives and false negatives are possible.

---

### 2.2 Intervention Actions

**What We Do:**
1. **Immediate Resources**
   - Display in-app alert with crisis hotlines
   - "If you're in crisis, please reach out: National Suicide Prevention Lifeline: 988"
   - Localized resources (US, UK, EU, etc.)

2. **Gentle Check-In**
   - "We noticed you might be going through a tough time. Would you like some resources?"
   - Link to mental health resources (BetterHelp, Talkspace, local therapists)

3. **Suggest Professional Help**
   - "Consider speaking with a mental health professional. Noema is a journaling tool, not therapy."

**What We Don't Do:**
- ❌ Contact emergency services without consent
- ❌ Notify anyone (family, friends, authorities) without consent
- ❌ Break encryption to access notes
- ❌ Use crisis detection to manipulate or exploit vulnerability

---

### 2.3 Disclaimers

**Shown on onboarding and in crisis situations:**

> "Noema is a personal journaling and self-reflection tool, **not a substitute for professional mental health care**. If you're experiencing a crisis, please contact a mental health professional or crisis helpline immediately."

---

## 3. AI Training & Data Governance

### 3.1 Training Data Sources

**Public Datasets:**
- GoEmotions (emotional text classification)
- CoNLL-2003, OntoNotes (named entity recognition)
- RAVDESS (voice emotion)
- Whisper training data (transcription)

**Custom Datasets (Opt-In Only):**
- If users consent, we collect anonymized journaling data
- **Strict Anonymization**:
  - Remove all PII (names, locations, phone numbers, emails)
  - Differential privacy: Add noise to aggregated statistics
  - K-anonymity: Ensure at least 10 users per data point
  - Human review of sample data for PII leakage

**Data Collection Consent:**
- Explicit opt-in: "Help improve Noema by contributing anonymized data"
- Clear explanation of what data is collected and how it's used
- Users can withdraw consent anytime
- Users can request deletion of contributed data

---

### 3.2 Model Evaluation

**Metrics:**
- **Accuracy**: >90% on emotion detection, >85% on NER
- **Fairness**: <5% accuracy disparity across demographic groups
- **Calibration**: Confidence scores should match actual accuracy

**Testing:**
- Hold-out test set (never seen during training)
- Cross-validation (5-fold)
- Adversarial testing (edge cases, noisy data)
- Demographic slice testing (age, gender, ethnicity, language)

---

### 3.3 Continuous Improvement

**User Feedback Loop:**
- Users can "thumbs up/down" AI outputs
- Corrections are logged (e.g., user changes "joy" to "anxiety")
- Corrections used to fine-tune models (only with consent)

**A/B Testing:**
- New models tested on 10% of users
- Monitor accuracy, user satisfaction, and ethical concerns
- Gradual rollout if successful

---

## 4. Bias Mitigation

### 4.1 Known Biases in Emotion AI

**Cultural Bias:**
- Western emotion models may not generalize to non-Western cultures
- Example: East Asian cultures may use different emotional expression norms

**Language Bias:**
- Models trained on English may perform worse on other languages
- Non-native speakers may be misclassified

**Gender Bias:**
- Voice emotion models may perform differently for different genders
- Example: Higher-pitched voices (often women) may be misclassified as "anxious"

**Neurodiversity Bias:**
- Autistic users may express emotions differently (e.g., flat affect)
- ADHD users may have more emotional variability

---

### 4.2 Mitigation Strategies

**Diverse Training Data:**
- Include multiple languages, cultures, ages, genders
- Actively seek underrepresented groups in data collection

**Bias Testing:**
- Evaluate models on demographic slices
- Measure accuracy for each group
- Require <5% disparity across groups

**Customization:**
- Allow users to teach AI their unique emotional expression
- Example: "When I say 'fine,' I usually mean 'stressed'"

**Transparency:**
- Acknowledge limitations in model cards
- Example: "This emotion model was trained primarily on English text and may be less accurate for other languages"

---

## 5. Mental Health Considerations

### 5.1 Not Therapy

**Clear Positioning:**
- Noema is a **self-reflection tool**, not therapy
- We never claim to diagnose or treat mental health conditions
- Disclaimers shown prominently in marketing and app

**Boundaries:**
- No AI-generated therapeutic advice
- No diagnosis of mental health conditions (e.g., "You have depression")
- Suggest professional help when appropriate

---

### 5.2 Potential Risks

**Over-Reliance on AI:**
- Risk: Users may trust AI insights over their own judgment
- Mitigation: Emphasize AI as a tool, not a truth-teller
- Encourage critical thinking: "Does this resonate with you?"

**Negative Reinforcement:**
- Risk: AI showing patterns like "You're always stressed on Mondays" could create self-fulfilling prophecy
- Mitigation: Frame patterns as opportunities for change, not fixed traits

**Privacy Anxiety:**
- Risk: Users may fear AI "knows too much" about them
- Mitigation: Privacy Dashboard, transparency, user control

---

### 5.3 Positive Psychology Approach

**Strengths-Based:**
- Focus on what's working, not just problems
- Example: "You're most creative on Tuesday evenings" (actionable insight)

**Growth Mindset:**
- Emotions are not fixed—they can change
- Frame insights as opportunities for growth

**Self-Compassion:**
- Avoid judgmental language
- Normalize emotional struggles: "It's okay to have difficult emotions"

---

## 6. Accountability & Governance

### 6.1 Ethics Review Board

**Composition:**
- Product Manager
- Lead AI/ML Engineer
- Mental Health Professional (advisor)
- Privacy/Security Expert (advisor)
- External ethicist (advisor, independent)

**Responsibilities:**
- Review all new AI features for ethical concerns
- Quarterly review of AI performance and user feedback
- Approve changes to AI training data or models
- Investigate ethical complaints

**Meeting Frequency:** Quarterly, or ad-hoc for urgent issues

---

### 6.2 User Reporting

**How Users Can Report Concerns:**
- In-app: Settings → Privacy → Report Ethical Concern
- Email: ethics@noema.app
- Anonymous form: noema.app/ethics-report

**Response Time:**
- Acknowledge within 48 hours
- Investigate and respond within 14 days
- Public transparency reports (aggregated, anonymized)

---

### 6.3 Transparency Reports

**Published Quarterly:**
- Number of ethical concerns reported
- Types of concerns (privacy, bias, harmful AI behavior)
- Actions taken
- Changes made to AI systems

**Example:**
> "Q4 2025: We received 12 reports of emotion misclassification for non-English users. We fine-tuned our multilingual models and improved accuracy by 8%."

---

## 7. External Partnerships & Research

### 7.1 Academic Collaborations

**Goal:** Contribute to responsible AI research

**Partnerships:**
- Universities researching emotional intelligence, NLP, mental health AI
- Share anonymized, aggregated findings (with user consent)
- Co-author papers on ethical AI in personal wellness

---

### 7.2 Open Source Commitment (Planned)

**What We'll Open-Source:**
- Core AI algorithms (after launch)
- Fairness testing framework
- Model evaluation tools
- Data anonymization pipeline

**Benefits:**
- Transparency: Independent audits
- Trust: Users can verify our claims
- Community: Contributions from researchers and developers

---

## 8. Continuous Ethical Evaluation

### 8.1 Key Questions We Ask

Before deploying any AI feature:

1. **Agency**: Does this empower users or manipulate them?
2. **Transparency**: Can users understand how this works?
3. **Privacy**: Does this respect user privacy?
4. **Fairness**: Does this work equally well for all users?
4. **Well-Being**: Does this help or harm?
6. **Necessity**: Is AI even needed for this feature?

---

### 8.2 Red Lines (Never Cross)

❌ **Sell user data** to advertisers or third parties
❌ **Train AI on user data** without explicit consent
❌ **Use dark patterns** to manipulate engagement
❌ **Diagnose mental health conditions** without clinical expertise
❌ **Break encryption** to access user notes
❌ **Optimize for engagement** over well-being
❌ **Deploy biased AI** that discriminates

---

## 9. Case Studies: Ethical Decisions

### Case Study 1: Detecting Suicidal Ideation

**Scenario**: AI detects text indicating suicidal ideation.

**Ethical Dilemma**: Should we alert authorities? Break encryption to read full note?

**Decision**:
- ❌ No automatic intervention (respects autonomy)
- ❌ No encryption breaking (respects privacy)
- ✅ Show resources (crisis hotlines, therapist links)
- ✅ Gentle check-in (non-judgmental, supportive)

**Reasoning**: User agency and privacy outweigh paternalistic intervention. We provide resources, not forceful action.

---

### Case Study 2: Gamification & Guilt

**Scenario**: User breaks a 100-day streak.

**Ethical Dilemma**: Should we send a notification to re-engage?

**Decision**:
- ❌ No guilt-inducing message ("You broke your streak!")
- ❌ No aggressive re-engagement push
- ✅ Offer streak freeze (if available)
- ✅ Gentle nudge after 3 days: "We're here when you're ready"

**Reasoning**: Well-being over engagement. Streaks should motivate, not guilt-trip.

---

### Case Study 3: Bias in Voice Emotion Detection

**Scenario**: Voice emotion model performs 15% worse for women (higher-pitched voices misclassified as "anxious").

**Ethical Dilemma**: Launch with bias, or delay to fix?

**Decision**:
- ❌ Don't launch with known bias
- ✅ Collect more diverse training data (women's voices)
- ✅ Fine-tune model to reduce gender disparity to <5%
- ✅ Publish findings transparently

**Reasoning**: Fairness is non-negotiable. Delay launch to ensure equitable performance.

---

## 10. Future Ethical Challenges

### 10.1 Multimodal AI (Images, Video)

**Challenge**: Analyzing facial expressions, body language
- **Privacy concerns**: Cameras in personal spaces
- **Bias risks**: Facial recognition often biased against darker skin tones

**Approach**: Extreme caution, extensive fairness testing, user control

---

### 10.2 Generative AI (Writing Assistance)

**Challenge**: AI helps users write journal entries
- **Authenticity concerns**: Is it still "your" journal if AI wrote it?
- **Manipulation risk**: AI could steer reflections in specific directions

**Approach**: Human-in-the-loop, AI as suggestion only, transparency

---

### 10.3 Social Features (Sharing Insights)

**Challenge**: Users share anonymized mood trends with community
- **Privacy risks**: Re-identification from patterns
- **Social comparison**: Comparing wellness scores could harm self-esteem

**Approach**: Strict anonymization, opt-in only, no ranking/leaderboards

---

## Conclusion: Our Pledge

We pledge to:
- **Put users first**: Well-being over profit
- **Be transparent**: Open about how AI works and its limitations
- **Empower, not exploit**: AI as a tool for self-discovery, not manipulation
- **Continuously improve**: Learn from mistakes, adapt to new challenges
- **Welcome scrutiny**: Open-source, external audits, user feedback

**AI is powerful. Emotion AI is especially powerful. With great power comes great responsibility.**

Noema is committed to wielding this power ethically, transparently, and in service of human flourishing.

---

**Questions? Concerns? We're listening.**

Email: ethics@noema.app

---

**Version History:**
- v1.0 (January 2025): Initial guidelines (pre-launch)

**Next Review**: Quarterly, or upon major AI feature launch
