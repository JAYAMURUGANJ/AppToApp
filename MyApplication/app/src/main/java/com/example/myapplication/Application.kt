
package com.example.myapplication

import android.app.Application
import android.util.Log
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.embedding.engine.dart.DartExecutor

class AddFlutterApp : Application() {

    companion object {
        const val FLUTTER_ENGINE_NAME = "nps_flutter_engine"
        const val TAG = "AddFlutterApp"
    }

    override fun onCreate() {
        super.onCreate()
        initializeFlutterEngine()
    }

    private fun initializeFlutterEngine() {
        try {
            // Create and configure FlutterEngine
            val flutterEngine = FlutterEngine(this)

            // Execute Dart entrypoint
            flutterEngine.dartExecutor.executeDartEntrypoint(
                DartExecutor.DartEntrypoint.createDefault()
            )

            // Cache the FlutterEngine for reuse with FlutterActivity
            FlutterEngineCache.getInstance().put(FLUTTER_ENGINE_NAME, flutterEngine)

            Log.d(TAG, "Application onCreate - Flutter engine initialized and cached successfully")
        } catch (e: Exception) {
            Log.e(TAG, "Failed to initialize Flutter engine", e)
        }
    }

    override fun onTerminate() {
        super.onTerminate()
        Log.d(TAG, "Application onTerminate - cleaning up Flutter resources")

        // Clean up cached engine
        try {
            FlutterEngineCache.getInstance().remove(FLUTTER_ENGINE_NAME)
        } catch (e: Exception) {
            Log.e(TAG, "Error cleaning up Flutter engine", e)
        }
    }

    @Deprecated("Deprecated in Java")
    override fun onLowMemory() {
        super.onLowMemory()
        Log.w(TAG, "Low memory warning - Flutter engine may be affected")
    }

    override fun onTrimMemory(level: Int) {
        super.onTrimMemory(level)
        Log.d(TAG, "Memory trim requested with level: $level")
    }
}
