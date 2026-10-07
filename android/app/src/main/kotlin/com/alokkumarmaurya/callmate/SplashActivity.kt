package com.alokkumarmaurya.callmate

import android.app.Activity
import android.content.Intent
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.embedding.engine.dart.DartExecutor

class SplashActivity : Activity() {

    companion object {
        private const val FLUTTER_ENGINE_ID = "callmate_flutter_engine"
        private const val SPLASH_DURATION = 1500L
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        /*
         * Start Flutter while the native splash is visible.
         *
         * The Flutter engine will execute main.dart in the
         * background while this Activity continues displaying
         * the native splash.
         */
        prewarmFlutterEngine()

        Handler(Looper.getMainLooper()).postDelayed({

            /*
             * IMPORTANT:
             *
             * Launch our declared MainActivity, not FlutterActivity.
             *
             * MainActivity already knows how to attach to the
             * cached Flutter engine through getCachedEngineId().
             */
            val intent = Intent(
                this,
                MainActivity::class.java
            ).apply {
                addFlags(Intent.FLAG_ACTIVITY_NO_ANIMATION)
            }

            startActivity(intent)

            /*
             * Remove the Activity transition animation so the
             * native splash does not blink during the transition
             * to Flutter.
             */
            @Suppress("DEPRECATION")
            overridePendingTransition(0, 0)

            finish()

            @Suppress("DEPRECATION")
            overridePendingTransition(0, 0)

        }, SPLASH_DURATION)
    }

    private fun prewarmFlutterEngine() {

        /*
         * Do not create another engine if one is already cached.
         *
         * This protects against Activity recreation.
         */
        if (
            FlutterEngineCache
                .getInstance()
                .contains(FLUTTER_ENGINE_ID)
        ) {
            return
        }

        val flutterEngine = FlutterEngine(this)

        /*
         * Start Dart main() immediately.
         *
         * Flutter initialization happens while the native
         * splash is still visible.
         */
        flutterEngine
            .dartExecutor
            .executeDartEntrypoint(
                DartExecutor.DartEntrypoint.createDefault()
            )

        /*
         * Store the running engine.
         *
         * MainActivity will retrieve this engine using
         * getCachedEngineId().
         */
        FlutterEngineCache
            .getInstance()
            .put(
                FLUTTER_ENGINE_ID,
                flutterEngine
            )
    }
}