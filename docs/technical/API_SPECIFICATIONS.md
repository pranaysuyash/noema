# Noema API Specifications
## RESTful API & Internal Service Architecture

---

## Overview

Noema's API architecture consists of:
1. **Internal Swift Services**: On-device processing (Core ML, local data)
2. **Cloud REST API**: Optional cloud-based AI features (user opt-in)
3. **CloudKit Sync**: Apple's sync infrastructure for data persistence
4. **Third-Party Integrations**: HealthKit, WeatherKit, location services

**API Design Principles:**
- **Privacy-First**: Minimal data transmission, encryption by default
- **Offline-First**: All core features work without internet
- **Idempotent**: Safe to retry operations
- **Versioned**: Support backward compatibility

---

## 1. Internal Swift Services API

### 1.1 NoteService

Manages note creation, retrieval, and updates.

```swift
protocol NoteServiceProtocol {
    /// Create a new text note
    func createTextNote(content: String, tags: [String]?) async throws -> Note

    /// Create a new voice note with audio recording
    func createVoiceNote(audioURL: URL, tags: [String]?) async throws -> Note

    /// Transcribe an audio note
    func transcribeNote(_ note: Note) async throws -> Note

    /// Generate AI summary for a note
    func summarizeNote(_ note: Note, detailLevel: SummaryDetailLevel) async throws -> String

    /// Analyze sentiment and extract emotions
    func analyzeEmotion(for note: Note) async throws -> EmotionalState

    /// Extract named entities from note
    func extractEntities(from note: Note) async throws -> [Entity]

    /// Update note content
    func updateNote(_ note: Note, content: String) async throws -> Note

    /// Delete note (soft delete)
    func deleteNote(_ note: Note) async throws

    /// Search notes
    func searchNotes(query: String, filters: NoteFilters?) async throws -> [Note]

    /// Get related notes
    func getRelatedNotes(for note: Note, limit: Int) async throws -> [Note]
}

enum SummaryDetailLevel {
    case brief       // 1-2 sentences
    case standard    // 3-5 sentences
    case detailed    // Full paragraph
}

struct NoteFilters {
    var dateRange: ClosedRange<Date>?
    var tags: [String]?
    var emotions: [EmotionType]?
    var entities: [UUID]?  // Entity IDs
    var minValence: Double?
    var maxValence: Double?
    var minEnergy: Double?
    var hasAudio: Bool?
}
```

---

### 1.2 EntityService

Manages entity detection, linking, and knowledge graph operations.

```swift
protocol EntityServiceProtocol {
    /// Extract entities from text
    func extractEntities(from text: String) async throws -> [DetectedEntity]

    /// Create or update entity in database
    func upsertEntity(name: String, type: EntityType, aliases: [String]?) async throws -> Entity

    /// Get entity by ID
    func getEntity(id: UUID) async throws -> Entity?

    /// Get entity by name (fuzzy matching)
    func findEntity(byName name: String) async throws -> Entity?

    /// Get all mentions of an entity
    func getMentions(for entity: Entity) async throws -> [EntityMention]

    /// Get emotional timeline for entity
    func getEmotionalTimeline(for entity: Entity, dateRange: ClosedRange<Date>?) async throws -> [EmotionalDataPoint]

    /// Get related entities (co-occurrences)
    func getRelatedEntities(for entity: Entity, minCoOccurrences: Int) async throws -> [Entity]

    /// Calculate relationship strength between two entities
    func calculateRelationshipStrength(entity1: Entity, entity2: Entity) async throws -> Double

    /// Merge duplicate entities
    func mergeEntities(source: Entity, into target: Entity) async throws
}

struct DetectedEntity {
    var text: String
    var type: EntityType
    var range: Range<String.Index>
    var confidence: Double
}

struct EmotionalDataPoint {
    var timestamp: Date
    var valence: Double
    var arousal: Double
    var energy: Double
    var note: Note
}
```

---

### 1.3 KnowledgeGraphService

Manages the emotional knowledge graph.

