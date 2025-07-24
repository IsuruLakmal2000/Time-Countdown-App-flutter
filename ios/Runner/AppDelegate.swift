import Flutter
import UIKit
import WidgetKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    
    // Setup widget method channel
    let widgetChannel = FlutterMethodChannel(name: "com.circularx.timecountdown/widget_config",
                                           binaryMessenger: controller.binaryMessenger)
    
    widgetChannel.setMethodCallHandler({
      (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      self.handleWidgetMethodCall(call: call, result: result)
    })
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  // Handle URL scheme deep links
  override func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
    if url.scheme == "timecountdown" && url.host == "widget-config" {
      // Handle widget configuration deep link
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
        if let controller = self.window?.rootViewController as? FlutterViewController {
          let channel = FlutterMethodChannel(name: "com.circularx.timecountdown/deep_link", binaryMessenger: controller.binaryMessenger)
          channel.invokeMethod("handleDeepLink", arguments: ["url": url.absoluteString])
        }
      }
      return true
    }
    return super.application(app, open: url, options: options)
  }
  
  private func handleWidgetMethodCall(call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "updateWidgetData":
      if let args = call.arguments as? [String: Any],
         let countdownsJson = args["countdowns"] as? String {
        
        // Store the countdown data in shared UserDefaults
        let sharedDefaults = UserDefaults(suiteName: "group.com.circularx.timecountdown.widgets")
        if let countdownsData = countdownsJson.data(using: .utf8) {
          sharedDefaults?.set(countdownsData, forKey: "countdowns")
        }
        
        result(nil)
      } else {
        result(FlutterError(code: "INVALID_ARGUMENT", message: "countdowns data is required", details: nil))
      }
      
    case "reloadTimelines":
      if #available(iOS 14.0, *) {
        WidgetCenter.shared.reloadAllTimelines()
        result(nil)
      } else {
        result(FlutterError(code: "UNAVAILABLE", message: "Widgets require iOS 14.0+", details: nil))
      }
      
    case "updateWidgetStyle":
      // Store widget style preference for iOS widgets
      if let args = call.arguments as? [String: Any],
         let style = args["style"] as? String {
        UserDefaults(suiteName: "group.com.circularx.timecountdown.widgets")?.set(style, forKey: "widget_style")
        if #available(iOS 14.0, *) {
          WidgetCenter.shared.reloadAllTimelines()
        }
        result(nil)
      } else {
        result(FlutterError(code: "INVALID_ARGUMENT", message: "Style argument is required", details: nil))
      }
      
    case "updateWidgetData":
      if let args = call.arguments as? [String: Any],
         let countdownsJson = args["countdowns"] as? String {
        
        print("Updating iOS widget data with: \(countdownsJson)")
        
        // Store the countdowns data in shared UserDefaults
        let sharedDefaults = UserDefaults(suiteName: "group.com.circularx.timecountdown.widgets")
        sharedDefaults?.set(countdownsJson, forKey: "widget_countdowns")
        
        // Also store as Data for the widget extension
        if let data = countdownsJson.data(using: .utf8) {
          sharedDefaults?.set(data, forKey: "countdowns")
          print("Stored countdown data in UserDefaults")
        }
        
        // Reload widget timelines to reflect the change
        if #available(iOS 14.0, *) {
          WidgetCenter.shared.reloadAllTimelines()
          print("Widget timelines reloaded")
        }
        
        result(nil)
      } else {
        result(FlutterError(code: "INVALID_ARGUMENT", message: "countdowns data is required", details: nil))
      }
      
    case "configureIOSWidget":
      if let args = call.arguments as? [String: Any],
         let countdownId = args["countdownId"] as? String {
        
        // Store the countdown ID globally for all widgets (legacy support)
        let sharedDefaults = UserDefaults(suiteName: "group.com.circularx.timecountdown.widgets")
        sharedDefaults?.set(countdownId, forKey: "selected_countdown_global")
        
        print("iOS widget configured with countdown ID: \(countdownId)")
        
        // Reload widget timelines to reflect the change
        if #available(iOS 14.0, *) {
          WidgetCenter.shared.reloadAllTimelines()
        }
        
        result(nil)
      } else {
        result(FlutterError(code: "INVALID_ARGUMENT", message: "countdownId is required", details: nil))
      }
      
    case "configureIOSWidgetByIndex":
      if let args = call.arguments as? [String: Any],
         let widgetIndex = args["widgetIndex"] as? Int,
         let countdownId = args["countdownId"] as? String {
        
        let frequency = args["frequency"] as? String ?? "15min" // Default to 15 minutes
        
        // Store the countdown ID and frequency for the specific widget index
        let sharedDefaults = UserDefaults(suiteName: "group.com.circularx.timecountdown.widgets")
        sharedDefaults?.set(countdownId, forKey: "widget_countdown_\(widgetIndex)")
        sharedDefaults?.set(frequency, forKey: "widget_frequency_\(widgetIndex)")
        
        print("iOS widget index \(widgetIndex) configured with countdown ID: \(countdownId) and frequency: \(frequency)")
        
        // Reload widget timelines to reflect the change
        if #available(iOS 14.0, *) {
          WidgetCenter.shared.reloadAllTimelines()
        }
        
        result(nil)
      } else {
        result(FlutterError(code: "INVALID_ARGUMENT", message: "widgetIndex and countdownId are required", details: nil))
      }
      
    case "getIOSWidgetConfiguration":
      // Return all configured iOS widget indices and their countdowns
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
      
      result(configuredWidgets)
      
    case "getConfiguredWidgets":
      // Return all configured iOS widgets (legacy method - includes both global and index-based)
      let sharedDefaults = UserDefaults(suiteName: "group.com.circularx.timecountdown.widgets")
      var configuredWidgets: [String: String] = [:]
      
      if let defaults = sharedDefaults {
        for (key, value) in defaults.dictionaryRepresentation() {
          // Include both old format (selected_countdown_) and new format (widget_countdown_)
          if (key.hasPrefix("selected_countdown_") || key.hasPrefix("widget_countdown_")), 
             let countdownId = value as? String {
            let widgetId: String
            if key.hasPrefix("selected_countdown_") {
              widgetId = String(key.dropFirst("selected_countdown_".count))
            } else {
              widgetId = String(key.dropFirst("widget_countdown_".count))
            }
            configuredWidgets[widgetId] = countdownId
          }
        }
      }
      
      result(configuredWidgets)
      
    case "configureWidget":
      // iOS widgets don't need explicit configuration like Android
      // Widget configuration is handled through the widget's configuration intent
      result(nil)
      
    case "cancelConfiguration":
      // No-op for iOS
      result(nil)
      
    case "getWidgetId":
      // iOS doesn't have widget IDs like Android
      result(-1)
      
    case "getIOSWidgetFrequencyConfiguration":
      // Return all configured iOS widget indices and their frequencies
      let sharedDefaults = UserDefaults(suiteName: "group.com.circularx.timecountdown.widgets")
      var configuredFrequencies: [String: String] = [:]
      
      if let defaults = sharedDefaults {
        for (key, value) in defaults.dictionaryRepresentation() {
          if key.hasPrefix("widget_frequency_"), let frequency = value as? String {
            let widgetIndex = String(key.dropFirst("widget_frequency_".count))
            configuredFrequencies[widgetIndex] = frequency
          }
        }
      }
      
      result(configuredFrequencies)

    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
