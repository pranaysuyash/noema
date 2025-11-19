//
//  LocationHeatmapView.swift
//  Noema
//
//  Created on January 19, 2025.
//

import SwiftUI
import MapKit

public struct LocationHeatmapView: View {
    @StateObject private var viewModel = KnowledgeGraphViewModel()
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
    @State private var selectedLocation: Location?
    @State private var mapStyle: MapStyle = .emotion

    public init() {}

    public var body: some View {
        NavigationStack {
            ZStack {
                Color.noemaBackground.ignoresSafeArea()

                VStack(spacing: 0) {
                    // Map style selector
                    MapStyleSelector(selectedStyle: $mapStyle)

                    // Map view
                    LocationMapView(
                        locations: viewModel.locations,
                        region: $region,
                        selectedLocation: $selectedLocation,
                        mapStyle: mapStyle
                    )

                    // Location details panel
                    if let location = selectedLocation {
                        LocationDetailPanel(location: location)
                            .transition(.move(edge: .bottom))
                    }

                    // Locations list
                    LocationsListSection(
                        locations: viewModel.locations,
                        onSelect: { location in
                            selectedLocation = location
                            withAnimation {
                                region.center = CLLocationCoordinate2D(
                                    latitude: location.latitude,
                                    longitude: location.longitude
                                )
                            }
                        }
                    )
                    .frame(height: 200)
                }
            }
            .navigationTitle("Location Insights")
            .loading(viewModel.isLoading)
            .errorAlert(error: $viewModel.error)
            .task {
                await viewModel.loadLocations()
                if let first = viewModel.locations.first {
                    region.center = CLLocationCoordinate2D(
                        latitude: first.latitude,
                        longitude: first.longitude
                    )
                }
            }
        }
    }

    enum MapStyle: String, CaseIterable {
        case emotion = "Emotion"
        case frequency = "Frequency"
        case recent = "Recent"
    }
}

// MARK: - Supporting Views

private struct MapStyleSelector: View {
    @Binding var selectedStyle: LocationHeatmapView.MapStyle

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(LocationHeatmapView.MapStyle.allCases, id: \.self) { style in
                    Button {
                        selectedStyle = style
                    } label: {
                        Text(style.rawValue)
                            .font(.subheadline)
                            .fontWeight(selectedStyle == style ? .semibold : .regular)
                            .foregroundColor(selectedStyle == style ? .white : .noemaTextPrimary)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(selectedStyle == style ? Color.noemaPrimary : Color.noemaCardBackground)
                            .cornerRadius(20)
                    }
                }
            }
            .padding()
        }
        .background(Color.noemaBackground)
    }
}

private struct LocationMapView: View {
    let locations: [Location]
    @Binding var region: MKCoordinateRegion
    @Binding var selectedLocation: Location?
    let mapStyle: LocationHeatmapView.MapStyle

    var body: some View {
        Map(coordinateRegion: $region, annotationItems: locations) { location in
            MapAnnotation(coordinate: CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)) {
                LocationMarker(
                    location: location,
                    isSelected: selectedLocation?.id == location.id,
                    style: mapStyle
                )
                .onTapGesture {
                    withAnimation {
                        selectedLocation = location
                    }
                }
            }
        }
        .frame(maxHeight: .infinity)
    }
}

private struct LocationMarker: View {
    @ObservedObject var location: Location
    let isSelected: Bool
    let style: LocationHeatmapView.MapStyle

    private var markerColor: Color {
        switch style {
        case .emotion:
            return Color.forEmotion(valence: location.averageValence, arousal: location.averageArousal)
        case .frequency:
            let intensity = min(1.0, Double(location.visitCount) / 50.0)
            return Color.blue.opacity(0.4 + intensity * 0.6)
        case .recent:
            let daysSince = Date().timeIntervalSince(location.lastVisited) / (24 * 3600)
            let intensity = max(0.0, 1.0 - daysSince / 30.0)
            return Color.green.opacity(0.4 + intensity * 0.6)
        }
    }

    private var markerSize: CGFloat {
        let baseSize: CGFloat = 30
        switch style {
        case .emotion:
            return baseSize
        case .frequency:
            return baseSize + CGFloat(min(location.visitCount, 50)) * 0.4
        case .recent:
            return baseSize
        }
    }

