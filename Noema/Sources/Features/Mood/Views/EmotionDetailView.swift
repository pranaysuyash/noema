//
//  EmotionDetailView.swift
//  Noema
//
//  Created on January 19, 2025.
//

import SwiftUI
import Charts

public struct EmotionDetailView: View {
    @ObservedObject var emotion: EmotionalState
    @Environment(\.dismiss) private var dismiss
    @State private var showingRelatedNotes = false

    public init(emotion: EmotionalState) {
        self.emotion = emotion
    }

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Emotion Header
                    EmotionHeaderSection(emotion: emotion)

                    // Core Dimensions
                    CoreDimensionsSection(emotion: emotion)

                    // Additional Metrics
                    AdditionalMetricsSection(emotion: emotion)

                    // Detection Sources
                    DetectionSourcesSection(emotion: emotion)

                    // Voice Characteristics (if available)
                    if emotion.voicePitch > 0 || emotion.voiceEnergy > 0 {
                        VoiceCharacteristicsSection(emotion: emotion)
                    }

                    // Biometrics (if available)
                    if emotion.heartRate > 0 {
                        BiometricsSection(emotion: emotion)
                    }

                    // Context
                    ContextSection(emotion: emotion)

                    // Related Notes
                    RelatedNotesButton(emotion: emotion, showingRelatedNotes: $showingRelatedNotes)
                }
                .padding()
            }
            .background(Color.noemaBackground)
            .navigationTitle("Emotion Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button {
                            // Export emotion data
                        } label: {
                            Label("Export Data", systemImage: "square.and.arrow.up")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .sheet(isPresented: $showingRelatedNotes) {
                RelatedNotesView(emotion: emotion)
            }
        }
    }
}

// MARK: - Supporting Views

private struct EmotionHeaderSection: View {
    @ObservedObject var emotion: EmotionalState

    var body: some View {
        VStack(spacing: 16) {
            // Large emotion circle
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.forEmotion(valence: emotion.valence, arousal: emotion.arousal),
                                Color.forEmotion(valence: emotion.valence, arousal: emotion.arousal).opacity(0.5)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 150, height: 150)
                    .shadow(color: Color.forEmotion(valence: emotion.valence, arousal: emotion.arousal).opacity(0.3), radius: 20)

                VStack(spacing: 8) {
                    Text(emotion.primaryEmotion.icon)
                        .font(.system(size: 60))

                    Text("\(Int(emotion.emotionIntensity * 100))%")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
            }

            // Emotion name and timestamp
            VStack(spacing: 4) {
                Text(emotion.primaryEmotion.displayName)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.noemaTextPrimary)

                Text(emotion.timestamp.formatted(date: .long, time: .shortened))
                    .font(.subheadline)
                    .foregroundColor(.noemaTextSecondary)
            }

            // Secondary emotions
            if !emotion.secondaryEmotions.isEmpty {
                HStack(spacing: 8) {
                    Text("Also feeling:")
                        .font(.caption)
                        .foregroundColor(.noemaTextSecondary)

                    ForEach(emotion.secondaryEmotions, id: \.self) { secondary in
                        Text(secondary.displayName)
                            .font(.caption)
                            .fontWeight(.medium)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(secondary.color.opacity(0.2))
                            .foregroundColor(secondary.color)
                            .cornerRadius(8)
                    }
                }
            }
        }
        .padding()
        .cardStyle()
    }
}

private struct CoreDimensionsSection: View {
    @ObservedObject var emotion: EmotionalState

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Core Dimensions")
                .font(.headline)
                .foregroundColor(.noemaTextPrimary)

            VStack(spacing: 16) {
                DimensionBar(
                    label: "Valence",
                    value: emotion.valence,
                    description: valenceDescription(emotion.valence),
                    color: emotion.valence > 0 ? .joyColor : .sadnessColor,
                    range: (-1, 1)
                )

                DimensionBar(
                    label: "Arousal",
                    value: emotion.arousal,
                    description: arousalDescription(emotion.arousal),
                    color: .excitementColor,
                    range: (-1, 1)
                )

                DimensionBar(
                    label: "Dominance",
                    value: emotion.dominance,
                    description: dominanceDescription(emotion.dominance),
                    color: .noemaPrimary,
                    range: (-1, 1)
                )
            }

