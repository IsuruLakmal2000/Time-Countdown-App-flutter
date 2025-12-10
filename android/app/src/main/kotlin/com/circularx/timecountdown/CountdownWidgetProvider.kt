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
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import java.io.File
import java.util.*
import java.text.SimpleDateFormat

open class CountdownWidgetProvider : AppWidgetProvider() {

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
            
            // Also notify the small widget provider if it exists
            val smallWidget = android.content.ComponentName(context, CountdownWidgetProviderSmall::class.java)
            val smallWidgetIds = appWidgetManager.getAppWidgetIds(smallWidget)

            // Update standard widgets
            val intent = Intent(context, CountdownWidgetProvider::class.java)
            intent.action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
            intent.putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, allWidgetIds)
            context.sendBroadcast(intent)
            
            // Update small widgets
            val intentSmall = Intent(context, CountdownWidgetProviderSmall::class.java)
            intentSmall.action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
            intentSmall.putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, smallWidgetIds)
            context.sendBroadcast(intentSmall)
        }
    }
    
    // Allow subclasses to define their own layout
    open fun getLayoutId(): Int {
        return R.layout.countdown_widget
    }

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        android.util.Log.d("WidgetDebug", "onUpdate called for IDs: ${appWidgetIds.joinToString()}")
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
        android.util.Log.d("WidgetDebug", "updateAppWidget called for ID: $appWidgetId")
        // Use the layout defined by this provider (or subclass)
        val layoutId = getLayoutId()
        
        val views = RemoteViews(context.packageName, layoutId)
        
        // Get the selected countdown ID for this widget
        val countdownId = getSelectedCountdownId(context, appWidgetId)
        android.util.Log.d("WidgetDebug", "Selected countdown ID for widget $appWidgetId is: '$countdownId'")
        
        if (countdownId.isNotEmpty()) {
            // Get countdown data from Flutter shared preferences
            val countdownData = getCountdownData(context, countdownId)
            
            if (countdownData != null) {
                updateWidgetWithCountdown(context, views, countdownData)
                views.setViewVisibility(R.id.tap_to_configure, android.view.View.GONE)
            } else {
                android.util.Log.d("WidgetDebug", "Countdown data not found for ID: $countdownId")
                showConfigurationMessage(views)
            }
        } else {
            showConfigurationMessage(views)
        }
        
        // Set up click intent - if not configured, open config activity, otherwise open app
        if (countdownId.isEmpty()) {
            // Widget not configured - open configuration activity
            val configIntent = Intent(context, CountdownWidgetConfigureActivity::class.java)
            configIntent.putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId)
            configIntent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
            val pendingIntent = PendingIntent.getActivity(
                context,
                appWidgetId,
                configIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.countdown_title, pendingIntent)
        } else {
            // Widget configured - open main app
            val intent = Intent(context, CountdownWidgetProvider::class.java)
            intent.action = WIDGET_CLICK_ACTION
            val pendingIntent = PendingIntent.getBroadcast(
                context, 
                appWidgetId, 
                intent, 
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.countdown_title, pendingIntent)
        }
        
        appWidgetManager.updateAppWidget(appWidgetId, views)
    }

    private fun showConfigurationMessage(views: RemoteViews) {
        views.setTextViewText(R.id.countdown_title, "Tap to configure")
        views.setTextViewText(R.id.days_value, "--")
        views.setTextViewText(R.id.hours_value, "--")
        views.setTextViewText(R.id.minutes_value, "--")
        views.setViewVisibility(R.id.tap_to_configure, android.view.View.VISIBLE)
    }

    private fun updateWidgetWithCountdown(context: Context, views: RemoteViews, countdownData: CountdownData) {
        views.setTextViewText(R.id.countdown_title, countdownData.title)
        
        val timeRemaining = calculateTimeRemaining(countdownData.targetDate)
        
        views.setTextViewText(R.id.days_value, String.format("%02d", timeRemaining.days))
        views.setTextViewText(R.id.hours_value, String.format("%02d", timeRemaining.hours))
        views.setTextViewText(R.id.minutes_value, String.format("%02d", timeRemaining.minutes))
        views.setViewVisibility(R.id.tap_to_configure, android.view.View.GONE)

        // Set background image if available
        if (countdownData.image.isNotEmpty()) {
            val bitmap = loadBitmap(context, countdownData.image)
            if (bitmap != null) {
                views.setImageViewBitmap(R.id.widget_background_image, bitmap)
                views.setViewVisibility(R.id.widget_background_image, android.view.View.VISIBLE)
                views.setViewVisibility(R.id.widget_dim_overlay, android.view.View.VISIBLE)
            } else {
                 views.setViewVisibility(R.id.widget_background_image, android.view.View.GONE)
                 views.setViewVisibility(R.id.widget_dim_overlay, android.view.View.GONE)
            }
        }
    }

    private fun loadBitmap(context: Context, imagePath: String): Bitmap? {
        return try {
            val options = BitmapFactory.Options().apply {
                inJustDecodeBounds = true
            }

            // First pass: Decode bounds only
            if (imagePath.startsWith("assets/")) {
                val assetPath = "flutter_assets/" + imagePath
                context.assets.open(assetPath).use { 
                    BitmapFactory.decodeStream(it, null, options) 
                }
            } else {
                val file = File(imagePath)
                if (file.exists()) {
                    BitmapFactory.decodeFile(file.absolutePath, options)
                } else {
                    return null
                }
            }

            // Calculate inSampleSize
            // Target roughly 800x480 for widget background (balance between quality and memory)
            options.inSampleSize = calculateInSampleSize(options, 800, 480)

            // Second pass: Decode with inSampleSize
            options.inJustDecodeBounds = false
            
            if (imagePath.startsWith("assets/")) {
                val assetPath = "flutter_assets/" + imagePath
                context.assets.open(assetPath).use { 
                    BitmapFactory.decodeStream(it, null, options) 
                }
            } else {
                BitmapFactory.decodeFile(File(imagePath).absolutePath, options)
            }
        } catch (e: Exception) {
            e.printStackTrace()
            null
        } catch (e: OutOfMemoryError) {
            e.printStackTrace()
            null
        }
    }

    private fun calculateInSampleSize(options: BitmapFactory.Options, reqWidth: Int, reqHeight: Int): Int {
        val (height: Int, width: Int) = options.run { outHeight to outWidth }
        var inSampleSize = 1

        if (height > reqHeight || width > reqWidth) {
            val halfHeight: Int = height / 2
            val halfWidth: Int = width / 2

            while (halfHeight / inSampleSize >= reqHeight && halfWidth / inSampleSize >= reqWidth) {
                inSampleSize *= 2
            }
        }

        return inSampleSize
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



    private fun getCountdownData(context: Context, countdownId: String): CountdownData? {
        try {
            // Access Flutter's shared preferences
            val flutterPrefs = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
            val countdownsJson = flutterPrefs.getString("flutter.widget_countdowns", null)
            android.util.Log.d("WidgetDebug", "Raw JSON from prefs: $countdownsJson")
            
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
            val jsonArray = org.json.JSONArray(json)
            for (i in 0 until jsonArray.length()) {
                val obj = jsonArray.getJSONObject(i)
                countdowns.add(
                    CountdownData(
                        id = obj.getString("id"),
                        title = obj.getString("title"),
                        targetDate = obj.getLong("targetDate"),
                        image = if (obj.has("image")) obj.getString("image") else ""
                    )
                )
            }
        } catch (e: Exception) {
            e.printStackTrace()
            // Fallback to manual parsing if JSON is malformed but potentially recoverable? 
            // Or just log error. Better to stick to standard JSON.
        }
        return countdowns
    }

    data class CountdownData(
        val id: String,
        val title: String,
        val targetDate: Long,
        val image: String
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
    android.util.Log.d("WidgetDebug", "Saving countdown ID $countdownId for widget $appWidgetId")
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
    try {
        // Try to get global frequency first
        val flutterPrefs = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        val globalFreq = flutterPrefs.getString("flutter.global_widget_frequency", null)
        
        if (globalFreq != null && globalFreq.isNotEmpty()) {
            android.util.Log.d("WidgetDebug", "Using global frequency: $globalFreq")
            return globalFreq
        }
    } catch (e: Exception) {
        e.printStackTrace()
    }

    // Fallback to widget specific or default
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
