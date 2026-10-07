package com.alokkumarmaurya.callmate

import android.app.Activity
import android.content.Intent
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import io.flutter.embedding.android.FlutterActivity
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
         * Start the Flutter engine immediately while the native
         * splash screen is visible.
         *
         * This removes the engine startup delay that was previously
         * happening after SplashActivity finished.
         */
        prewarmFlutterEngine()

        /*
         * Keep the existing splash duration.
         *
         * During this time:
         *
         * Native splash is visible
         *        +
         * Flutter engine is starting in the background
         */
        Handler(Looper.getMainLooper()).postDelayed({

            val intent = FlutterActivity
                .withCachedEngine(FLUTTER_ENGINE_ID)
                .destroyEngineWithActivity(false)
                .build(this)

            intent.addFlags(Intent.FLAG_ACTIVITY_NO_ANIMATION)

            startActivity(intent)

            @Suppress("DEPRECATION")
            overridePendingTransition(0, 0)

            finish()

            @Suppress("DEPRECATION")
            overridePendingTransition(0, 0)

        }, SPLASH_DURATION)
    }

    private fun prewarmFlutterEngine() {

        /*
         * Do not create the engine more than once.
         *
         * This can happen if Android recreates the Activity.
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
         * main.dart will:
         *
         * 1. Initialize GetStorage
         * 2. Initialize AppThemeController
         * 3. Initialize AppDI
         * 4. runApp()
         * 5. Initialize notifications after the first frame
         */
        flutterEngine
            .dartExecutor
            .executeDartEntrypoint(
                DartExecutor.DartEntrypoint.createDefault()
            )

        /*
         * Store the already-running engine so MainActivity can
         * attach to it instead of creating a new FlutterEngine.
         */
        FlutterEngineCache
            .getInstance()
            .put(
                FLUTTER_ENGINE_ID,
                flutterEngine
            )
    }
}