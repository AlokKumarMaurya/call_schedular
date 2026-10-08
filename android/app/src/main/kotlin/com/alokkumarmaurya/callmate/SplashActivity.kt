package com.alokkumarmaurya.callmate

import io.flutter.embedding.android.FlutterFragmentActivity

/**
 * Flutter entry activity.
 *
 * The Android launch theme is displayed while Flutter initializes.
 * FlutterActivity keeps that launch window in place until Flutter
 * renders its first frame.
 *
 * There is intentionally:
 * - no splash timer
 * - no Handler
 * - no second Activity transition
 * - no manually pre-warmed FlutterEngine
 *
 * This prevents a black screen on slower devices where Flutter may
 * take longer than an arbitrary splash duration to render.
 */
class SplashActivity : FlutterFragmentActivity()