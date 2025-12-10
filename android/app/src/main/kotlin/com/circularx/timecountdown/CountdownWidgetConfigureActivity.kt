package com.circularx.timecountdown

import android.app.Activity
import android.appwidget.AppWidgetManager
import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class CountdownWidgetConfigureActivity : FlutterActivity() {
    
    companion object {
        const val CHANNEL = "com.circularx.timecountdown/widget_config"
        const val EXTRA_APPWIDGET_ID = "appwidget_id"
    }
    
    private var appWidgetId = AppWidgetManager.INVALID_APPWIDGET_ID
    private lateinit var methodChannel: MethodChannel

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Find the widget id from the intent
        val intent = intent
        val extras = intent.extras
        if (extras != null) {
            appWidgetId = extras.getInt(
                AppWidgetManager.EXTRA_APPWIDGET_ID,
                AppWidgetManager.INVALID_APPWIDGET_ID
            )
        }

        // If this activity was started with an intent without an app widget ID, finish with an error
        if (appWidgetId == AppWidgetManager.INVALID_APPWIDGET_ID) {
            finish()
            return
        }

        // Set the result to CANCELED. This will cause the widget host to cancel
        // out of the widget placement if the user presses the back button
        setResult(Activity.RESULT_CANCELED)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        methodChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                "getWidgetId" -> {
                    result.success(appWidgetId)
                }
                "configureWidget" -> {
                    val countdownId = call.argument<String>("countdownId")
                    val frequency = call.argument<String>("frequency") ?: "15min" // Default to 15 minutes
                    val widgetId = call.argument<Int>("widgetId") ?: appWidgetId
                    if (countdownId != null) {
                        configureWidget(countdownId, frequency, widgetId)
                        result.success(true)
                    } else {
                        result.error("INVALID_ARGUMENT", "Countdown ID is required", null)
                    }
                }
                "cancelConfiguration" -> {
                    cancelConfiguration()
                    result.success(true)
                }
                "getAndroidWidgetFrequencyConfiguration" -> {
                    val frequencyConfig = getWidgetFrequencyConfiguration()
                    result.success(frequencyConfig)
                }
                "getAndroidWidgetConfiguration" -> {
                    val widgetConfig = getWidgetConfiguration()
                    result.success(widgetConfig)
                }
                "updateAllWidgets" -> {
                    updateAllWidgets()
                    result.success(true)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun updateAllWidgets() {
        // Update all widgets immediately
        CountdownWidgetProvider.updateAllWidgets(this)
    }

    private fun configureWidget(countdownId: String, frequency: String = "15min", widgetId: Int = appWidgetId) {
        // Save the selected countdown ID and frequency
        saveSelectedCountdownId(this, widgetId, countdownId)
        saveWidgetFrequency(this, widgetId, frequency)
        
        // Update the widget
        val appWidgetManager = AppWidgetManager.getInstance(this)
        CountdownWidgetProvider().onUpdate(this, appWidgetManager, intArrayOf(widgetId))
        
        // Return success result
        val resultValue = Intent()
        resultValue.putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, widgetId)
        setResult(Activity.RESULT_OK, resultValue)
        finish()
    }

    private fun cancelConfiguration() {
        setResult(Activity.RESULT_CANCELED)
        finish()
    }
    
    // Save widget frequency preference
    private fun saveWidgetFrequency(context: android.content.Context, appWidgetId: Int, frequency: String) {
        val prefs = context.getSharedPreferences("countdown_widget_prefs", android.content.Context.MODE_PRIVATE)
        val editor = prefs.edit()
        editor.putString("frequency_$appWidgetId", frequency)
        editor.apply()
    }

    // Get widget frequency configuration
    private fun getWidgetFrequencyConfiguration(): Map<String, String> {
        val prefs = getSharedPreferences("countdown_widget_prefs", android.content.Context.MODE_PRIVATE)
        val frequencyConfig = mutableMapOf<String, String>()
        
        for ((key, value) in prefs.all) {
            if (key.startsWith("frequency_") && value is String) {
                val widgetId = key.removePrefix("frequency_")
                frequencyConfig[widgetId] = value
            }
        }
        
        return frequencyConfig
    }

    // Get widget configuration
    private fun getWidgetConfiguration(): Map<String, String> {
        val prefs = getSharedPreferences("countdown_widget_prefs", android.content.Context.MODE_PRIVATE)
        val widgetConfig = mutableMapOf<String, String>()
        
        for ((key, value) in prefs.all) {
            if (key.startsWith("appwidget_") && value is String) {
                val widgetId = key.removePrefix("appwidget_")
                widgetConfig[widgetId] = value
            }
        }
        
        return widgetConfig
    }

    override fun getInitialRoute(): String {
        return "/widget_config"
    }
}
