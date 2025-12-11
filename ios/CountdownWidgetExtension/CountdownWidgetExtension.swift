//
//  CountdownWidgetExtension.swift
//  CountdownWidgetExtension
//
//  Created by Isuru lakmal on 2025-07-24.
//

import WidgetKit
import SwiftUI
import AppIntents

// MARK: - Helper to get image path for a countdown ID
func getImagePath(for countdownId: String?) -> String? {
    guard let countdownId = countdownId else { return nil }
    let sharedDefaults = UserDefaults(suiteName: "group.com.circularx.timecountdown.widgets")
    
    if let countdownsString = sharedDefaults?.string(forKey: "countdowns"),
       let data = countdownsString.data(using: .utf8),
       let countdowns = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
        for countdown in countdowns {
            if let id = countdown["id"] as? String, id == countdownId {
                return countdown["image"] as? String
            }
        }
    }
    return nil
}

// MARK: - Helper to load image from App Group container
func loadImageFromAppGroup(imagePath: String?) -> UIImage? {
    guard let imagePath = imagePath, !imagePath.isEmpty else { return nil }
    
    // Always extract filename and try App Group container first
    // This is crucial because widget extensions are sandboxed and cannot access
    // the main app's documents directory
    let fileName = (imagePath as NSString).lastPathComponent
    
    // Try loading from App Group shared container (where images are copied)
    if let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.circularx.timecountdown.widgets") {
        let imageURL = containerURL.appendingPathComponent("widget_images").appendingPathComponent(fileName)
        print("Widget: Trying to load image from App Group: \(imageURL.path)")
        
        if FileManager.default.fileExists(atPath: imageURL.path) {
            if let image = UIImage(contentsOfFile: imageURL.path) {
                print("Widget: Successfully loaded image from App Group container")
                return image
            } else {
                print("Widget: File exists but failed to create UIImage")
            }
        } else {
            print("Widget: Image file not found in App Group container")
        }
    }
    
    // Fallback: Try as absolute file path (only works in same sandbox, rarely applicable)
    if FileManager.default.fileExists(atPath: imagePath) {
        print("Widget: Trying to load image from absolute path: \(imagePath)")
        if let image = UIImage(contentsOfFile: imagePath) {
            print("Widget: Successfully loaded image from absolute path")
            return image
        }
    }
    
    // Final fallback: Try as URL
    if let url = URL(string: imagePath),
       let data = try? Data(contentsOf: url),
       let image = UIImage(data: data) {
        print("Widget: Successfully loaded image from URL")
        return image
    }
    
    print("Widget: Failed to load image from any source for path: \(imagePath)")
    return nil
}

// MARK: - App Intent for Countdown Selection
@available(iOS 17.0, *)
struct SelectCountdownIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Select Countdown"
    static var description = IntentDescription("Choose which countdown to display")
    
    @Parameter(title: "Countdown")
    var countdown: CountdownEntity?
}

// MARK: - Countdown Entity for Intent
@available(iOS 17.0, *)
struct CountdownEntity: AppEntity {
    let id: String
    let title: String
    let targetDate: Date
    let imagePath: String?
    
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Countdown"
    static var defaultQuery = CountdownEntityQuery()
    
    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(title)")
    }
}

// MARK: - Entity Query
@available(iOS 17.0, *)
struct CountdownEntityQuery: EntityQuery {
    func entities(for identifiers: [CountdownEntity.ID]) async throws -> [CountdownEntity] {
        let allEntities = await suggestedEntities()
        return allEntities.filter { identifiers.contains($0.id) }
    }
    
    func suggestedEntities() async -> [CountdownEntity] {
        let sharedDefaults = UserDefaults(suiteName: "group.com.circularx.timecountdown.widgets")
        var entities: [CountdownEntity] = []
        
        if let countdownsString = sharedDefaults?.string(forKey: "countdowns"),
           let data = countdownsString.data(using: .utf8),
           let countdowns = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
            
            for countdown in countdowns {
                if let id = countdown["id"] as? String,
                   let title = countdown["title"] as? String {
                    var targetDate = Date()
                    if let timestamp = countdown["targetDate"] as? Int64 {
                        targetDate = Date(timeIntervalSince1970: Double(timestamp) / 1000)
                    } else if let timestamp = countdown["targetDate"] as? Int {
                        targetDate = Date(timeIntervalSince1970: Double(timestamp) / 1000)
                    } else if let timestamp = countdown["targetDate"] as? Double {
                        targetDate = Date(timeIntervalSince1970: timestamp / 1000)
                    }
                    let imagePath = countdown["image"] as? String
                    entities.append(CountdownEntity(id: id, title: title, targetDate: targetDate, imagePath: imagePath))
                }
            }
        }
        