```swift
protocol KnowledgeGraphServiceProtocol {
    /// Build or update knowledge graph
    func buildGraph() async throws -> KnowledgeGraph

    /// Get subgraph around an entity
    func getSubgraph(centeredOn entity: Entity, depth: Int) async throws -> KnowledgeGraph

    /// Calculate centrality scores for all entities
    func calculateCentrality() async throws -> [UUID: Double]

    /// Detect communities (clusters) in the graph
    func detectCommunities() async throws -> [Community]

    /// Find shortest path between two entities
    func findPath(from: Entity, to: Entity) async throws -> [Entity]?

    /// Get temporal graph evolution
    func getGraphEvolution(dateRange: ClosedRange<Date>) async throws -> [GraphSnapshot]

    /// Export graph to visualization format
    func exportGraph(format: GraphExportFormat) async throws -> Data
}

struct KnowledgeGraph {
    var nodes: [GraphNode]
    var edges: [GraphEdge]
}

struct GraphNode {
    var id: UUID
    var entity: Entity
    var centrality: Double
    var emotionalValence: Double
}

struct GraphEdge {
    var source: UUID
    var target: UUID
    var weight: Double  // Relationship strength
    var emotionalTone: Double
    var coOccurrences: Int
}

struct Community {
    var id: UUID
    var members: [Entity]
    var theme: String?  // AI-generated theme
    var cohesion: Double
}

struct GraphSnapshot {
    var date: Date
    var graph: KnowledgeGraph
}

enum GraphExportFormat {
    case json
    case graphml
    case gexf
}
```

---

### 1.4 EmotionAnalysisService

Performs emotion detection and analysis.

```swift
protocol EmotionAnalysisServiceProtocol {
    /// Analyze emotion from text
    func analyzeTextEmotion(text: String) async throws -> EmotionalState

    /// Analyze emotion from voice (audio characteristics)
    func analyzeVoiceEmotion(audioURL: URL) async throws -> VoiceEmotionData

    /// Combine multi-modal emotion signals
    func combineEmotionSignals(text: EmotionalState?, voice: VoiceEmotionData?, biometric: BiometricData?) async throws -> EmotionalState

    /// Get emotional patterns over time
    func getEmotionalPatterns(dateRange: ClosedRange<Date>) async throws -> EmotionalPatterns

    /// Predict mood based on context
    func predictMood(context: MoodContext) async throws -> EmotionalStatePrediction

    /// Detect emotional anomalies
    func detectAnomalies(threshold: Double) async throws -> [EmotionalAnomaly]

    /// Generate insights from emotional data
    func generateInsights() async throws -> [EmotionalInsight]
}

struct VoiceEmotionData {
    var pitch: Double
    var pitchVariability: Double
    var energy: Double
    var speakingRate: Double
    var pauseFrequency: Double
    var detectedEmotion: EmotionType
    var confidence: Double
}

struct BiometricData {
    var heartRate: Double?
    var heartRateVariability: Double?
    var sleepQuality: Double?
    var activityLevel: Double?
}

struct EmotionalPatterns {
    var timeOfDayPattern: [TimeOfDay: Double]  // Average valence per time slot
    var dayOfWeekPattern: [Int: Double]        // 0 = Sunday
    var seasonalPattern: [Season: Double]
    var circadianRhythm: CircadianPattern
}

struct CircadianPattern {
    var peakEnergyTime: Date
    var lowEnergyTime: Date
    var moodAmplitude: Double
}

struct MoodContext {
    var time: Date
    var location: Location?
    var weather: WeatherSnapshot?
    var calendarEvents: [CalendarEvent]?
    var recentSleep: Double?
    var recentExercise: Double?
}

struct EmotionalStatePrediction {
    var predictedState: EmotionalState
    var confidence: Double
    var reasoning: String
}

struct EmotionalAnomaly {
    var timestamp: Date
    var state: EmotionalState
    var deviationScore: Double
    var type: AnomalyType
}

enum AnomalyType {
    case unusuallyPositive
    case unusuallyNegative
    case rapidChange
    case prolongedExtreme
}

struct EmotionalInsight {
    var title: String
    var description: String
    var type: InsightType
    var impact: InsightImpact
    var relatedEntities: [Entity]?
    var actionableAdvice: String?
}

enum InsightType {
    case pattern
    case correlation
    case achievement
    case warning
    case opportunity
}

enum InsightImpact {
    case low
    case medium
    case high
}
```

---

### 1.5 GamificationService

Manages achievements, quests, and progression.

```swift
protocol GamificationServiceProtocol {
    /// Calculate XP for a note
    func calculateXP(for note: Note) async throws -> Int

    /// Award XP to user
    func awardXP(amount: Int) async throws

    /// Check for unlocked achievements
    func checkAchievements() async throws -> [Achievement]

    /// Update streak status
    func updateStreak() async throws -> StreakStatus

    /// Generate personalized quest
    func generateQuest(based on: UserProfile) async throws -> Quest

    /// Mark quest as completed
    func completeQuest(_ quest: Quest) async throws

    /// Get garden state
    func getGardenState() async throws -> GardenState

    /// Update garden based on activity
    func updateGarden(activity: GardenActivity) async throws -> GardenState

    /// Get leaderboard (community feature, opt-in)
    func getLeaderboard(scope: LeaderboardScope) async throws -> [LeaderboardEntry]
}

struct StreakStatus {
    var currentStreak: Int
    var longestStreak: Int
    var streakFreezes: Int
    var nextMilestone: Int
}

enum GardenActivity {
    case noteCreated(quality: Double)
    case insightGained
    case streakMilestone
    case achievementUnlocked
}

enum LeaderboardScope {
    case global
    case friends
    case local  // Same geographic region
}

struct LeaderboardEntry {
    var rank: Int
    var username: String  // Anonymized
    var level: Int
    var totalXP: Int
}
```

