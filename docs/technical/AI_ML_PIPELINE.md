# Noema AI/ML Pipeline Architecture
## On-Device & Cloud AI Processing

---

## Overview

Noema's AI/ML architecture is **hybrid**: prioritizing on-device processing for privacy and performance, with optional cloud-based models for advanced features (user opt-in only).

**Core Principles:**
1. **Privacy-First**: Default to on-device processing
2. **Performance**: Optimized for real-time inference on mobile devices
3. **Accuracy**: >90% accuracy on core tasks (sentiment, NER)
4. **Battery-Efficient**: Minimal impact on device battery life
5. **Graceful Degradation**: Core features work without cloud access

---

## 1. On-Device AI Models

### 1.1 Speech-to-Text (Transcription)

**Base Model:** Whisper-Small (OpenAI)

**Optimizations:**
- Quantized to INT8 for 4x speedup
- Core ML conversion for iOS acceleration
- Model size: ~250MB (acceptable for app bundle or on-demand download)

**Performance Targets:**
- Speed: <2 seconds per minute of audio (iPhone 13+)
- Accuracy: >98% WER (Word Error Rate) on clean audio, >95% on noisy audio
- Languages: 50+ supported (multilingual model)

**Implementation:**
```swift
import CoreML
import Speech

class TranscriptionService {
    private var whisperModel: WhisperSmall?

    func transcribe(audioURL: URL) async throws -> TranscriptionResult {
        // Load audio
        let audioData = try loadAudio(from: audioURL)

        // Preprocess (convert to 16kHz mono, normalize)
        let preprocessedAudio = preprocessAudio(audioData)

        // Run inference
        let prediction = try await whisperModel?.prediction(from: preprocessedAudio)

        // Post-process (punctuation, capitalization)
        let transcription = postProcessTranscription(prediction)

        return TranscriptionResult(
            text: transcription.text,
            confidence: transcription.confidence,
            language: transcription.detectedLanguage,
            timestamps: transcription.wordTimestamps
        )
    }

    private func preprocessAudio(_ data: AudioData) -> MLMultiArray {
        // Convert to mel spectrogram
        // Normalize to [-1, 1]
        // Return as MLMultiArray
    }

    private func postProcessTranscription(_ raw: RawTranscription) -> Transcription {
        // Add punctuation using linguistic rules
        // Capitalize proper nouns
        // Add speaker labels (if diarization enabled)
    }
}

struct TranscriptionResult {
    var text: String
    var confidence: Double
    var language: String
    var timestamps: [WordTimestamp]
}

struct WordTimestamp {
    var word: String
    var startTime: TimeInterval
    var endTime: TimeInterval
    var confidence: Double
}
```

**Fallback Strategy:**
- If device too old (iPhone <13): Use Apple's built-in Speech Recognition API
- If Whisper fails: Graceful error, allow manual text entry

---

### 1.2 Sentiment Analysis & Emotion Detection

**Base Model:** DistilBERT-base-uncased (fine-tuned)

**Training Data:**
- GoEmotions dataset (58K Reddit comments, 28 emotion labels)
- Custom dataset: 10K journaling entries (anonymized, consented)
- Augmentation: Paraphrasing, back-translation

**Fine-Tuning:**
- Multi-label classification (user can feel multiple emotions)
- Regression heads for valence, arousal, dominance (VAD model)

**Model Architecture:**
```
Input: Text (max 512 tokens)
  ↓
DistilBERT Encoder (6 layers, 768 hidden)
  ↓
[CLS] token representation
  ↓
┌─────────────────┬─────────────────┬─────────────────┐
│ Emotion Head    │ VAD Head        │ Intensity Head  │
│ (28 labels)     │ (3 outputs)     │ (1 output)      │
│ Sigmoid         │ Tanh            │ Sigmoid         │
└─────────────────┴─────────────────┴─────────────────┘
  ↓
Output: {emotions, valence, arousal, dominance, intensity}
```

**Optimizations:**
- Quantized to INT8 (4x smaller, 4x faster)
- Distilled from BERT-base (2x smaller, 1.5x faster)
- Pruned 30% of weights with <2% accuracy loss

**Performance:**
- Inference time: <100ms per note (iPhone 13+)
- Accuracy: >90% on multi-label emotion detection
- Battery impact: <1% per 100 inferences

