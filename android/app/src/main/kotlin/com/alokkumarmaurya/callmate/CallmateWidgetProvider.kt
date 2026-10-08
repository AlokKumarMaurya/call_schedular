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
                val pendingIntent = HomeWidgetLaunchIntent.getActivity(context, SplashActivity::class.java)
                setOnClickPendingIntent(R.id.callmate_widget_root, pendingIntent)

                val nextName = widgetData.getString("widget_next_name", "No upcoming calls") ?: "No upcoming calls"
                val nextTime = widgetData.getString("widget_next_time", "Open Callmate to schedule a call") ?: "Open Callmate to schedule a call"
                val nextPhone = widgetData.getString("widget_next_phone", "") ?: ""
                val upcomingCount = widgetData.getInt("widget_upcoming_count", 0)

                setTextViewText(R.id.callmate_widget_next_name, nextName)
                setTextViewText(R.id.callmate_widget_next_time, nextTime)
                setTextViewText(R.id.callmate_widget_next_phone, nextPhone)
                setTextViewText(R.id.callmate_widget_count, "$upcomingCount upcoming")
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
