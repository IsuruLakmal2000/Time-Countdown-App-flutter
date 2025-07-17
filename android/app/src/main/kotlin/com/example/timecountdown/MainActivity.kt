package com.circularx.timecountdown

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.circularx.timecountdown/widget_config"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "updateWidgetStyle" -> {
                    val style = call.argument<String>("style")
                    if (style != null) {
                        updateWidgetStyle(style)
                        result.success(null)
                    } else {
                        result.error("INVALID_ARGUMENT", "Style argument is required", null)
                    }
                }
                "configureWidget" -> {
                    val countdownId = call.argument<String>("countdownId")
                    if (countdownId != null) {
                        // Handle widget configuration if needed
                        result.success(null)
                    } else {
                        result.error("INVALID_ARGUMENT", "CountdownId argument is required", null)
                    }
                }
                "cancelConfiguration" -> {
                    // Handle cancel configuration
                    result.success(null)
                }
                "getWidgetId" -> {
                    // Return a default widget ID or handle as needed
                    result.success(-1)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun updateWidgetStyle(style: String) {
        // Send broadcast to update all widgets with new style
        val intent = Intent(this, CountdownWidgetProvider::class.java)
        intent.action = CountdownWidgetProvider.WIDGET_STYLE_UPDATE_ACTION
        sendBroadcast(intent)
    }
}
