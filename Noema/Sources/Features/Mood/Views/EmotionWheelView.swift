//
//  EmotionWheelView.swift
//  Noema
//
//  Created on January 19, 2025.
//

import SwiftUI

public struct EmotionWheelView: View {
    @State private var selectedEmotion: EmotionType?
    @State private var intensity: Double = 0.5
    @Environment(\.dismiss) private var dismiss
    let onSelection: ((EmotionType, Double) -> Void)?

    public init(onSelection: ((EmotionType, Double) -> Void)? = nil) {
        self.onSelection = onSelection
    }

    public var body: some View {
        NavigationStack {
            ZStack {
                Color.noemaBackground.ignoresSafeArea()

                VStack(spacing: 32) {
                    // Title
                    VStack(spacing: 8) {
                        Text("How are you feeling?")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.noemaTextPrimary)

                        if let emotion = selectedEmotion {
                            Text(emotion.displayName)
                                .font(.title3)
                                .foregroundColor(.noemaTextSecondary)
                        } else {
                            Text("Select an emotion")
                                .font(.subheadline)
                                .foregroundColor(.noemaTextSecondary)
                        }
                    }

                    // Emotion Wheel
                    EmotionWheelCircle(selectedEmotion: $selectedEmotion)
                        .frame(width: 300, height: 300)

                    // Intensity Slider
                    if selectedEmotion != nil {
                        VStack(spacing: 12) {
                            Text("Intensity")
                                .font(.headline)
                                .foregroundColor(.noemaTextPrimary)

                            HStack(spacing: 16) {
                                Text("Mild")
                                    .font(.caption)
                                    .foregroundColor(.noemaTextSecondary)

                                Slider(value: $intensity, in: 0...1)
                                    .tint(.noemaPrimary)

                                Text("Intense")
                                    .font(.caption)
                                    .foregroundColor(.noemaTextSecondary)
                            }

                            Text("\(Int(intensity * 100))%")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.noemaTextPrimary)
                        }
                        .padding()
                        .cardStyle()
                    }

                    Spacer()

                    // Save Button
                    if let emotion = selectedEmotion {
                        Button {
                            onSelection?(emotion, intensity)
                            dismiss()
                        } label: {
                            Text("Save Emotion")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.noemaPrimary)
                                .cornerRadius(12)
                        }
                        .padding(.horizontal)
                    }
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Emotion Wheel Circle

private struct EmotionWheelCircle: View {
    @Binding var selectedEmotion: EmotionType?

    private let emotions: [EmotionWheelSegment] = [
        EmotionWheelSegment(emotion: .joy, angle: 0, color: .joyColor),
        EmotionWheelSegment(emotion: .excitement, angle: 45, color: .excitementColor),
        EmotionWheelSegment(emotion: .surprise, angle: 90, color: .orange),
        EmotionWheelSegment(emotion: .fear, angle: 135, color: .fearColor),
        EmotionWheelSegment(emotion: .sadness, angle: 180, color: .sadnessColor),
        EmotionWheelSegment(emotion: .disgust, angle: 225, color: .green),
        EmotionWheelSegment(emotion: .anger, angle: 270, color: .angerColor),
        EmotionWheelSegment(emotion: .contentment, angle: 315, color: .contentmentColor),
    ]

    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .fill(Color.noemaCardBackground)

            // Emotion segments
            ForEach(emotions) { segment in
                EmotionSegmentView(
                    segment: segment,
                    isSelected: selectedEmotion == segment.emotion
                )
                .onTapGesture {
                    withAnimation(.spring()) {
                        selectedEmotion = segment.emotion
                    }
                    let generator = UIImpactFeedbackGenerator(style: .medium)
                    generator.impactOccurred()
                }
            }

            // Center circle
            Circle()
                .fill(Color.noemaBackground)
                .frame(width: 100, height: 100)

            // Selected emotion indicator
            if let emotion = selectedEmotion {
                VStack(spacing: 4) {
                    Image(systemName: emotion.icon)
                        .font(.title)
                        .foregroundColor(emotion.color)

                    Text(emotion.displayName)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.noemaTextPrimary)
                }
            } else {
                Image(systemName: "face.smiling")
                    .font(.largeTitle)
                    .foregroundColor(.noemaTextSecondary.opacity(0.5))
            }
        }
    }
}

private struct EmotionSegmentView: View {
    let segment: EmotionWheelSegment
    let isSelected: Bool

    var body: some View {
        GeometryReader { geometry in
            let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
            let radius = min(geometry.size.width, geometry.size.height) / 2
            let innerRadius = radius * 0.4

            Path { path in
                let startAngle = Angle(degrees: Double(segment.angle) - 22.5)
                let endAngle = Angle(degrees: Double(segment.angle) + 22.5)

                path.addArc(
                    center: center,
                    radius: radius,
                    startAngle: startAngle,
                    endAngle: endAngle,
                    clockwise: false
                )

                path.addLine(to: CGPoint(
                    x: center.x + innerRadius * cos(CGFloat(endAngle.radians)),
                    y: center.y + innerRadius * sin(CGFloat(endAngle.radians))
                ))

                path.addArc(
                    center: center,
                    radius: innerRadius,
                    startAngle: endAngle,
                    endAngle: startAngle,
                    clockwise: true
                )

                path.closeSubpath()
            }
            .fill(segment.color.opacity(isSelected ? 1.0 : 0.6))
            .overlay(
                Path { path in
                    let startAngle = Angle(degrees: Double(segment.angle) - 22.5)
                    let endAngle = Angle(degrees: Double(segment.angle) + 22.5)

                    path.addArc(
                        center: center,
                        radius: radius,
                        startAngle: startAngle,
                        endAngle: endAngle,
                        clockwise: false
                    )

                    path.addLine(to: CGPoint(
                        x: center.x + innerRadius * cos(CGFloat(endAngle.radians)),
                        y: center.y + innerRadius * sin(CGFloat(endAngle.radians))
                    ))

                    path.addArc(
                        center: center,
                        radius: innerRadius,
                        startAngle: endAngle,
                        endAngle: startAngle,
                        clockwise: true
                    )

                    path.closeSubpath()
                }
                .stroke(isSelected ? Color.white : Color.clear, lineWidth: 3)
            )
            .scaleEffect(isSelected ? 1.05 : 1.0)

            // Label
            let labelAngle = CGFloat(segment.angle) * .pi / 180
            let labelRadius = (radius + innerRadius) / 2
            let labelX = center.x + labelRadius * cos(labelAngle) - 20
            let labelY = center.y + labelRadius * sin(labelAngle) - 10

            Text(segment.emotion.icon)
                .font(.title3)
                .position(x: labelX, y: labelY)
        }
    }
}

// MARK: - Supporting Types

private struct EmotionWheelSegment: Identifiable {
    let id = UUID()
    let emotion: EmotionType
    let angle: CGFloat
    let color: Color
}

extension EmotionType {
    var icon: String {
        switch self {
        case .joy: return "😊"
        case .sadness: return "😢"
        case .anger: return "😠"
        case .fear: return "😨"
        case .surprise: return "😲"
        case .disgust: return "🤢"
        case .contentment: return "😌"
        case .excitement: return "🤩"
        case .anxiety: return "😰"
        case .peaceful: return "😇"
        default: return "😐"
        }
    }
}

#Preview {
    EmotionWheelView()
}
