package com.alokkumarmaurya.callmate

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

class CallmateWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.callmate_widget).apply {
                val launchIntent = HomeWidgetLaunchIntent.getActivity(context, SplashActivity::class.java)
                setOnClickPendingIntent(R.id.callmate_widget_root, launchIntent)
                setTextViewText(R.id.callmate_widget_next_name, widgetData.getString("widget_next_name", "No upcoming calls") ?: "No upcoming calls")
                setTextViewText(R.id.callmate_widget_next_time, widgetData.getString("widget_next_time", "Schedule a call from Callmate") ?: "Schedule a call from Callmate")
                setTextViewText(R.id.callmate_widget_next_phone, widgetData.getString("widget_next_phone", "") ?: "")
                setTextViewText(R.id.callmate_widget_count, widgetData.getInt("widget_upcoming_count", 0).toString() + " upcoming")
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}