**Implementation:**
```swift
import CoreML
import NaturalLanguage

class SentimentAnalysisService {
    private var bertModel: DistilBERTSentiment?

    func analyze(text: String) async throws -> EmotionalState {
        // Tokenize text
        let tokens = tokenize(text)

        // Run inference
        let output = try await bertModel?.prediction(tokens: tokens)

        // Parse output
        let emotions = parseEmotions(output.emotionLogits)
        let vad = parseVAD(output.vadOutputs)
        let intensity = output.intensity

        return EmotionalState(
            valence: vad.valence,
            arousal: vad.arousal,
            dominance: vad.dominance,
            primaryEmotion: emotions.primary,
            secondaryEmotions: emotions.secondary,
            emotionIntensity: intensity,
            confidence: output.confidence,
            detectionSources: [.textSentiment]
        )
    }

    private func tokenize(_ text: String) -> [Int] {
        // Use NLTokenizer for word splitting
        // Convert to DistilBERT vocab IDs
        // Add [CLS], [SEP] tokens
        // Pad to 512 tokens
    }

    private func parseEmotions(_ logits: MLMultiArray) -> (primary: EmotionType, secondary: [EmotionType]) {
        // Apply sigmoid threshold (0.5)
        // Sort by confidence
        // Return top emotion as primary, others as secondary
    }
}
```

---

### 1.3 Named Entity Recognition (NER)

**Base Model:** Custom transformer-based NER

**Entity Types:**
- Person, Place, Organization (standard)
- Date, Time (temporal)
- Topic, Project, Goal, Hobby (custom for journaling)

**Training Data:**
- CoNLL-2003 (news articles)
- OntoNotes 5.0 (diverse text)
- Custom dataset: 5K annotated journal entries

**Model Architecture:**
```
Input: Text (tokenized)
  ↓
BERT-base Encoder
  ↓
Token-level representations
  ↓
BiLSTM-CRF Layer (captures sequential dependencies)
  ↓
Output: BIO tags for each token
  (B-PERSON, I-PERSON, O, B-PLACE, etc.)
```

**Post-Processing:**
- Entity linking: Resolve co-references ("Sarah" = "Sarah Johnson" = "Mom")
- Custom entity detection: Use regex + context for projects, goals
- Relationship extraction: Detect entity-entity relationships

**Performance:**
- Inference: <200ms per note
- Precision: >85% (standard entities), >75% (custom entities)
- Recall: >80%

**Implementation:**
```swift
class NERService {
    private var nerModel: BERTNERModel?
    private var entityResolver: EntityResolver?

    func extractEntities(from text: String) async throws -> [DetectedEntity] {
        // Tokenize
        let tokens = tokenize(text)

        // Run NER model
        let bioTags = try await nerModel?.predict(tokens: tokens)

        // Convert BIO tags to entities
        let rawEntities = parseBIOTags(bioTags, tokens: tokens)

        // Resolve entities (merge duplicates, link aliases)
        let resolvedEntities = try await entityResolver?.resolve(rawEntities)

        return resolvedEntities
    }

    private func parseBIOTags(_ tags: [BIOTag], tokens: [String]) -> [RawEntity] {
        // Combine B-X and I-X tags into entities
        // Extract text spans
    }
}

struct DetectedEntity {
    var text: String
    var type: EntityType
    var range: Range<String.Index>
    var confidence: Double
    var aliases: [String]?
}
```

---

### 1.4 Voice Emotion Analysis (Paralinguistic)

**Goal:** Detect emotion from voice characteristics (tone, pitch, energy), not just words.

**Features Extracted:**
- **Pitch** (F0): Mean, variance, range
- **Energy**: RMS energy, spectral energy
- **Speaking Rate**: Words per minute, pause frequency
- **Jitter/Shimmer**: Voice quality metrics (stress indicators)
- **MFCCs**: Mel-frequency cepstral coefficients (timbral features)

**Model:** XGBoost Classifier

**Training Data:**
- RAVDESS (emotional speech dataset)
- Custom recordings (consented volunteers)

**Emotions Detected:**
- Happy, Sad, Angry, Fearful, Neutral, Excited

