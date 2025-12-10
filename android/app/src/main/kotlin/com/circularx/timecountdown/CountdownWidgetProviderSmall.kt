package com.circularx.timecountdown

import android.content.Context
import android.appwidget.AppWidgetManager
import android.content.Intent

class CountdownWidgetProviderSmall : CountdownWidgetProvider() {
    
    override fun getLayoutId(): Int {
        return R.layout.countdown_widget_small
    }
}
