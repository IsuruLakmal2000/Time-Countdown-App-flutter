//
//  CountdownWidgetExtension.swift
//  CountdownWidgetExtension
//
//  Created by Isuru lakmal on 2025-07-24.
//

import WidgetKit
import SwiftUI

struct CountdownProvider: TimelineProvider {
    func placeholder(in context: Context) -> CountdownEntry {
        CountdownEntry(
            date: Date(),
            title: "Sample Event",
            targetDate: Date().addingTimeInterval(86400), // 1 day from now
            days: 1,
            hours: 0,
            minutes: 0,
            seconds: 0,
            style: "glass"
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (CountdownEntry) -> ()) {
        let entry = CountdownEntry(
            date: Date(),
            title: "Sample Event",
            targetDate: Date().addingTimeInterval(86400),
            days: 1,
            hours: 0,
            minutes: 0,
            seconds: 0,
            style: "glass"
        )
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [CountdownEntry] = []
        let currentDate = Date()
        
        // Get countdown data from UserDefaults (shared with main app via App Groups)
        let sharedDefaults = UserDefaults(suiteName: "group.com.circularx.timecountdown.widgets")
        let countdownsData = sharedDefaults?.data(forKey: "countdowns")
        let style = sharedDefaults?.string(forKey: "widget_style") ?? "glass"
        
        // Use a round-robin approach for multiple widgets
        // This allows users to have different countdowns on different widgets
        let widgetIndex = getWidgetIndex(from: context)
        let selectedCountdownId = getSelectedCountdownForIndex(widgetIndex)
        
        print("Widget timeline update - Selected ID: \(selectedCountdownId)")
        print("Widget data available: \(countdownsData != nil)")
        
        var countdown: [String: Any]?
        var title = "Tap to Configure"
        var targetDate = Date().addingTimeInterval(86400)
        var isConfigured = false
        
        if let data = countdownsData,
           let countdowns = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
            
            print("Widget found \(countdowns.count) countdowns")
            print("Looking for countdown ID: \(selectedCountdownId)")
            
            if !selectedCountdownId.isEmpty {
                // Find the specific countdown by ID
                countdown = countdowns.first { countdownData in
                    if let id = countdownData["id"] as? String {
                        print("Checking countdown with ID: \(id)")
                        return id == selectedCountdownId
                    }
                    return false
                }
                print("Selected countdown found: \(countdown != nil)")
            }
            
            // If no specific countdown found or no ID selected, use first available
            if countdown == nil && !countdowns.isEmpty {
                countdown = countdowns.first
                print("Using first available countdown")
            }
            
            if let selectedCountdown = countdown {
                title = selectedCountdown["title"] as? String ?? "Countdown"
                if let targetTimestamp = selectedCountdown["targetDate"] as? Int64 {
                    targetDate = Date(timeIntervalSince1970: Double(targetTimestamp) / 1000)
                } else if let targetTimestamp = selectedCountdown["targetDate"] as? Int {
                    targetDate = Date(timeIntervalSince1970: Double(targetTimestamp) / 1000)
                } else if let targetTimestamp = selectedCountdown["targetDate"] as? Double {
                    targetDate = Date(timeIntervalSince1970: targetTimestamp / 1000)
                }
                isConfigured = true
                print("Widget configured with title: \(title), target: \(targetDate)")
            } else {
                print("No countdown data found")
            }
        } else {
            print("No countdown data available in UserDefaults")
        }
        
        // Get frequency setting for this widget
        let frequency = getWidgetFrequency(for: widgetIndex)
        let (updateInterval, timelineHours) = getUpdateSettings(for: frequency)
        
        // Create timeline entries based on frequency
        for minuteOffset in stride(from: 0, to: timelineHours * 60, by: updateInterval) {
            let entryDate = Calendar.current.date(byAdding: .minute, value: minuteOffset, to: currentDate)!
            let timeRemaining = targetDate.timeIntervalSince(entryDate)
            
            let days = max(0, Int(timeRemaining / 86400))
            let hours = max(0, Int((timeRemaining.truncatingRemainder(dividingBy: 86400)) / 3600))
            let minutes = max(0, Int((timeRemaining.truncatingRemainder(dividingBy: 3600)) / 60))
            // let seconds = max(0, Int(timeRemaining.truncatingRemainder(dividingBy: 60)))
            
            let entry = CountdownEntry(
                    date: entryDate,
                    title: title,
                    targetDate: targetDate,
                    days: days,
                    hours: hours,
                    minutes: minutes,
                    seconds: 0, // Always 0, not shown
                    style: style
                )
                entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct CountdownEntry: TimelineEntry {
    let date: Date
    let title: String
    let targetDate: Date
    let days: Int
    let hours: Int
    let minutes: Int
    let seconds: Int
    let style: String
}

// MARK: - Widget Configuration Helper Methods
extension CountdownProvider {
    private func getWidgetIndex(from context: Context) -> Int {
        // Create a deterministic index based on the widget's characteristics
        // This ensures the same widget always gets the same index
        let family = context.family.rawValue
        let displaySize = context.displaySize
        
        // Create a hash-like value from the widget characteristics
        let sizeString = "\(Int(displaySize.width))x\(Int(displaySize.height))"
        let identifier = "\(family)_\(sizeString)"
        
        // Get or create an index for this widget type
        let sharedDefaults = UserDefaults(suiteName: "group.com.circularx.timecountdown.widgets")
        let existingIndex = sharedDefaults?.integer(forKey: "widget_index_\(identifier)") ?? 0
        
        if existingIndex == 0 {
            // This is a new widget type, assign it the next available index
            let nextIndex = (sharedDefaults?.integer(forKey: "next_widget_index") ?? 0) + 1
            sharedDefaults?.set(nextIndex, forKey: "widget_index_\(identifier)")
            sharedDefaults?.set(nextIndex, forKey: "next_widget_index")
            print("Assigned new widget index \(nextIndex) to \(identifier)")
            return nextIndex
        } else {
            print("Using existing widget index \(existingIndex) for \(identifier)")
            return existingIndex
        }
    }
    
    private func getSelectedCountdownForIndex(_ widgetIndex: Int) -> String {
        let sharedDefaults = UserDefaults(suiteName: "group.com.circularx.timecountdown.widgets")
        
        // First, try to get a specific countdown assigned to this widget index
        if let specificCountdown = sharedDefaults?.string(forKey: "widget_countdown_\(widgetIndex)") {
            print("Found specific countdown for widget \(widgetIndex): \(specificCountdown)")
            return specificCountdown
        }
        
        // If no specific assignment, use round-robin distribution
        guard let countdownsData = sharedDefaults?.data(forKey: "countdowns"),
              let countdowns = try? JSONSerialization.jsonObject(with: countdownsData) as? [[String: Any]],
              !countdowns.isEmpty else {
            print("No countdowns available for widget \(widgetIndex)")
            return ""
        }
        
        // Use modulo to distribute widgets across available countdowns
        let countdownIndex = (widgetIndex - 1) % countdowns.count
        let selectedCountdown = countdowns[countdownIndex]
        let countdownId = selectedCountdown["id"] as? String ?? ""
        
        print("Using round-robin countdown for widget \(widgetIndex): \(countdownId) (index \(countdownIndex))")
        return countdownId
    }
    
    static func setSelectedCountdownId(_ countdownId: String, for widgetIndex: Int) {
        let sharedDefaults = UserDefaults(suiteName: "group.com.circularx.timecountdown.widgets")
        sharedDefaults?.set(countdownId, forKey: "widget_countdown_\(widgetIndex)")
        print("Set countdown \(countdownId) for widget index \(widgetIndex)")
    }
    
    static func getAllConfiguredWidgets() -> [String: String] {
        let sharedDefaults = UserDefaults(suiteName: "group.com.circularx.timecountdown.widgets")
        var configuredWidgets: [String: String] = [:]
        
        if let defaults = sharedDefaults {
            for (key, value) in defaults.dictionaryRepresentation() {
                if key.hasPrefix("widget_countdown_"), let countdownId = value as? String {
                    let widgetIndex = String(key.dropFirst("widget_countdown_".count))
                    configuredWidgets[widgetIndex] = countdownId
                }
            }
        }
        
        return configuredWidgets
    }
    
    private func getWidgetFrequency(for widgetIndex: Int) -> String {
        let sharedDefaults = UserDefaults(suiteName: "group.com.circularx.timecountdown.widgets")
        return sharedDefaults?.string(forKey: "widget_frequency_\(widgetIndex)") ?? "15min"
    }
    
    private func getUpdateSettings(for frequency: String) -> (updateInterval: Int, timelineHours: Int) {
        switch frequency {
        case "1min":
            return (updateInterval: 1, timelineHours: 2) // Update every 1 minute for 2 hours
        case "5min":
            return (updateInterval: 5, timelineHours: 4) // Update every 5 minutes for 4 hours
        case "15min":
            return (updateInterval: 15, timelineHours: 6) // Update every 15 minutes for 6 hours
        case "1hour":
            return (updateInterval: 60, timelineHours: 24) // Update every hour for 24 hours
        default:
            return (updateInterval: 15, timelineHours: 6) // Default to 15 minutes
        }
    }
}

struct CountdownWidgetExtensionEntryView: View {
    var entry: CountdownProvider.Entry

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background based on style
                backgroundView
                
                if entry.title == "Tap to Configure" {
                    // Configuration state
                    VStack(spacing: 4) {
                        Image(systemName: "plus.circle")
                            .font(.system(size: min(geometry.size.width * 0.15, 24)))
                            .foregroundColor(textColor.opacity(0.7))
                        
                        Text("Tap to Configure")
                            .font(.system(size: min(geometry.size.width * 0.08, 12), weight: .medium))
                            .foregroundColor(textColor)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                    }
                    .padding(8)
                } else {
                    // Normal countdown display
                    VStack(spacing: 4) {
                        // Title
                        Text(entry.title)
                            .font(.system(size: min(geometry.size.width * 0.1, 14), weight: .medium))
                            .foregroundColor(textColor)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                        
                        // Countdown display
                        if geometry.size.width > 150 { // Medium widget
                            HStack(spacing: 8) {
                                timeUnit(value: entry.days, label: "DAYS", geometry: geometry)
                                timeUnit(value: entry.hours, label: "HRS", geometry: geometry)
                                timeUnit(value: entry.minutes, label: "MIN", geometry: geometry)
                                // seconds removed
                            }
                        } else { // Small widget
                            HStack(spacing: 4) {
                                timeUnit(value: entry.days, label: "D", geometry: geometry)
                                timeUnit(value: entry.hours, label: "H", geometry: geometry)
                                timeUnit(value: entry.minutes, label: "M", geometry: geometry)
                                // seconds removed
                            }
                        }
                    }
                    .padding(8)
                }
            }
        }
        .widgetURL(URL(string: "timecountdown://widget-config"))
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
                .font(.system(size: min(geometry.size.width * 0.12, 18), weight: .bold, design: .rounded))
                .foregroundColor(textColor)
            Text(label)
                .font(.system(size: min(geometry.size.width * 0.06, 8), weight: .medium))
                .foregroundColor(textColor.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
    }
}

struct CountdownWidgetExtension: Widget {
    let kind: String = "CountdownWidgetExtension"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: CountdownProvider()) { entry in
            if #available(iOS 17.0, *) {
                CountdownWidgetExtensionEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                CountdownWidgetExtensionEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("Countdown Widget")
        .description("Show your countdown timer on the home screen")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

#Preview(as: .systemSmall) {
    CountdownWidgetExtension()
} timeline: {
    CountdownEntry(
        date: .now,
        title: "New Year",
        targetDate: Date().addingTimeInterval(86400),
        days: 1,
        hours: 2,
        minutes: 30,
        seconds: 0, // Always 0, not shown
        style: "glass"
    )
}