            // Circumplex visualization
            CircumplexView(valence: emotion.valence, arousal: emotion.arousal)
                .frame(height: 200)
        }
        .padding()
        .cardStyle()
    }

    private func valenceDescription(_ value: Double) -> String {
        if value > 0.5 { return "Very Positive" }
        else if value > 0 { return "Positive" }
        else if value > -0.5 { return "Negative" }
        else { return "Very Negative" }
    }

    private func arousalDescription(_ value: Double) -> String {
        if value > 0.5 { return "High Energy" }
        else if value > 0 { return "Activated" }
        else if value > -0.5 { return "Calm" }
        else { return "Very Calm" }
    }

    private func dominanceDescription(_ value: Double) -> String {
        if value > 0.5 { return "In Control" }
        else if value > 0 { return "Somewhat in Control" }
        else if value > -0.5 { return "Less Control" }
        else { return "Out of Control" }
    }
}

private struct DimensionBar: View {
    let label: String
    let value: Double
    let description: String
    let color: Color
    let range: (Double, Double)

    private var normalizedValue: Double {
        (value - range.0) / (range.1 - range.0)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(label)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.noemaTextPrimary)

                Spacer()

                Text(description)
                    .font(.caption)
                    .foregroundColor(.noemaTextSecondary)
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 12)
                        .cornerRadius(6)

                    // Filled portion
                    Rectangle()
                        .fill(color)
                        .frame(width: geometry.size.width * normalizedValue, height: 12)
                        .cornerRadius(6)

                    // Value marker
                    Circle()
                        .fill(Color.white)
                        .frame(width: 8, height: 8)
                        .offset(x: geometry.size.width * normalizedValue - 4)
                        .shadow(color: .black.opacity(0.2), radius: 2)
                }
            }
            .frame(height: 12)
        }
    }
}

private struct CircumplexView: View {
    let valence: Double
    let arousal: Double

    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)

            ZStack {
                // Quadrant labels
                Text("High Arousal")
                    .font(.caption2)
                    .foregroundColor(.noemaTextSecondary)
                    .position(x: center.x, y: 20)

                Text("Low Arousal")
                    .font(.caption2)
                    .foregroundColor(.noemaTextSecondary)
                    .position(x: center.x, y: geometry.size.height - 20)

                Text("Negative")
                    .font(.caption2)
                    .foregroundColor(.noemaTextSecondary)
                    .position(x: 20, y: center.y)

                Text("Positive")
                    .font(.caption2)
                    .foregroundColor(.noemaTextSecondary)
                    .position(x: geometry.size.width - 20, y: center.y)

                // Circle background
                Circle()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 2)
                    .frame(width: size * 0.7, height: size * 0.7)
                    .position(center)

                // Axes
                Path { path in
                    path.move(to: CGPoint(x: center.x, y: center.y - size * 0.35))
                    path.addLine(to: CGPoint(x: center.x, y: center.y + size * 0.35))
                }
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)

                Path { path in
                    path.move(to: CGPoint(x: center.x - size * 0.35, y: center.y))
                    path.addLine(to: CGPoint(x: center.x + size * 0.35, y: center.y))
                }
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)

                // Emotion point
                let x = center.x + CGFloat(valence) * size * 0.35
                let y = center.y - CGFloat(arousal) * size * 0.35

                Circle()
                    .fill(Color.forEmotion(valence: valence, arousal: arousal))
                    .frame(width: 20, height: 20)
                    .position(x: x, y: y)
                    .shadow(color: Color.forEmotion(valence: valence, arousal: arousal).opacity(0.5), radius: 10)
            }
        }
        .background(Color.noemaCardBackground)
        .cornerRadius(12)
    }
}

private struct AdditionalMetricsSection: View {
    @ObservedObject var emotion: EmotionalState

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Additional Metrics")
                .font(.headline)
                .foregroundColor(.noemaTextPrimary)

            HStack(spacing: 12) {
                MetricCard(
                    icon: "bolt.fill",
                    label: "Energy",
                    value: "\(Int(emotion.energyLevel * 100))%",
                    color: .xpGold
                )

                MetricCard(
                    icon: "flame.fill",
                    label: "Stress",
                    value: "\(Int(emotion.stressLevel * 100))%",
                    color: .angerColor
                )

                MetricCard(
                    icon: "target",
                    label: "Focus",
                    value: "\(Int(emotion.focusLevel * 100))%",
                    color: .blue
                )
            }
        }
        .padding()
        .cardStyle()
    }
}

private struct MetricCard: View {
    let icon: String
    let label: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)

            Text(value)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.noemaTextPrimary)

            Text(label)
                .font(.caption)
                .foregroundColor(.noemaTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}

private struct DetectionSourcesSection: View {
    @ObservedObject var emotion: EmotionalState

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Detection Sources")
                .font(.headline)
                .foregroundColor(.noemaTextPrimary)