        return entities
    }
    
    func defaultResult() async -> CountdownEntity? {
        let entities = await suggestedEntities()
        return entities.first
    }
}

// MARK: - Timeline Provider for iOS 17+ with Intent
@available(iOS 17.0, *)
struct ConfigurableCountdownProvider: AppIntentTimelineProvider {
    typealias Entry = CountdownEntry
    typealias Intent = SelectCountdownIntent
    
    func placeholder(in context: Context) -> CountdownEntry {
        CountdownEntry(
            date: Date(),
            title: "Sample Event",
            targetDate: Date().addingTimeInterval(86400),
            days: 1,
            hours: 0,
            minutes: 0,
            seconds: 0,
            style: "glass",
            imagePath: nil
        )
    }
    
    func snapshot(for configuration: SelectCountdownIntent, in context: Context) async -> CountdownEntry {
        // For snapshot, use entity data directly for speed - it already has the values from selection
        if let selectedCountdown = configuration.countdown {
            // The entity already contains the title and targetDate from when it was created
            // Just need to look up the image path if not already in the entity
            var imagePath = selectedCountdown.imagePath
            
            // If image path is nil, try to look it up quickly
            if imagePath == nil || imagePath?.isEmpty == true {
                let sharedDefaults = UserDefaults(suiteName: "group.com.circularx.timecountdown.widgets")
                if let countdownsString = sharedDefaults?.string(forKey: "countdowns"),
                   let data = countdownsString.data(using: .utf8),
                   let countdowns = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]],
                   let matchingCountdown = countdowns.first(where: { ($0["id"] as? String) == selectedCountdown.id }) {
                    imagePath = matchingCountdown["image"] as? String
                }
            }
            
            let timeRemaining = selectedCountdown.targetDate.timeIntervalSince(Date())
            let days = max(0, Int(timeRemaining / 86400))
            let hours = max(0, Int((timeRemaining.truncatingRemainder(dividingBy: 86400)) / 3600))
            let minutes = max(0, Int((timeRemaining.truncatingRemainder(dividingBy: 3600)) / 60))
            
