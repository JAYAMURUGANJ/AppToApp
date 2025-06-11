package com.example.myapplication

import android.app.Application
import android.util.Log
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch

class AddFlutterApp : Application() {

    companion object {
        const val FLUTTER_ENGINE_NAME = "nps_flutter_engine"
        const val TAG = "AddFlutterApp"
        private const val CHANNEL_NAME = "com.example.myapplication/data"
        private const val ENGINE_WARMUP_DELAY = 1000L
    }

    private val applicationScope = CoroutineScope(SupervisorJob() + Dispatchers.Main)
    private var flutterEngine: FlutterEngine? = null

    override fun onCreate() {
        super.onCreate()
        Log.d(TAG, "Application onCreate - Starting Flutter engine initialization")
        initializeFlutterEngine()
    }

    private fun initializeFlutterEngine() {
        try {
            // Create and configure FlutterEngine
            flutterEngine = FlutterEngine(this).also { engine ->

                // Execute Dart entrypoint
                engine.dartExecutor.executeDartEntrypoint(
                    DartExecutor.DartEntrypoint.createDefault()
                )

                // Set up method channel for native-Flutter communication
                setupMethodChannel(engine)

                // Cache the FlutterEngine for reuse with FlutterActivity
                FlutterEngineCache.getInstance().put(FLUTTER_ENGINE_NAME, engine)

                Log.d(TAG, "Flutter engine initialized and cached successfully")

                // Warm up the engine
                warmUpEngine(engine)
            }

        } catch (e: Exception) {
            Log.e(TAG, "Failed to initialize Flutter engine", e)
        }
    }

    private fun setupMethodChannel(engine: FlutterEngine) {
        try {
            val channel = MethodChannel(engine.dartExecutor.binaryMessenger, CHANNEL_NAME)

            // Set up method call handler for Flutter -> Native communication
            channel.setMethodCallHandler { call, result ->
                when (call.method) {
                    "getNativeData" -> {
                        val data = mapOf(
                            "appVersion" to android.os.Build.VERSION.RELEASE,
                            "platform" to "Android",
                            "timestamp" to System.currentTimeMillis()
                        )
                        result.success(data)
                    }
                    "logMessage" -> {
                        val message = call.argument<String>("message") ?: "No message"
                        Log.i(TAG, "Flutter log: $message")
                        result.success("Message logged")
                    }
                    else -> {
                        result.notImplemented()
                    }
                }
            }

            Log.d(TAG, "Method channel setup completed")
        } catch (e: Exception) {
            Log.e(TAG, "Failed to setup method channel", e)
        }
    }

    private fun warmUpEngine(engine: FlutterEngine) {
        applicationScope.launch {
            try {
                // Wait for engine to be fully ready
                delay(ENGINE_WARMUP_DELAY)

                if (engine.dartExecutor.isExecutingDart) {
                    val channel = MethodChannel(engine.dartExecutor.binaryMessenger, CHANNEL_NAME)

                    // Send a warmup message to Flutter
                    channel.invokeMethod("warmup", mapOf(
                        "source" to "native_warmup",
                        "timestamp" to System.currentTimeMillis()
                    ), object : MethodChannel.Result {


                        override fun success(result: Any?) {
                            Log.d(TAG, "Flutter engine warmup successful: $result")
                        }

                        override fun error(
                            errorCode: String,
                            errorMessage: String?,
                            errorDetails: Any?
                        ) {
                            Log.w(TAG, "Flutter engine warmup failed: $errorMessage")
                        }

                        override fun notImplemented() {
                            Log.d(TAG, "Flutter warmup method not implemented (expected)")
                        }
                    })
                } else {
                    Log.w(TAG, "Dart executor not ready for warmup")
                }
            } catch (e: Exception) {
                Log.e(TAG, "Error during engine warmup", e)
            }
        }
    }

    override fun onTerminate() {
        super.onTerminate()
        Log.d(TAG, "Application onTerminate - cleaning up Flutter resources")
        cleanupResources()
    }

    override fun onTrimMemory(level: Int) {
        super.onTrimMemory(level)
        Log.d(TAG, "Memory trim requested with level: $level")

        when (level) {

            // Background states - less critical
            TRIM_MEMORY_BACKGROUND -> {
                Log.d(TAG, "BACKGROUND: App went to background, normal memory management")
                handleBackgroundMemory()
            }

            TRIM_MEMORY_UI_HIDDEN -> {
                Log.d(TAG, "UI_HIDDEN: App UI is no longer visible, can release UI resources")
                handleUIHidden()
            }

            else -> {
                Log.d(TAG, "Unknown memory trim level: $level")
            }
        }
    }

    @Deprecated("Deprecated in Java", ReplaceWith("onTrimMemory"))
    override fun onLowMemory() {
        super.onLowMemory()
        Log.w(TAG, "Low memory warning - Flutter engine may be affected")
    }

    private fun cleanupResources() {
        try {
            // Cancel all coroutines
            applicationScope.cancel()

            // Clean up cached engine
            FlutterEngineCache.getInstance().remove(FLUTTER_ENGINE_NAME)

            // Clean up engine reference
            flutterEngine?.destroy()
            flutterEngine = null

            Log.d(TAG, "Flutter resources cleaned up successfully")
        } catch (e: Exception) {
            Log.e(TAG, "Error cleaning up Flutter engine", e)
        }
    }

    private fun handleBackgroundMemory() {
        Log.d(TAG, "Handling BACKGROUND memory - normal background state")
        try {
            // Normal background state - minimal cleanup
            flutterEngine?.let { engine ->
                if (engine.dartExecutor.isExecutingDart) {
                    val channel = MethodChannel(engine.dartExecutor.binaryMessenger, CHANNEL_NAME)
                    channel.invokeMethod("onBackground", mapOf("memoryPressure" to "normal"))
                }
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error handling background memory", e)
        }
    }

    private fun handleUIHidden() {
        Log.d(TAG, "Handling UI_HIDDEN - UI resources can be released")
        try {
            // UI is hidden, can release UI-related resources
            flutterEngine?.let { engine ->
                if (engine.dartExecutor.isExecutingDart) {
                    val channel = MethodChannel(engine.dartExecutor.binaryMessenger, CHANNEL_NAME)
                    channel.invokeMethod("onUIHidden", null)
                }
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error handling UI hidden", e)
        }
    }


}