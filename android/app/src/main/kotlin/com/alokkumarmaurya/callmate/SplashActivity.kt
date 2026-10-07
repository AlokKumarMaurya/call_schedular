package com.alokkumarmaurya.callmate

import android.app.Activity
import android.content.Intent
import android.os.Bundle
import android.os.Handler
import android.os.Looper

class SplashActivity : Activity() {

    private val splashDuration = 1500L

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // The splash image is already provided by SplashTheme's
        // windowBackground. Do not set another content view here.
        //
        // This prevents the same splash image from being rendered twice
        // and removes the small visual blink.

        Handler(Looper.getMainLooper()).postDelayed({

            val intent = Intent(this, MainActivity::class.java).apply {
                addFlags(Intent.FLAG_ACTIVITY_NO_ANIMATION)
            }

            startActivity(intent)

            // Prevent the native Activity transition animation.
            @Suppress("DEPRECATION")
            overridePendingTransition(0, 0)

            finish()

            @Suppress("DEPRECATION")
            overridePendingTransition(0, 0)

        }, splashDuration)
    }
}