---

### 1.6 SyncService

Manages CloudKit synchronization.

```swift
protocol SyncServiceProtocol {
    /// Start sync process
    func sync() async throws

    /// Upload changes to cloud
    func uploadChanges() async throws

    /// Download remote changes
    func downloadChanges() async throws

    /// Resolve sync conflicts
    func resolveConflicts() async throws

    /// Get sync status
    func getSyncStatus() async throws -> SyncStatus

    /// Enable/disable sync for specific note
    func setSyncEnabled(for note: Note, enabled: Bool) async throws
}

enum SyncStatusValue {
    case synced
    case syncPending
    case syncing
    case syncFailed(Error)
    case offline
}

struct SyncStatus {
    var status: SyncStatusValue
    var lastSync: Date?
    var pendingUploadCount: Int
    var pendingDownloadCount: Int
}
```

---

## 2. Cloud REST API (Optional, User Opt-In)

**Base URL:** `https://api.noema.app/v1`

**Authentication:** Bearer token (JWT)

**Headers:**
```
Authorization: Bearer {jwt_token}
Content-Type: application/json
X-API-Version: 1.0
X-Device-ID: {unique_device_id}
```

---

### 2.1 Advanced Summarization

**POST /notes/{note_id}/summarize**

Generate advanced AI summary using cloud models (GPT-4 or Claude).

**Request:**
```json
{
  "encrypted_content": "base64_encrypted_note_content",
  "detail_level": "detailed",
  "style": "conversational",
  "focus": "insights"  // or "facts", "emotions"
}
```

**Response:**
```json
{
  "summary": "AI-generated summary...",
  "key_points": ["point 1", "point 2"],
  "processing_time_ms": 1250
}
```

**Privacy Note:**
- Content encrypted client-side before transmission
- Server decrypts only for processing (ephemeral)
- Summary returned, content not stored

---

### 2.2 Advanced Insights

**POST /insights/generate**

Generate deep insights using cloud AI.

**Request:**
```json
{
  "encrypted_notes": ["base64_note1", "base64_note2"],
  "date_range": {
    "start": "2025-01-01T00:00:00Z",
    "end": "2025-01-31T23:59:59Z"
  },
  "insight_types": ["patterns", "correlations", "recommendations"]
}
```

**Response:**
```json
{
  "insights": [
    {
      "type": "pattern",
      "title": "Creative Peak Times",
      "description": "You're most creative on Tuesday evenings between 8-10 PM",
      "confidence": 0.87,
      "supporting_data": {
        "sample_count": 15,
        "average_creativity_score": 0.82
      }
    }
  ]
}
```

---

### 2.3 Knowledge Graph Reasoning

**POST /knowledge-graph/infer**

Use cloud-based graph neural networks for advanced relationship inference.

**Request:**
```json
{
  "encrypted_graph": "base64_graph_data",
  "query_type": "recommend_reconnections",
  "parameters": {
    "min_importance": 0.6,
    "days_since_contact": 30
  }
}
```

**Response:**
```json
{
  "recommendations": [
    {
      "entity_id": "uuid-1234",
      "entity_name": "Sarah",
      "reason": "High emotional impact, no mention in 45 days",
      "priority": 0.92
    }
  ]
}
```

---

### 2.4 Wellness Report

**GET /reports/wellness?period=monthly**

Generate comprehensive wellness report.

**Response:**
```json
{
  "period": "2025-01",
  "summary": {
    "average_valence": 0.62,
    "mood_variance": 0.23,
    "energy_trend": "increasing",
    "stress_level": "moderate"
  },
  "highlights": [
    "15% improvement in emotional balance",
    "Identified 3 new stress triggers",
    "Peak creativity: Tuesday evenings"
  ],
  "recommendations": [
    "Consider morning exercise to boost energy",
    "Reconnect with Sarah - historically positive influence"
  ],
  "charts": {
    "mood_timeline": "base64_chart_image",
    "entity_emotional_map": "base64_chart_image"
  }
}
```

---

## 3. Third-Party Integrations

### 3.1 HealthKit Integration

