package com.example.ai_defender_tablet;

import android.app.Activity;
import android.app.AlarmManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.util.Log;

import java.util.Objects;

public class MyExceptionHandler implements Thread.UncaughtExceptionHandler {
    private Context context;
    public MyExceptionHandler(Context c) {
        context = c;
    }
    @Override
    public void uncaughtException(Thread thread, Throwable ex) {
        Log.d("heyException", Objects.requireNonNull(ex.getMessage()));
        Intent intent = new Intent(context, MainActivity.class);
        intent.putExtra("crash", true);
        intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP
                | Intent.FLAG_ACTIVITY_CLEAR_TASK
                | Intent.FLAG_ACTIVITY_NEW_TASK);
        PendingIntent pendingIntent = PendingIntent.getActivity(context.getApplicationContext(), 0, intent, PendingIntent.FLAG_ONE_SHOT | PendingIntent.FLAG_IMMUTABLE);
        AlarmManager mgr = (AlarmManager) context.getApplicationContext().getSystemService(Context.ALARM_SERVICE);
        mgr.set(AlarmManager.RTC, System.currentTimeMillis() + 100, pendingIntent);
    }
}