import WidgetKit
import SwiftUI

struct CountdownWidget: Widget {
    let kind: String = "CountdownWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: CountdownProvider()) { entry in
            CountdownWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Countdown Widget")
        .description("Show your countdown timer on the home screen")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct CountdownWidgetEntryView: View {
    var entry: CountdownProvider.Entry

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background based on style
                backgroundView
                
                VStack(spacing: 12) {
                    // Title
                    Text(entry.title)
                        .font(.system(size: min(geometry.size.width * 0.15, 18), weight: .bold))
                        .foregroundColor(textColor)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                    
                    // Countdown display
                    if geometry.size.width > 150 { // Medium widget
                        HStack(spacing: 8) {
                            timeUnit(value: entry.days, label: "DAYS", geometry: geometry)
                            timeUnit(value: entry.hours, label: "HRS", geometry: geometry)
                            timeUnit(value: entry.minutes, label: "MIN", geometry: geometry)
                            timeUnit(value: entry.seconds, label: "SEC", geometry: geometry)
                        }
                    } else { // Small widget
                        VStack(spacing: 2) {
                            HStack(spacing: 4) {
                                timeUnit(value: entry.days, label: "D", geometry: geometry)
                                timeUnit(value: entry.hours, label: "H", geometry: geometry)
                            }
                            HStack(spacing: 4) {
                                timeUnit(value: entry.minutes, label: "M", geometry: geometry)
                                timeUnit(value: entry.seconds, label: "S", geometry: geometry)
                            }
                        }
                    }
                }
                .padding(8)
            }
        }
    }
    
    @ViewBuilder
    private var backgroundView: some View {
        switch entry.style {
        case "glass":
            Color.black.opacity(0.3)
                .background(.ultraThinMaterial)
        case "neomorphism":
            Color.gray.opacity(0.2)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(red: 0.15, green: 0.15, blue: 0.15))
                        .shadow(color: .white.opacity(0.1), radius: 1, x: -1, y: -1)
                        .shadow(color: .black.opacity(0.3), radius: 2, x: 2, y: 2)
                )
        case "gradient":
            LinearGradient(
                colors: [Color.purple.opacity(0.8), Color.pink.opacity(0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case "sunset":
            LinearGradient(
                colors: [Color.orange.opacity(0.8), Color.pink.opacity(0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        default:
            Color.black.opacity(0.3)
                .background(.ultraThinMaterial)
        }
    }
    
    private var textColor: Color {
        switch entry.style {
        case "neomorphism":
            return .white
        default:
            return .primary
        }
    }
    
    private func timeUnit(value: Int, label: String, geometry: GeometryProxy) -> some View {
        VStack(spacing: 1) {
            Text("\(value)")
                .font(.system(size: min(geometry.size.width * 0.15, 20), weight: .bold, design: .rounded))
                .foregroundColor(textColor)
            Text(label)
                .font(.system(size: min(geometry.size.width * 0.08, 12), weight: .medium))
                .foregroundColor(textColor.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview(as: .systemSmall) {
    CountdownWidget()
} timeline: {
    CountdownEntry(
        date: .now,
        title: "New Year",
        targetDate: Date().addingTimeInterval(86400),
        days: 1,
        hours: 2,
        minutes: 30,
        seconds: 45,
        style: "glass"
    )
}
