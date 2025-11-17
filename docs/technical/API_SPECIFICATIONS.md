# noema: API Specifications

## Version 1.0 | Last Updated: 2025-11-17

## Table of Contents
1. [API Overview](#api-overview)
2. [Authentication](#authentication)
3. [Cloud Sync API](#cloud-sync-api)
4. [AI Processing API](#ai-processing-api)
5. [Analytics API](#analytics-api)
6. [Error Handling](#error-handling)
7. [Rate Limiting](#rate-limiting)
8. [Webhooks](#webhooks)

---

## 1. API Overview

### Base URLs

```
Production:  https://api.noema.app/v1
Staging:     https://staging-api.noema.app/v1
Development: http://localhost:3000/v1
```

### API Principles

- **REST-ful**: Standard HTTP methods (GET, POST, PUT, DELETE)
- **JSON**: All requests and responses use JSON
- **Versioning**: API version in URL path (`/v1/`)
- **HTTPS Only**: All production traffic over TLS 1.3
- **Authentication**: Bearer token (JWT) in Authorization header

### Common Headers

```http
Authorization: Bearer <jwt_token>
Content-Type: application/json
Accept: application/json
X-Client-Version: 1.0.0
X-Platform: iOS
```

---

## 2. Authentication

### 2.1 Sign In with Apple

**Endpoint:** `POST /auth/apple`

**Request:**
```json
{
  "identityToken": "eyJraWQ...",
  "authorizationCode": "c1a2b3...",
  "user": {
    "email": "[email protected]",
    "firstName": "John",
    "lastName": "Doe"
  }
}
```

**Response:** `200 OK`
```json
{
  "accessToken": "eyJhbGc...",
  "refreshToken": "eyJhbGc...",
  "expiresIn": 3600,
  "user": {
    "id": "usr_1a2b3c4d",
    "email": "[email protected]",
    "displayName": "John Doe",
    "createdAt": "2025-01-15T10:30:00Z"
  }
}
```

### 2.2 Refresh Token

**Endpoint:** `POST /auth/refresh`

**Request:**
```json
{
  "refreshToken": "eyJhbGc..."
}
```

**Response:** `200 OK`
```json
{
  "accessToken": "eyJhbGc...",
  "expiresIn": 3600
}
```

### 2.3 Logout

**Endpoint:** `POST /auth/logout`

**Headers:** `Authorization: Bearer <accessToken>`

**Response:** `204 No Content`

---

## 3. Cloud Sync API

### 3.1 Sync Notes

**Endpoint:** `POST /sync/notes`

**Request:**
```json
{
  "notes": [
    {
      "id": "note_1a2b3c",
      "encryptedContent": "AES256_ENCRYPTED_BLOB",
      "iv": "RANDOM_IV",
      "tag": "GCM_TAG",
      "createdAt": "2025-01-15T10:30:00Z",
      "modifiedAt": "2025-01-15T11:00:00Z",
      "version": 2
    }
  ],
  "lastSyncToken": "sync_token_xyz"
}
```

**Response:** `200 OK`
```json
{
  "syncedNotes": ["note_1a2b3c"],
  "conflicts": [],
  "newSyncToken": "sync_token_abc",
  "serverChanges": [
    {
      "id": "note_4d5e6f",
      "encryptedContent": "...",
      "iv": "...",
      "tag": "...",
      "createdAt": "2025-01-15T09:00:00Z",
      "modifiedAt": "2025-01-15T09:30:00Z",
      "version": 1
    }
  ]
}
```

### 3.2 Delete Note

**Endpoint:** `DELETE /sync/notes/:noteId`

**Response:** `204 No Content`

### 3.3 Get Sync Status

**Endpoint:** `GET /sync/status`

**Response:** `200 OK`
```json
{
  "lastSyncAt": "2025-01-15T11:00:00Z",
  "pendingChanges": 5,
  "syncToken": "sync_token_abc"
}
```

---

## 4. AI Processing API

### 4.1 Analyze Text (Cloud AI)

**Endpoint:** `POST /ai/analyze`

**Request:**
```json
{
  "text": "Had a great conversation with Sarah about the new project.",
  "features": ["emotion", "entities", "summary"],
  "language": "en"
}
```

**Response:** `200 OK`
```json
{
  "emotion": {
    "dimensions": {
      "joy": 0.85,
      "sadness": 0.05,
      "anger": 0.0,
      "fear": 0.0,
      "surprise": 0.2,
      "disgust": 0.0,
      "trust": 0.7,
      "anticipation": 0.3
    },
    "dominantEmotion": "joy",
    "confidence": 0.92
  },
  "entities": [
    {
      "text": "Sarah",
      "type": "person",
      "confidence": 0.95,
      "startIndex": 26,
      "endIndex": 31
    }
  ],
  "summary": "Productive discussion with Sarah about project engagement strategies",
  "language": "en",
  "processingTime": 450
}
```

### 4.2 Transcribe Audio (Cloud AI)

**Endpoint:** `POST /ai/transcribe`

**Content-Type:** `multipart/form-data`

**Request:**
```
audio: <audio_file.m4a>
language: en (optional)
enableDiarization: true (optional)
```

**Response:** `200 OK`
```json
{
  "text": "Full transcribed text...",
  "segments": [
    {
      "text": "Segment text",
      "startTime": 0.0,
      "endTime": 3.5,
      "confidence": 0.96,
      "speakerID": 1
    }
  ],
  "language": "en",
  "duration": 12.5,
  "averageConfidence": 0.94
}
```

### 4.3 Generate Insights

**Endpoint:** `POST /ai/insights`

**Request:**
```json
{
  "noteIds": ["note_1", "note_2", "note_3"],
  "dateRange": {
    "start": "2025-01-01T00:00:00Z",
    "end": "2025-01-15T23:59:59Z"
  },
  "insightTypes": ["mood_patterns", "productivity_trends", "wellness_score"]
}
```

**Response:** `200 OK`
```json
{
  "insights": [
    {
      "type": "mood_patterns",
      "title": "Your Best Creative Times",
      "description": "You're most creative when feeling joyful, typically mornings",
      "confidence": 0.88,
      "data": {
        "correlations": [
          {
            "mood": "joy",
            "activity": "creative_work",
            "correlation": 0.76
          }
        ]
      }
    }
  ],
  "wellnessScore": 78,
  "generatedAt": "2025-01-15T12:00:00Z"
}
```

---

## 5. Analytics API

### 5.1 Track Event

**Endpoint:** `POST /analytics/events`

**Request:**
```json
{
  "events": [
    {
      "name": "note_created",
      "properties": {
        "noteType": "text",
        "wordCount": 150,
        "hasMood": true,
        "hasAudio": false
      },
      "timestamp": "2025-01-15T10:30:00Z",
      "sessionId": "session_abc123"
    }
  ]
}
```

**Response:** `202 Accepted`

### 5.2 Get User Analytics

**Endpoint:** `GET /analytics/user`

**Query Parameters:**
- `start`: ISO 8601 date (required)
- `end`: ISO 8601 date (required)
- `metrics`: Comma-separated list (optional)

**Response:** `200 OK`
```json
{
  "period": {
    "start": "2025-01-01T00:00:00Z",
    "end": "2025-01-15T23:59:59Z"
  },
  "metrics": {
    "notesCreated": 45,
    "moodsLogged": 52,
    "streakDays": 12,
    "achievementsUnlocked": 3,
    "averageSessionDuration": 480
  }
}
```

---

## 6. Error Handling

### Standard Error Response

```json
{
  "error": {
    "code": "INVALID_REQUEST",
    "message": "Request validation failed",
    "details": [
      {
        "field": "email",
        "message": "Invalid email format"
      }
    ],
    "requestId": "req_1a2b3c4d"
  }
}
```

### Error Codes

| Code | HTTP Status | Description |
|------|------------|-------------|
| `INVALID_REQUEST` | 400 | Request validation failed |
| `UNAUTHORIZED` | 401 | Invalid or expired token |
| `FORBIDDEN` | 403 | Insufficient permissions |
| `NOT_FOUND` | 404 | Resource not found |
| `CONFLICT` | 409 | Resource conflict (e.g., duplicate) |
| `RATE_LIMITED` | 429 | Too many requests |
| `SERVER_ERROR` | 500 | Internal server error |
| `SERVICE_UNAVAILABLE` | 503 | Service temporarily unavailable |

---

## 7. Rate Limiting

### Limits by Tier

| Tier | Requests/Minute | Requests/Hour | Requests/Day |
|------|----------------|---------------|--------------|
| Free | 10 | 100 | 1,000 |
| Pro | 60 | 1,000 | 10,000 |
| Family | 100 | 2,000 | 20,000 |

### Rate Limit Headers

```http
X-RateLimit-Limit: 60
X-RateLimit-Remaining: 45
X-RateLimit-Reset: 1642245600
```

### Rate Limit Exceeded Response

```json
{
  "error": {
    "code": "RATE_LIMITED",
    "message": "Rate limit exceeded",
    "retryAfter": 30
  }
}
```

---

## 8. Webhooks

### 8.1 Webhook Configuration

**Endpoint:** `POST /webhooks`

**Request:**
```json
{
  "url": "https://your-server.com/webhooks/noema",
  "events": ["note.created", "achievement.unlocked"],
  "secret": "your_webhook_secret"
}
```

**Response:** `201 Created`
```json
{
  "id": "webhook_abc123",
  "url": "https://your-server.com/webhooks/noema",
  "events": ["note.created", "achievement.unlocked"],
  "createdAt": "2025-01-15T10:30:00Z"
}
```

### 8.2 Webhook Payload

**Headers:**
```http
Content-Type: application/json
X-Noema-Signature: sha256=...
X-Noema-Event: note.created
```

**Payload:**
```json
{
  "id": "evt_1a2b3c",
  "type": "note.created",
  "createdAt": "2025-01-15T10:30:00Z",
  "data": {
    "noteId": "note_abc123",
    "userId": "usr_xyz789"
  }
}
```

### 8.3 Webhook Signature Verification

```python
import hmac
import hashlib

def verify_webhook(payload, signature, secret):
    expected = hmac.new(
        secret.encode(),
        payload.encode(),
        hashlib.sha256
    ).hexdigest()
    return hmac.compare_digest(f"sha256={expected}", signature)
```

---

## Appendix A: API Client Example (Swift)

```swift
import Foundation

actor NoemaAPIClient {
    private let baseURL = URL(string: "https://api.noema.app/v1")!
    private let session: URLSession
    private var accessToken: String?

    init(session: URLSession = .shared) {
        self.session = session
    }

    func analyzeText(_ text: String) async throws -> EmotionAnalysisResponse {
        let endpoint = baseURL.appendingPathComponent("ai/analyze")

        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(accessToken ?? "")", forHTTPHeaderField: "Authorization")

        let body = AnalyzeRequest(
            text: text,
            features: ["emotion", "entities", "summary"],
            language: "en"
        )
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw APIError.requestFailed
        }

        return try JSONDecoder().decode(EmotionAnalysisResponse.self, from: data)
    }
}
```

---

## Document Control

**Version:** 1.0
**Last Updated:** 2025-11-17
**Status:** Preliminary Specification

**Review Schedule:** Quarterly or before major API changes

**Approval:**
- Engineering Lead: [Pending]
- Backend Team: [Pending]

---

*This API specification will evolve as noema develops. All breaking changes will be versioned.*
