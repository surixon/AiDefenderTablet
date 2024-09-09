package com.example.ai_defender_tablet
import android.app.Application


class MyApp : Application() {
    override fun onCreate() {
        super.onCreate()
        Thread.setDefaultUncaughtExceptionHandler( MyExceptionHandler(this));
    }


}