            return CountdownEntry(
                date: Date(),
                title: selectedCountdown.title,
                targetDate: selectedCountdown.targetDate,
                days: days,
                hours: hours,
                minutes: minutes,
                seconds: 0,
                style: "glass",
                imagePath: imagePath
            )
        }
        
        // If no countdown selected, try to show first available countdown instead of placeholder
        let sharedDefaults = UserDefaults(suiteName: "group.com.circularx.timecountdown.widgets")
        if let countdownsString = sharedDefaults?.string(forKey: "countdowns"),
           let data = countdownsString.data(using: .utf8),
           let countdowns = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]],
           let first = countdowns.first {
            
            let title = first["title"] as? String ?? "Countdown"
            let imagePath = first["image"] as? String
            var targetDate = Date().addingTimeInterval(86400)
            
            if let timestamp = first["targetDate"] as? Int64 {
                targetDate = Date(timeIntervalSince1970: Double(timestamp) / 1000)
            } else if let timestamp = first["targetDate"] as? Int {
                targetDate = Date(timeIntervalSince1970: Double(timestamp) / 1000)
            } else if let timestamp = first["targetDate"] as? Double {
                targetDate = Date(timeIntervalSince1970: timestamp / 1000)
            }
            
            let timeRemaining = targetDate.timeIntervalSince(Date())
            let days = max(0, Int(timeRemaining / 86400))
            let hours = max(0, Int((timeRemaining.truncatingRemainder(dividingBy: 86400)) / 3600))
            let minutes = max(0, Int((timeRemaining.truncatingRemainder(dividingBy: 3600)) / 60))
            
            return CountdownEntry(
                date: Date(),
                title: title,
                targetDate: targetDate,
                days: days,
                hours: hours,
                minutes: minutes,
                seconds: 0,
                style: "glass",
                imagePath: imagePath
            )
        }
        
        return placeholder(in: context)
    }
    
    func timeline(for configuration: SelectCountdownIntent, in context: Context) async -> Timeline<CountdownEntry> {
        var entries: [CountdownEntry] = []
        let currentDate = Date()
        let sharedDefaults = UserDefaults(suiteName: "group.com.circularx.timecountdown.widgets")
        let style = sharedDefaults?.string(forKey: "widget_style") ?? "glass"
        
        var title = "Tap to Configure"
        var targetDate = Date().addingTimeInterval(86400)
        var imagePath: String? = nil
        
        // Read all countdowns from UserDefaults
        var allCountdowns: [[String: Any]] = []
        if let countdownsString = sharedDefaults?.string(forKey: "countdowns"),
           let data = countdownsString.data(using: .utf8),
           let countdowns = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
            allCountdowns = countdowns
        }
        
        // Use the selected countdown from the intent - look it up by ID to get fresh data
        if let selectedCountdown = configuration.countdown {
            // Look up the countdown by ID in the stored data to get fresh values
            if let matchingCountdown = allCountdowns.first(where: { ($0["id"] as? String) == selectedCountdown.id }) {
                title = matchingCountdown["title"] as? String ?? selectedCountdown.title
                imagePath = matchingCountdown["image"] as? String
                
                // Parse target date from stored data
                if let timestamp = matchingCountdown["targetDate"] as? Int64 {
                    targetDate = Date(timeIntervalSince1970: Double(timestamp) / 1000)
                } else if let timestamp = matchingCountdown["targetDate"] as? Int {
                    targetDate = Date(timeIntervalSince1970: Double(timestamp) / 1000)
                } else if let timestamp = matchingCountdown["targetDate"] as? Double {
                    targetDate = Date(timeIntervalSince1970: timestamp / 1000)
                } else {
                    // Fallback to entity's stored date
                    targetDate = selectedCountdown.targetDate
                }
                
                print("Widget: Using selected countdown '\(title)' with ID \(selectedCountdown.id)")
            } else {
                // Countdown with selected ID not found, use entity's stored values
                title = selectedCountdown.title
                targetDate = selectedCountdown.targetDate
                imagePath = selectedCountdown.imagePath
                print("Widget: Selected countdown ID \(selectedCountdown.id) not found in stored data, using cached entity values")
            }
        } else if let first = allCountdowns.first {
            // Fallback to first available countdown when nothing is selected
            title = first["title"] as? String ?? "Countdown"
            imagePath = first["image"] as? String
            if let timestamp = first["targetDate"] as? Int64 {
                targetDate = Date(timeIntervalSince1970: Double(timestamp) / 1000)
            } else if let timestamp = first["targetDate"] as? Int {
                targetDate = Date(timeIntervalSince1970: Double(timestamp) / 1000)
            } else if let timestamp = first["targetDate"] as? Double {
                targetDate = Date(timeIntervalSince1970: timestamp / 1000)
            }
            print("Widget: No countdown selected, using first available countdown '\(title)'")
        } else {
            print("Widget: No countdowns available")
        }
        
        // Create timeline entries for next 6 hours, updating every 15 minutes
        for minuteOffset in stride(from: 0, to: 360, by: 15) {
            let entryDate = Calendar.current.date(byAdding: .minute, value: minuteOffset, to: currentDate)!
            let timeRemaining = targetDate.timeIntervalSince(entryDate)
            
            let days = max(0, Int(timeRemaining / 86400))
            let hours = max(0, Int((timeRemaining.truncatingRemainder(dividingBy: 86400)) / 3600))
            let minutes = max(0, Int((timeRemaining.truncatingRemainder(dividingBy: 3600)) / 60))
            
            let entry = CountdownEntry(
                date: entryDate,
                title: title,
                targetDate: targetDate,
                days: days,
                hours: hours,
                minutes: minutes,
                seconds: 0,
                style: style,
                imagePath: imagePath
            )
            entries.append(entry)
        }
        
        return Timeline(entries: entries, policy: .atEnd)
    }
}