    var body: some View {
        ZStack {
            Circle()
                .fill(markerColor)
                .frame(width: markerSize, height: markerSize)
                .opacity(0.7)

            Circle()
                .stroke(Color.white, lineWidth: isSelected ? 3 : 2)
                .frame(width: markerSize, height: markerSize)

            if isSelected {
                Circle()
                    .stroke(Color.noemaPrimary, lineWidth: 2)
                    .frame(width: markerSize + 8, height: markerSize + 8)
            }

            Text(location.placeType.icon)
                .font(.caption)
        }
        .shadow(color: .black.opacity(0.3), radius: 4)
    }
}

private struct LocationDetailPanel: View {
    @ObservedObject var location: Location

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    if let name = location.placeName, !name.isEmpty {
                        Text(name)
                            .font(.headline)
                            .foregroundColor(.noemaTextPrimary)
                    }

                    HStack(spacing: 4) {
                        Text(location.placeType.icon)
                        Text(location.placeType.displayName)
                            .font(.subheadline)
                            .foregroundColor(.noemaTextSecondary)
                    }

                    if let city = location.city, let state = location.state {
                        Text("\(city), \(state)")
                            .font(.caption)
                            .foregroundColor(.noemaTextSecondary)
                    }
                }

                Spacer()
            }

            Divider()

            // Metrics
            HStack(spacing: 20) {
                LocationStat(
                    icon: "mappin.circle.fill",
                    label: "Visits",
                    value: "\(location.visitCount)",
                    color: .blue
                )

                LocationStat(
                    icon: "face.smiling",
                    label: "Avg Valence",
                    value: location.averageValence > 0 ? "+\(Int(location.averageValence * 100))" : "\(Int(location.averageValence * 100))",
                    color: location.averageValence > 0 ? .joyColor : .sadnessColor
                )

                LocationStat(
                    icon: "bolt.fill",
                    label: "Avg Energy",
                    value: "\(Int(location.averageEnergy * 100))",
                    color: .xpGold
                )
            }

            // Last visited
            HStack {
                Image(systemName: "clock")
                    .font(.caption)
                    .foregroundColor(.noemaTextSecondary)

                Text("Last visited \(location.lastVisited.formatted(date: .abbreviated, time: .omitted))")
                    .font(.caption)
                    .foregroundColor(.noemaTextSecondary)
            }
        }
        .padding()
        .background(Color.noemaCardBackground)
        .cornerRadius(16, corners: [.topLeft, .topRight])
        .shadow(color: .black.opacity(0.1), radius: 10)
    }
}

private struct LocationStat: View {
    let icon: String
    let label: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)

            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.noemaTextPrimary)

            Text(label)
                .font(.caption2)
                .foregroundColor(.noemaTextSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}

private struct LocationsListSection: View {
    let locations: [Location]
    let onSelect: (Location) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("All Locations")
                .font(.headline)
                .foregroundColor(.noemaTextPrimary)
                .padding(.horizontal)

            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(locations.sorted { $0.visitCount > $1.visitCount }) { location in
                        LocationListRow(location: location)
                            .onTapGesture {
                                onSelect(location)
                            }
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.top)
        .background(Color.noemaBackground)
    }
}

private struct LocationListRow: View {
    @ObservedObject var location: Location

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color.forEmotion(valence: location.averageValence, arousal: location.averageArousal))
                .frame(width: 40, height: 40)
                .overlay(
                    Text(location.placeType.icon)
                        .font(.title3)
                )

            VStack(alignment: .leading, spacing: 4) {
                if let name = location.placeName, !name.isEmpty {
                    Text(name)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.noemaTextPrimary)
                        .lineLimit(1)
                }

                HStack(spacing: 8) {
                    Text("\(location.visitCount) visits")
                        .font(.caption)
                        .foregroundColor(.noemaTextSecondary)

                    Circle()
                        .fill(Color.noemaTextSecondary)
                        .frame(width: 3, height: 3)

                    Text("Valence: \(location.averageValence > 0 ? "+" : "")\(Int(location.averageValence * 100))")
                        .font(.caption)
                        .foregroundColor(.noemaTextSecondary)
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.noemaTextSecondary)
        }
        .padding()
        .background(Color.noemaCardBackground)
        .cornerRadius(10)
    }
}

// MARK: - Supporting Extensions

extension PlaceType {
    var icon: String {
        switch self {
        case .home: return "🏠"
        case .work: return "💼"
        case .cafe: return "☕"
        case .gym: return "💪"
        case .park: return "🌳"
        case .restaurant: return "🍽️"
        case .shop: return "🛍️"
        case .other: return "📍"
        }
    }

    var displayName: String {
        rawValue.capitalized
    }
}

// Helper for corner radius on specific corners
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

#Preview {
    LocationHeatmapView()
}
