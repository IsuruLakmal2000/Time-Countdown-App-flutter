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
                    if (countdownId != null) {
                        configureWidget(countdownId)
                        result.success(true)
                    } else {
                        result.error("INVALID_ARGUMENT", "Countdown ID is required", null)
                    }
                }
                "cancelConfiguration" -> {
                    cancelConfiguration()
                    result.success(true)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun configureWidget(countdownId: String) {
        // Save the selected countdown ID
        saveSelectedCountdownId(this, appWidgetId, countdownId)
        
        // Update the widget
        val appWidgetManager = AppWidgetManager.getInstance(this)
        CountdownWidgetProvider().onUpdate(this, appWidgetManager, intArrayOf(appWidgetId))
        
        // Return success result
        val resultValue = Intent()
        resultValue.putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId)
        setResult(Activity.RESULT_OK, resultValue)
        finish()
    }

    private fun cancelConfiguration() {
        setResult(Activity.RESULT_CANCELED)
        finish()
    }

    override fun getInitialRoute(): String {
        return "/widget_config"
    }
}