            HStack(spacing: 8) {
                ForEach(emotion.detectionSources, id: \.self) { source in
                    HStack(spacing: 4) {
                        Image(systemName: source.icon)
                            .font(.caption)

                        Text(source.displayName)
                            .font(.caption)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.noemaPrimary.opacity(0.1))
                    .foregroundColor(.noemaPrimary)
                    .cornerRadius(12)
                }
            }

            HStack {
                Image(systemName: "checkmark.seal.fill")
                    .foregroundColor(.green)

                Text("Confidence: \(Int(emotion.confidence * 100))%")
                    .font(.subheadline)
                    .foregroundColor(.noemaTextPrimary)
            }
        }
        .padding()
        .cardStyle()
    }
}

private struct VoiceCharacteristicsSection: View {
    @ObservedObject var emotion: EmotionalState

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Voice Analysis", systemImage: "waveform")
                .font(.headline)
                .foregroundColor(.noemaTextPrimary)

            VStack(spacing: 8) {
                CharacteristicRow(label: "Pitch", value: emotion.voicePitch, unit: "Hz")
                CharacteristicRow(label: "Energy", value: emotion.voiceEnergy, unit: "dB")
                CharacteristicRow(label: "Speaking Rate", value: emotion.speakingRate, unit: "wpm")
                CharacteristicRow(label: "Pause Frequency", value: emotion.pauseFrequency, unit: "/min")
            }
        }
        .padding()
        .cardStyle()
    }
}

private struct CharacteristicRow: View {
    let label: String
    let value: Double
    let unit: String

    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.noemaTextSecondary)

            Spacer()

            Text("\(Int(value)) \(unit)")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.noemaTextPrimary)
        }
    }
}

private struct BiometricsSection: View {
    @ObservedObject var emotion: EmotionalState

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Biometric Data", systemImage: "heart.fill")
                .font(.headline)
                .foregroundColor(.red)

            VStack(spacing: 8) {
                BiometricRow(label: "Heart Rate", value: emotion.heartRate, unit: "bpm")
                BiometricRow(label: "HRV", value: emotion.heartRateVariability, unit: "ms")
            }
        }
        .padding()
        .cardStyle()
    }
}

private struct BiometricRow: View {
    let label: String
    let value: Double
    let unit: String

    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.noemaTextSecondary)

            Spacer()

            Text("\(Int(value)) \(unit)")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.noemaTextPrimary)
        }
    }
}

private struct ContextSection: View {
    @ObservedObject var emotion: EmotionalState

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Context")
                .font(.headline)
                .foregroundColor(.noemaTextPrimary)

            if let trigger = emotion.trigger, !trigger.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Trigger")
                        .font(.caption)
                        .foregroundColor(.noemaTextSecondary)

                    Text(trigger)
                        .font(.subheadline)
                        .foregroundColor(.noemaTextPrimary)
                }
            } else {
                Text("No context information available")
                    .font(.subheadline)
                    .foregroundColor(.noemaTextSecondary)
                    .italic()
            }
        }
        .padding()
        .cardStyle()
    }
}

private struct RelatedNotesButton: View {
    @ObservedObject var emotion: EmotionalState
    @Binding var showingRelatedNotes: Bool

    var body: some View {
        Button {
            showingRelatedNotes = true
        } label: {
            HStack {
                Image(systemName: "note.text")
                    .font(.title3)

                VStack(alignment: .leading, spacing: 4) {
                    Text("View Related Note")
                        .font(.subheadline)
                        .fontWeight(.medium)

                    Text("See the full context")
                        .font(.caption)
                        .foregroundColor(.noemaTextSecondary.opacity(0.8))
                }

                Spacer()

                Image(systemName: "chevron.right")
            }
            .foregroundColor(.noemaPrimary)
            .padding()
            .cardStyle()
        }
    }
}

private struct RelatedNotesView: View {
    @ObservedObject var emotion: EmotionalState
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack {
                if let note = emotion.note {
                    NoteDetailView(note: note)
                } else {
                    Text("No related note")
                        .foregroundColor(.noemaTextSecondary)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Supporting Extensions

extension DetectionSource {
    var displayName: String {
        switch self {
        case .text: return "Text"
        case .voice: return "Voice"
        case .biometric: return "Biometric"
        case .user: return "User"
        case .ai: return "AI"
        }
    }

    var icon: String {
        switch self {
        case .text: return "text.bubble"
        case .voice: return "waveform"
        case .biometric: return "heart.fill"
        case .user: return "person.fill"
        case .ai: return "sparkles"
        }
    }
}

#Preview {
    let emotion = EmotionalState()
    emotion.primaryEmotion = .joy
    emotion.valence = 0.7
    emotion.arousal = 0.5
    emotion.dominance = 0.6
    emotion.emotionIntensity = 0.8
    return EmotionDetailView(emotion: emotion)
}
