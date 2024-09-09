package com.example.ai_defender_tablet.receiver

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log
import com.example.ai_defender_tablet.MainActivity

class StartOnBootReceiver : BroadcastReceiver() {
    private val logTag = StartOnBootReceiver::class.java.simpleName
    override fun onReceive(context: Context, intent: Intent) {
        if (Intent.ACTION_BOOT_COMPLETED == intent.action) {
            Log.d(logTag,"ACTION_BOOT_COMPLETED: Started App")
            val activityIntent = Intent(context, MainActivity::class.java)
            activityIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            context.startActivity(activityIntent)
        }
    }
}