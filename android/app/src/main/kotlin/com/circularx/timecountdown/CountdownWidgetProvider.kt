package com.circularx.timecountdown

import android.app.AlarmManager
import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.os.SystemClock
import android.widget.RemoteViews
import java.util.*
import java.text.SimpleDateFormat

class CountdownWidgetProvider : AppWidgetProvider() {

    companion object {
        const val WIDGET_CLICK_ACTION = "com.circularx.timecountdown.WIDGET_CLICK"
        const val WIDGET_STYLE_UPDATE_ACTION = "com.circularx.timecountdown.WIDGET_STYLE_UPDATE"
        const val PREFS_NAME = "countdown_widget_prefs"
        const val PREF_PREFIX_KEY = "appwidget_"
        
        // Static method to update all widgets when style changes
        fun updateAllWidgets(context: Context) {
            val appWidgetManager = AppWidgetManager.getInstance(context)
            val thisWidget = android.content.ComponentName(context, CountdownWidgetProvider::class.java)
            val allWidgetIds = appWidgetManager.getAppWidgetIds(thisWidget)
            
            val intent = Intent(context, CountdownWidgetProvider::class.java)
            intent.action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
            intent.putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, allWidgetIds)
            context.sendBroadcast(intent)
        }
    }

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        // Update all widgets
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
            // Schedule next update based on widget frequency
            scheduleNextUpdate(context, appWidgetId)
        }
    }

    override fun onDeleted(context: Context, appWidgetIds: IntArray) {
        // Clean up preferences when widget is deleted
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val editor = prefs.edit()
        for (appWidgetId in appWidgetIds) {
            editor.remove(PREF_PREFIX_KEY + appWidgetId)
            editor.remove("frequency_$appWidgetId")
            // Cancel scheduled updates for deleted widgets
            cancelScheduledUpdate(context, appWidgetId)
        }
        editor.apply()
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        
        if (intent.action == WIDGET_CLICK_ACTION) {
            // Open the main app when widget is clicked
            val launchIntent = context.packageManager.getLaunchIntentForPackage(context.packageName)
            launchIntent?.flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
            context.startActivity(launchIntent)
        } else if (intent.action == WIDGET_STYLE_UPDATE_ACTION) {
            // Update all widgets when style is changed
            updateAllWidgets(context)
        }
    }

    private fun updateAppWidget(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int
    ) {
        // Get widget style preference to determine which layout to use
        val widgetStyle = getWidgetStyle(context)
        val layoutId = when (widgetStyle) {
            "neomorphism" -> R.layout.countdown_widget_neomorphism
            "gradient" -> R.layout.countdown_widget_gradient
            "sunset" -> R.layout.countdown_widget_sunset
            "glass" -> R.layout.countdown_widget
            else -> R.layout.countdown_widget_neomorphism // Default to neomorphism (free style)
        }
        
        val views = RemoteViews(context.packageName, layoutId)
        
        // Get the selected countdown ID for this widget
        val countdownId = getSelectedCountdownId(context, appWidgetId)
        
        if (countdownId.isNotEmpty()) {
            // Get countdown data from Flutter shared preferences
            val countdownData = getCountdownData(context, countdownId)
            
            if (countdownData != null) {
                updateWidgetWithCountdown(views, countdownData)
                views.setViewVisibility(R.id.tap_to_configure, android.view.View.GONE)
            } else {
                showConfigurationMessage(views)
            }
        } else {
            showConfigurationMessage(views)
        }
        
        // Set up click intent to open the app
        val intent = Intent(context, CountdownWidgetProvider::class.java)
        intent.action = WIDGET_CLICK_ACTION
        val pendingIntent = PendingIntent.getBroadcast(
            context, 
            appWidgetId, 
            intent, 
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        views.setOnClickPendingIntent(R.id.countdown_title, pendingIntent)
        
        appWidgetManager.updateAppWidget(appWidgetId, views)
    }

    private fun showConfigurationMessage(views: RemoteViews) {
        views.setTextViewText(R.id.countdown_title, "Tap to configure")
        views.setTextViewText(R.id.days_value, "--")
        views.setTextViewText(R.id.hours_value, "--")
        views.setTextViewText(R.id.minutes_value, "--")
        views.setViewVisibility(R.id.tap_to_configure, android.view.View.VISIBLE)
    }

    private fun updateWidgetWithCountdown(views: RemoteViews, countdownData: CountdownData) {
        views.setTextViewText(R.id.countdown_title, countdownData.title)
        
        val timeRemaining = calculateTimeRemaining(countdownData.targetDate)
        
        views.setTextViewText(R.id.days_value, String.format("%02d", timeRemaining.days))
        views.setTextViewText(R.id.hours_value, String.format("%02d", timeRemaining.hours))
        views.setTextViewText(R.id.minutes_value, String.format("%02d", timeRemaining.minutes))
        views.setViewVisibility(R.id.tap_to_configure, android.view.View.GONE)
    }

    private fun calculateTimeRemaining(targetDate: Long): TimeRemaining {
        val now = System.currentTimeMillis()
        val diff = targetDate - now
        
        return if (diff > 0) {
            val days = (diff / (1000 * 60 * 60 * 24)).toInt()
            val hours = ((diff % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60)).toInt()
            val minutes = ((diff % (1000 * 60 * 60)) / (1000 * 60)).toInt()
            val seconds = ((diff % (1000 * 60)) / 1000).toInt()
            
            TimeRemaining(days, hours, minutes, seconds)
        } else {
            TimeRemaining(0, 0, 0, 0)
        }
    }

    private fun getSelectedCountdownId(context: Context, appWidgetId: Int): String {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        return prefs.getString(PREF_PREFIX_KEY + appWidgetId, "") ?: ""
    }

    private fun getWidgetStyle(context: Context): String {
        try {
            // Access Flutter's shared preferences for widget style
            val flutterPrefs = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
            return flutterPrefs.getString("flutter.widget_style", "neomorphism") ?: "neomorphism"
        } catch (e: Exception) {
            e.printStackTrace()
            return "neomorphism" // Default to neomorphism (free style)
        }
    }

    private fun getCountdownData(context: Context, countdownId: String): CountdownData? {
        try {
            // Access Flutter's shared preferences
            val flutterPrefs = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
            val countdownsJson = flutterPrefs.getString("flutter.widget_countdowns", null)
            
            if (countdownsJson != null) {
                val countdowns = parseCountdownsJson(countdownsJson)
                return countdowns.find { it.id == countdownId }
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
        return null
    }

    private fun parseCountdownsJson(json: String): List<CountdownData> {
        val countdowns = mutableListOf<CountdownData>()
        try {
            // Simple JSON parsing - in production environment, consider using Gson
            // Remove brackets and split by objects
            val cleanJson = json.trim().removePrefix("[").removeSuffix("]")
            if (cleanJson.isNotEmpty()) {
                val objects = cleanJson.split("},{")
                for (i in objects.indices) {
                    var obj = objects[i]
                    if (i == 0) obj = obj.removePrefix("{")
                    if (i == objects.size - 1) obj = obj.removeSuffix("}")
                    if (!obj.startsWith("{")) obj = "{$obj"
                    if (!obj.endsWith("}")) obj = "$obj}"
                    
                    // Extract values using string manipulation
                    val idMatch = Regex("\"id\"\\s*:\\s*\"([^\"]+)\"").find(obj)
                    val titleMatch = Regex("\"title\"\\s*:\\s*\"([^\"]+)\"").find(obj)
                    val targetDateMatch = Regex("\"targetDate\"\\s*:\\s*(\\d+)").find(obj)
                    
                    if (idMatch != null && titleMatch != null && targetDateMatch != null) {
                        countdowns.add(
                            CountdownData(
                                id = idMatch.groupValues[1],
                                title = titleMatch.groupValues[1],
                                targetDate = targetDateMatch.groupValues[1].toLong()
                            )
                        )
                    }
                }
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
        return countdowns
    }

    data class CountdownData(
        val id: String,
        val title: String,
        val targetDate: Long
    )

    data class TimeRemaining(
        val days: Int,
        val hours: Int,
        val minutes: Int,
        val seconds: Int
    )
}

// Extension function to save selected countdown ID
fun saveSelectedCountdownId(context: Context, appWidgetId: Int, countdownId: String) {
    val prefs = context.getSharedPreferences(CountdownWidgetProvider.PREFS_NAME, Context.MODE_PRIVATE)
    val editor = prefs.edit()
    editor.putString(CountdownWidgetProvider.PREF_PREFIX_KEY + appWidgetId, countdownId)
    editor.apply()
}

// Extension function to save widget frequency
fun saveWidgetFrequency(context: Context, appWidgetId: Int, frequency: String) {
    val prefs = context.getSharedPreferences(CountdownWidgetProvider.PREFS_NAME, Context.MODE_PRIVATE)
    val editor = prefs.edit()
    editor.putString("frequency_$appWidgetId", frequency)
    editor.apply()
}

// Extension function to get widget frequency
fun getWidgetFrequency(context: Context, appWidgetId: Int): String {
    val prefs = context.getSharedPreferences(CountdownWidgetProvider.PREFS_NAME, Context.MODE_PRIVATE)
    return prefs.getString("frequency_$appWidgetId", "15min") ?: "15min"
}

private fun scheduleNextUpdate(context: Context, appWidgetId: Int) {
        val frequency = getWidgetFrequency(context, appWidgetId)
        val updateIntervalMs = when (frequency) {
            "1min" -> 60 * 1000L
            "5min" -> 5 * 60 * 1000L
            "15min" -> 15 * 60 * 1000L
            "1hour" -> 60 * 60 * 1000L
            else -> 15 * 60 * 1000L // Default to 15 minutes
        }
        
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val intent = Intent(context, CountdownWidgetProvider::class.java).apply {
            action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
            putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, intArrayOf(appWidgetId))
        }
        
        val pendingIntent = PendingIntent.getBroadcast(
            context,
            appWidgetId,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        
        val nextUpdateTime = SystemClock.elapsedRealtime() + updateIntervalMs
        alarmManager.setExact(AlarmManager.ELAPSED_REALTIME, nextUpdateTime, pendingIntent)
    }
    
    private fun cancelScheduledUpdate(context: Context, appWidgetId: Int) {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val intent = Intent(context, CountdownWidgetProvider::class.java).apply {
            action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
            putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, intArrayOf(appWidgetId))
        }
        
        val pendingIntent = PendingIntent.getBroadcast(
            context,
            appWidgetId,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        
        alarmManager.cancel(pendingIntent)
    }