**Implementation:**
```swift
import AVFoundation
import Accelerate

class VoiceEmotionService {
    func analyzeVoiceEmotion(audioURL: URL) async throws -> VoiceEmotionData {
        // Load audio
        let audioBuffer = try loadAudioBuffer(from: audioURL)

        // Extract features
        let features = extractParalinguisticFeatures(audioBuffer)

        // Run XGBoost model
        let prediction = try await voiceEmotionModel?.predict(features: features)

        return VoiceEmotionData(
            pitch: features.meanPitch,
            pitchVariability: features.pitchVariance,
            energy: features.energy,
            speakingRate: features.speakingRate,
            pauseFrequency: features.pauseFrequency,
            detectedEmotion: prediction.emotion,
            confidence: prediction.confidence
        )
    }

    private func extractParalinguisticFeatures(_ buffer: AVAudioPCMBuffer) -> ParalinguisticFeatures {
        // Pitch extraction (autocorrelation or YIN algorithm)
        let pitch = extractPitch(buffer)

        // Energy (RMS)
        let energy = calculateRMS(buffer)

        // Speaking rate (VAD + word boundaries)
        let speakingRate = estimateSpeakingRate(buffer)

        // Pause detection
        let pauseFrequency = detectPauses(buffer)

        // MFCCs
        let mfccs = extractMFCCs(buffer, numCoefficients: 13)

        return ParalinguisticFeatures(...)
    }
}
```

---

### 1.5 Mood Pattern Recognition (LSTM)

**Goal:** Learn temporal patterns in mood, predict future states.

**Model:** Bidirectional LSTM

**Input Sequence:**
- Historical mood states (valence, arousal, energy) - 30 days
- Contextual features: time of day, day of week, weather, sleep, exercise

**Output:**
- Predicted mood for next 24 hours
- Confidence interval

**Training:**
- User-specific: Fine-tune on individual's data after 30 days
- Cold-start: Use aggregated (anonymized) patterns from similar users

**Implementation:**
```swift
class MoodPredictionService {
    private var lstmModel: MoodLSTM?

    func predictMood(for date: Date, context: MoodContext) async throws -> EmotionalStatePrediction {
        // Get historical mood sequence (30 days)
        let historicalMoods = try await fetchHistoricalMoods(days: 30)

        // Encode context (time, weather, sleep, etc.)
        let contextVector = encodeContext(context)

        // Prepare input sequence
        let inputSequence = prepareSequence(historical: historicalMoods, context: contextVector)

        // Run LSTM
        let prediction = try await lstmModel?.predict(sequence: inputSequence)

        return EmotionalStatePrediction(
            predictedState: prediction.state,
            confidence: prediction.confidence,
            reasoning: generateReasoning(prediction, context)
        )
    }

    private func generateReasoning(_ prediction: Prediction, _ context: MoodContext) -> String {
        // Explain why this mood is predicted
        // e.g., "Based on your patterns, Monday mornings tend to be lower energy. Rainy weather may also contribute."
    }
}
```

---

## 2. Cloud AI Models (Optional, User Opt-In)

### 2.1 Advanced Summarization

**Model:** GPT-4-Turbo or Claude 3.5 Sonnet

**Use Case:** Generate insightful, conversational summaries with deeper understanding.

**Privacy:**
- Content encrypted client-side (AES-256)
- Transmitted over TLS to cloud
- Server decrypts temporarily for processing
- Summary returned, content not stored
- User explicitly opts in

**Prompt Engineering:**
```
You are a compassionate AI assistant helping a user reflect on their thoughts.

The user wrote the following note:
[ENCRYPTED_NOTE_CONTENT]

Please provide:
1. A concise summary (3-5 sentences)
2. Key insights or patterns you notice
3. Gentle questions to deepen reflection

Tone: Supportive, non-judgmental, curious.
```

**API Call:**
```swift
class CloudSummarizationService {
    func generateAdvancedSummary(note: Note, style: SummaryStyle) async throws -> AdvancedSummary {
        // Encrypt note content
        let encrypted = try encryptionService.encrypt(note.content)

        // Call cloud API
        let request = SummarizationRequest(
            encryptedContent: encrypted,
            style: style,
            detailLevel: .detailed
        )
        let response = try await apiClient.post("/notes/summarize", body: request)

        return AdvancedSummary(
            summary: response.summary,
            keyPoints: response.keyPoints,
            reflectionQuestions: response.reflectionQuestions
        )
    }
}
```

---

### 2.2 Knowledge Graph Reasoning (Graph Neural Network)

**Model:** Custom Graph Attention Network (GAT)

**Use Case:**
- Infer latent relationships between entities
- Recommend entities to revisit ("You haven't mentioned Sarah in 2 months, but she's historically important")
- Detect community clusters