```swift
import HealthKit

class HealthKitService {
    func requestAuthorization() async throws
    func fetchSleepData(dateRange: ClosedRange<Date>) async throws -> [HKSleepAnalysis]
    func fetchActivityData(dateRange: ClosedRange<Date>) async throws -> ActivityData
    func fetchHeartRateData(dateRange: ClosedRange<Date>) async throws -> [HeartRateDataPoint]

    func correlateWithMood() async throws -> [HealthMoodCorrelation]
}

struct ActivityData {
    var steps: Int
    var activeEnergyBurned: Double
    var exerciseMinutes: Int
    var standHours: Int
}

struct HeartRateDataPoint {
    var timestamp: Date
    var bpm: Int
    var context: HKHeartRateMotionContext?
}

struct HealthMoodCorrelation {
    var metricType: HealthMetricType
    var correlationCoefficient: Double
    var insight: String
}
```

---

### 3.2 WeatherKit Integration

```swift
import WeatherKit

class WeatherService {
    func getCurrentWeather(location: CLLocation) async throws -> WeatherSnapshot
    func getHistoricalWeather(location: CLLocation, date: Date) async throws -> WeatherSnapshot

    func analyzeWeatherImpact() async throws -> [WeatherMoodCorrelation]
}

struct WeatherMoodCorrelation {
    var weatherCondition: WeatherCondition
    var averageMoodImpact: Double
    var sampleCount: Int
    var significance: StatisticalSignificance
}

enum StatisticalSignificance {
    case notSignificant
    case weaklySignificant
    case significant
    case highlySignificant
}
```

---

### 3.3 Calendar Integration

```swift
import EventKit

class CalendarService {
    func requestAccess() async throws
    func getUpcomingEvents(days: Int) async throws -> [CalendarEvent]

    func analyzeEventMoodImpact() async throws -> [EventMoodCorrelation]
}

struct CalendarEvent {
    var title: String
    var startDate: Date
    var endDate: Date
    var location: String?
    var attendees: [String]?
}

struct EventMoodCorrelation {
    var eventType: String  // Meeting, social, workout, etc.
    var preMoodAverage: Double
    var postMoodAverage: Double
    var moodChange: Double
}
```

---

## 4. Error Handling

### Error Codes

```swift
enum NoemaAPIError: Error {
    // Client Errors (400-499)
    case invalidRequest(message: String)
    case unauthorized
    case forbidden
    case notFound(resource: String)
    case rateLimitExceeded
    case subscriptionRequired

    // Server Errors (500-599)
    case internalServerError
    case serviceUnavailable
    case aiProcessingFailed

    // Network Errors
    case networkUnavailable
    case requestTimeout

    // Data Errors
    case corruptedData
    case encryptionFailed
    case decryptionFailed
}

struct APIErrorResponse: Codable {
    var error: String
    var message: String
    var code: Int
    var requestId: String
    var retryAfter: Int?  // Seconds
}
```

---

## 5. Rate Limiting

**Free Tier:**
- 30 minutes transcription/month
- 100 API calls/day (cloud features)
- 10 advanced summaries/month

**Pro Tier:**
- Unlimited transcription
- 10,000 API calls/day
- Unlimited advanced summaries

**Rate Limit Headers:**
```
X-RateLimit-Limit: 10000
X-RateLimit-Remaining: 9847
X-RateLimit-Reset: 1640995200  // Unix timestamp
```

---

## 6. Webhook Events (Future)

For third-party integrations and automation.

### Event Types

- `note.created`
- `note.updated`
- `achievement.unlocked`
- `insight.generated`
- `streak.milestone`

### Webhook Payload

```json
{
  "event_type": "achievement.unlocked",
  "timestamp": "2025-01-15T14:30:00Z",
  "user_id": "encrypted_user_id",
  "data": {
    "achievement_id": "uuid",
    "achievement_type": "streak30Days",
    "title": "Monthly Master"
  }
}
```

---

## 7. API Versioning

**Strategy:** URL-based versioning

- `/v1/notes` (current)
- `/v2/notes` (future)

**Deprecation Policy:**
- New versions announced 3 months in advance
- Old versions supported for 12 months after deprecation
- Gradual migration path provided

---

## 8. Performance & SLAs

**Target Latencies:**
- On-device processing: <100ms (sentiment), <2s (transcription per minute)
- Cloud API: p95 <500ms, p99 <1000ms
- Sync: <5 seconds for incremental sync

**Availability:**
- Cloud API: 99.9% uptime
- Sync service: 99.95% uptime
- Graceful degradation: App remains functional offline

---

## Summary

Noema's API architecture prioritizes:
- **Privacy**: Encryption, minimal cloud transmission
- **Performance**: On-device processing, efficient cloud APIs
- **Reliability**: Offline-first, robust error handling
- **Scalability**: Rate limiting, efficient sync
- **Extensibility**: Versioned APIs, webhook support

**Next Steps:**
1. Implement Swift service protocols
2. Build cloud API backend (consider Vapor or Nest.js)
3. Set up CloudKit schema
4. Integrate HealthKit, WeatherKit
5. Performance testing and optimization