// MARK: - Legacy Timeline Provider for iOS 14-16
struct LegacyCountdownProvider: TimelineProvider {
    func placeholder(in context: Context) -> CountdownEntry {
        CountdownEntry(
            date: Date(),
            title: "Sample Event",
            targetDate: Date().addingTimeInterval(86400),
            days: 1,
            hours: 0,
            minutes: 0,
            seconds: 0,
            style: "glass",
            imagePath: nil
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
            style: "glass",
            imagePath: nil
        )
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [CountdownEntry] = []
        let currentDate = Date()
        
        let sharedDefaults = UserDefaults(suiteName: "group.com.circularx.timecountdown.widgets")
        let style = sharedDefaults?.string(forKey: "widget_style") ?? "glass"
        
        var title = "Tap to Configure"
        var targetDate = Date().addingTimeInterval(86400)
        var imagePath: String? = nil
        
        // Try reading countdown data
        if let countdownsString = sharedDefaults?.string(forKey: "countdowns"),
           let data = countdownsString.data(using: .utf8),
           let countdowns = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]],
           let first = countdowns.first {
            
            title = first["title"] as? String ?? "Countdown"
            imagePath = first["image"] as? String
            if let timestamp = first["targetDate"] as? Int64 {
                targetDate = Date(timeIntervalSince1970: Double(timestamp) / 1000)
            } else if let timestamp = first["targetDate"] as? Int {
                targetDate = Date(timeIntervalSince1970: Double(timestamp) / 1000)
            } else if let timestamp = first["targetDate"] as? Double {
                targetDate = Date(timeIntervalSince1970: timestamp / 1000)
            }
        }
        
        // Create timeline entries
        for minuteOffset in stride(from: 0, to: 360, by: 15) {
            let entryDate = Calendar.current.date(byAdding: .minute, value: minuteOffset, to: currentDate)!
            let timeRemaining = targetDate.timeIntervalSince(entryDate)
            
            let days = max(0, Int(timeRemaining / 86400))
            let hours = max(0, Int((timeRemaining.truncatingRemainder(dividingBy: 86400)) / 3600))
            let minutes = max(0, Int((timeRemaining.truncatingRemainder(dividingBy: 3600)) / 60))
            
            let entry = CountdownEntry(
                date: entryDate,
                title: title,
                targetDate: targetDate,
                days: days,
                hours: hours,
                minutes: minutes,
                seconds: 0,
                style: style,
                imagePath: imagePath
            )
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

// MARK: - Entry
struct CountdownEntry: TimelineEntry {
    let date: Date
    let title: String
    let targetDate: Date
    let days: Int
    let hours: Int
    let minutes: Int
    let seconds: Int
    let style: String
    let imagePath: String?
}

// MARK: - Widget View
struct CountdownWidgetExtensionEntryView: View {
    var entry: CountdownEntry

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background - try to load countdown image, fallback to gradient
                if let imagePath = entry.imagePath,
                   let uiImage = loadImageFromAppGroup(imagePath: imagePath) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .clipped()
                    
                    // Dark overlay for better text readability
                    Color.black.opacity(0.3)
                } else {
                    // Fallback gradient background
                    LinearGradient(
                        colors: [Color(red: 0.1, green: 0.1, blue: 0.15), Color(red: 0.05, green: 0.05, blue: 0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                }
                
                if entry.title == "Tap to Configure" {
                    // Configuration state
                    VStack(spacing: 4) {
                        Image(systemName: "plus.circle")
                            .font(.system(size: min(geometry.size.width * 0.15, 24)))
                            .foregroundColor(.white.opacity(0.7))
                        
                        Text("Tap to Configure")
                            .font(.system(size: min(geometry.size.width * 0.08, 12), weight: .medium))
                            .foregroundColor(.white)
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
                            .foregroundColor(.white)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                            .shadow(color: .black.opacity(0.5), radius: 2, x: 0, y: 1)
                        
                        // Countdown display
                        if geometry.size.width > 150 { // Medium widget
                            HStack(spacing: 8) {
                                timeUnit(value: entry.days, label: "DAYS", geometry: geometry)
                                timeUnit(value: entry.hours, label: "HRS", geometry: geometry)
                                timeUnit(value: entry.minutes, label: "MIN", geometry: geometry)
                            }
                        } else { // Small widget
                            HStack(spacing: 4) {
                                timeUnit(value: entry.days, label: "D", geometry: geometry)
                                timeUnit(value: entry.hours, label: "H", geometry: geometry)
                                timeUnit(value: entry.minutes, label: "M", geometry: geometry)
                            }
                        }
                    }
                    .padding(8)
                }
            }
        }
        .widgetURL(URL(string: "timecountdown://widget-config"))
    }
    
    private func timeUnit(value: Int, label: String, geometry: GeometryProxy) -> some View {
        VStack(spacing: 1) {
            Text("\(value)")
                .font(.system(size: min(geometry.size.width * 0.12, 18), weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.5), radius: 2, x: 0, y: 1)
            Text(label)
                .font(.system(size: min(geometry.size.width * 0.06, 8), weight: .medium))
                .foregroundColor(.white.opacity(0.9))
                .shadow(color: .black.opacity(0.5), radius: 1, x: 0, y: 1)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Widget Definition
struct CountdownWidgetExtension: Widget {
    let kind: String = "CountdownWidgetExtension"

    var body: some WidgetConfiguration {
        if #available(iOS 17.0, *) {
            return AppIntentConfiguration(kind: kind, intent: SelectCountdownIntent.self, provider: ConfigurableCountdownProvider()) { entry in
                CountdownWidgetExtensionEntryView(entry: entry)
                    .containerBackground(for: .widget) {
                        // Empty background to remove any system default styling
                        Color.clear
                    }
            }
            .configurationDisplayName("Countdown Widget")
            .description("Show your countdown timer on the home screen. Long press to select a countdown.")
            .supportedFamilies([.systemSmall, .systemMedium])
            .contentMarginsDisabled()
        } else {
            return StaticConfiguration(kind: kind, provider: LegacyCountdownProvider()) { entry in
                CountdownWidgetExtensionEntryView(entry: entry)
            }
            .configurationDisplayName("Countdown Widget")
            .description("Show your countdown timer on the home screen")
            .supportedFamilies([.systemSmall, .systemMedium])
        }
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
        seconds: 0,
        style: "glass",
        imagePath: nil
    )
}