**Architecture:**
```
Input: Knowledge Graph (nodes, edges, features)
  ↓
Graph Attention Layer 1 (attention over neighbors)
  ↓
Graph Attention Layer 2
  ↓
Graph Pooling (aggregate node representations)
  ↓
MLP (Multi-Layer Perceptron)
  ↓
Output: Inferred relationships, recommendations
```

**Why Cloud?**
- Graph too large for on-device memory (50K+ entities)
- Computationally intensive (attention over all edges)

**Privacy:**
- Graph structure encrypted
- Entity names hashed (one-way)
- Results returned with hashed IDs, client decrypts

---

## 3. Model Training & Fine-Tuning Pipeline

### 3.1 Data Collection (Privacy-Preserving)

**User Consent:**
- Opt-in: "Help improve Noema by contributing anonymized data"
- Explicit consent form, GDPR-compliant

**Anonymization:**
- Remove PII (names, locations, phone numbers)
- Differential privacy: Add noise to aggregated statistics
- K-anonymity: Ensure at least K users per data point

**Data Validation:**
- Human review of sample data
- Automated PII detection
- User can review what's shared

---

### 3.2 Model Training Infrastructure

**Tools:**
- **Framework:** PyTorch / TensorFlow
- **Training:** AWS SageMaker or Google Vertex AI
- **Experiment Tracking:** Weights & Biases
- **Data Versioning:** DVC (Data Version Control)

**Training Process:**
1. Collect anonymized data (monthly batches)
2. Preprocess and validate
3. Split: 80% train, 10% val, 10% test
4. Train with cross-validation
5. Evaluate on held-out test set
6. A/B test in production (10% of users)
7. Gradual rollout if successful

---

### 3.3 Model Optimization for Mobile

**Quantization:**
```python
import coremltools as ct

# Convert PyTorch model to Core ML
model_fp32 = torch.load('distilbert_sentiment.pth')
traced_model = torch.jit.trace(model_fp32, example_input)

# Convert to Core ML
mlmodel = ct.convert(
    traced_model,
    inputs=[ct.TensorType(shape=(1, 512), dtype=np.int32)]
)

# Quantize to INT8
mlmodel_int8 = ct.models.neural_network.quantization_utils.quantize_weights(
    mlmodel, nbits=8
)

# Save
mlmodel_int8.save('DistilBERTSentiment_INT8.mlmodel')
```

**Pruning:**
```python
import torch.nn.utils.prune as prune

# Prune 30% of weights
prune.global_unstructured(
    parameters_to_prune,
    pruning_method=prune.L1Unstructured,
    amount=0.3
)

# Fine-tune pruned model
train(pruned_model, epochs=5)
```

---

## 4. AI Pipeline Orchestration

### 4.1 Processing Flow for New Note

```
User creates note (text or voice)
  ↓
[IF VOICE] → Transcription Service (Whisper) → Text
  ↓
Sentiment Analysis Service (DistilBERT) → Emotional State
  ↓
NER Service (BERT-NER) → Entities
  ↓
Entity Resolution → Merge with existing entities
  ↓
[IF VOICE] → Voice Emotion Analysis → Voice Emotion Data
  ↓
Emotion Fusion → Combine text + voice emotions
  ↓
Knowledge Graph Update → Add entities, update relationships
  ↓
Gamification Service → Calculate XP, check achievements
  ↓
Save to Core Data
  ↓
[IF SYNC ENABLED] → Sync Service → CloudKit
```

**Parallel Processing:**
- Sentiment and NER can run in parallel (independent)
- Voice emotion and transcription sequential (need text first)

**Error Handling:**
- Each step isolated: If NER fails, note still saved (just without entities)
- Retry logic for transient failures
- Graceful degradation

---

### 4.2 Batch Processing (Background)

**Use Case:** User hasn't opened app in a while, batch-process notes.

```swift
import BackgroundTasks

class BackgroundProcessor {
    func scheduleBackgroundProcessing() {
        let request = BGProcessingTaskRequest(identifier: "app.noema.ai-processing")
        request.requiresNetworkConnectivity = false
        request.requiresExternalPower = false

        try? BGTaskScheduler.shared.submit(request)
    }

    func handleBackgroundTask(task: BGProcessingTask) {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 2  // Limit to save battery

        // Fetch unprocessed notes
        let unprocessedNotes = fetchUnprocessedNotes()

        for note in unprocessedNotes {
            queue.addOperation {
                self.processNote(note)
            }
        }

        task.expirationHandler = {
            queue.cancelAllOperations()
        }

        queue.waitUntilAllOperationsAreFinished()
        task.setTaskCompleted(success: true)
    }
}
```

