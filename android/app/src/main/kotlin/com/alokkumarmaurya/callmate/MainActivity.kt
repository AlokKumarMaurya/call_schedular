package com.alokkumarmaurya.callmate

import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {

    companion object {
        const val FLUTTER_ENGINE_ID = "callmate_flutter_engine"
    }

    override fun getCachedEngineId(): String {
        return FLUTTER_ENGINE_ID
    }
}