---

## 5. Model Performance Monitoring

### 5.1 Metrics to Track

**Accuracy Metrics:**
- Sentiment accuracy: Compare to user corrections
- NER precision/recall: Track entity merge rate
- Transcription WER: Compare to user edits

**Performance Metrics:**
- Inference latency (p50, p95, p99)
- Battery consumption per inference
- Memory usage
- Model load time

**User Engagement:**
- How often do users correct AI outputs?
- Do users trust AI summaries (read full note vs summary)?

---

### 5.2 Continuous Improvement

**User Feedback Loop:**
- Users can "thumbs up/down" AI-generated content
- Corrections logged and used for retraining
- A/B testing of model improvements

**Model Updates:**
- Over-the-air (OTA) model updates via app updates
- Or: On-demand download for large models
- Graceful handling of model version mismatches

---

## 6. Ethical AI Considerations

### 6.1 Bias Mitigation

**Potential Biases:**
- Sentiment models trained on Western data may misinterpret non-Western emotional expression
- NER may perform worse on non-English names

**Mitigation:**
- Diverse training data (multiple cultures, languages)
- Fairness audits: Test on diverse demographic slices
- User feedback: Allow cultural customization

---

### 6.2 Transparency

**Explainability:**
- Show confidence scores for all AI outputs
- Explain why an emotion was detected: "High valence words: 'excited', 'amazing', 'love'"
- Visualize attention weights (which words contributed to sentiment)

**User Control:**
- Users can always override AI decisions
- Disable specific AI features
- Export raw data (not just AI summaries)

---

### 6.3 Crisis Detection Safeguards

**If AI detects suicidal ideation:**
- DO: Show crisis resources (suicide hotline)
- DO: Gentle check-in: "Are you okay? Consider reaching out to a professional."
- DO NOT: Alert authorities without consent
- DO NOT: Break encryption to access notes

**Implementation:**
```swift
func detectCrisisIndicators(text: String) -> CrisisLevel {
    let crisisKeywords = ["suicide", "kill myself", "end it all", "no reason to live"]
    let matches = crisisKeywords.filter { text.lowercased().contains($0) }

    if matches.count > 2 {
        return .high
    } else if matches.count > 0 {
        return .moderate
    } else {
        return .none
    }
}

func handleCrisis(level: CrisisLevel) {
    if level == .high || level == .moderate {
        // Show in-app alert with resources
        showAlert(
            title: "We're here for you",
            message: "If you're in crisis, please reach out:\n\n" +
                     "National Suicide Prevention Lifeline: 988\n" +
                     "Crisis Text Line: Text HOME to 741741",
            actions: [
                .call988,
                .findTherapist,
                .dismiss
            ]
        )
    }
}
```

---

## 7. Future AI Capabilities (Roadmap)

### Year 1
- ✅ On-device transcription, sentiment, NER
- ✅ Voice emotion analysis
- ✅ Basic mood prediction

### Year 2
- Multimodal models: Image + text understanding (photo notes)
- Advanced relationship inference (graph neural networks)
- Personalized writing style analysis ("This doesn't sound like you")

### Year 3
- AI journaling assistant: Socratic questioning for deeper reflection
- Dream analysis (with dream journaling mode)
- Generative AI: "Write a letter to your past/future self"

---

## Summary

Noema's AI/ML pipeline combines:
- **On-Device Intelligence**: Privacy, speed, offline capability
- **Cloud Augmentation**: Advanced features with user consent
- **Continuous Learning**: User feedback improves models
- **Ethical Design**: Transparency, bias mitigation, crisis safeguards

**Performance:**
- <2s transcription per minute
- <100ms sentiment analysis
- <200ms NER
- <5% battery impact per hour of use

**Privacy:**
- 90% of AI processing on-device
- Cloud processing: encrypted, ephemeral, opt-in
- Zero-knowledge architecture

**Next Steps:**
1. Train and optimize on-device models
2. Build Core ML pipeline
3. Implement cloud API for advanced features
4. Continuous evaluation and improvement
