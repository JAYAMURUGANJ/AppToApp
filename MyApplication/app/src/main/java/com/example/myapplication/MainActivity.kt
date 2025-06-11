// Improved MainActivity with better error handling and data sending
package com.example.myapplication

import android.annotation.SuppressLint
import android.content.Context
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.util.Log
import android.widget.Toast
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Button
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.example.myapplication.ui.theme.MyApplicationTheme
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.delay

class MainActivity : ComponentActivity() {

    companion object {
        const val TAG = "MainActivity"
        internal const val CHANNEL_NAME = "com.example.myapplication/data"
        internal const val DATA_SEND_DELAY = 800L // Reduced delay
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()

        setContent {
            MyApplicationTheme {
                Surface(modifier = Modifier.fillMaxSize()) {
                    MainScreen()
                }
            }
        }
    }
}

@Composable
fun MainScreen() {
    var isFlutterReady by remember { mutableStateOf(false) }

    // Check Flutter engine status periodically
    LaunchedEffect(Unit) {
        while (true) {
            isFlutterReady = checkFlutterEngineReady()
            delay(2000) // Check every 2 seconds
        }
    }

    Column(
        modifier = Modifier.fillMaxSize(),
        verticalArrangement = Arrangement.spacedBy(24.dp, Alignment.CenterVertically),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {

        // Title Card
        Card(
            modifier = Modifier
                .fillMaxWidth(0.9f)
                .padding(16.dp),
            elevation = CardDefaults.cardElevation(defaultElevation = 8.dp)
        ) {
            Column(
                modifier = Modifier.padding(24.dp),
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                Text(
                    text = "Flutter Integration Demo",
                    style = MaterialTheme.typography.headlineMedium,
                    fontWeight = FontWeight.Bold
                )
                Text(
                    text = "Launch Flutter screens from native Android",
                    style = MaterialTheme.typography.bodyMedium,
                    modifier = Modifier.padding(top = 8.dp)
                )
            }
        }

        // Flutter Launch Buttons
        LauncherFlutterButton(
            title = "Launch Flutter Home",
            isReady = isFlutterReady,
            onRefreshReady = { isFlutterReady = checkFlutterEngineReady() }
        )

        SendDataFlutterApp(
            title = "Send Data To Flutter App",
            isReady = isFlutterReady,
            onRefreshReady = { isFlutterReady = checkFlutterEngineReady() }
        )

        // Status indicator
        Text(
            text = if (isFlutterReady) "✅ Flutter Engine Ready" else "⚠️ Flutter Engine Not Ready",
            style = MaterialTheme.typography.bodySmall,
            color = if (isFlutterReady) MaterialTheme.colorScheme.primary else MaterialTheme.colorScheme.error
        )
    }
}

@Composable
fun LauncherFlutterButton(
    title: String = "Launch Flutter Activity",
    isReady: Boolean = true,
    onRefreshReady: () -> Unit = {},
    @SuppressLint("ModifierParameter") modifier: Modifier = Modifier
) {
    val context = LocalContext.current

    Button(
        onClick = {
            try {
                if (isReady) {
                    launchFlutterActivity(context, title)
                } else {
                    showEngineNotReadyMessage(context, onRefreshReady)
                }
            } catch (e: Exception) {
                handleLaunchError(context, e)
            }
        },
        enabled = isReady,
        modifier = modifier
            .padding(horizontal = 16.dp)
            .fillMaxWidth(0.8f)
    ) {
        Text(text = title)
    }
}

@Composable
fun SendDataFlutterApp(
    title: String = "Send Data To Flutter App",
    isReady: Boolean = true,
    onRefreshReady: () -> Unit = {},
    @SuppressLint("ModifierParameter") modifier: Modifier = Modifier
) {
    val context = LocalContext.current

    Button(
        onClick = {
            try {
                if (isReady) {
                    launchFlutterActivityWithData(context)
                } else {
                    showEngineNotReadyMessage(context, onRefreshReady)
                }
            } catch (e: Exception) {
                handleLaunchError(context, e)
            }
        },
        enabled = isReady,
        modifier = modifier
            .padding(horizontal = 16.dp)
            .fillMaxWidth(0.8f)
    ) {
        Text(text = title)
    }
}

// Helper functions for better code organization
private fun launchFlutterActivity(context: Context, title: String) {
    val intent = FlutterActivity
        .withCachedEngine(AddFlutterApp.FLUTTER_ENGINE_NAME)
        .build(context)
    context.startActivity(intent)
    Log.d(MainActivity.TAG, "Launched Flutter Activity: $title")
}

private fun launchFlutterActivityWithData(context: Context) {
    Toast.makeText(context, "Launching Flutter with data...", Toast.LENGTH_SHORT).show()

    // Launch Flutter Activity
    launchFlutterActivity(context, "Flutter with Data")

    // Send data after launch
    sendDataToFlutter(context)
}

private fun sendDataToFlutter(context: Context) {
    val flutterEngine = FlutterEngineCache.getInstance()
        .get(AddFlutterApp.FLUTTER_ENGINE_NAME)

    if (flutterEngine == null) {
        Log.e(MainActivity.TAG, "FlutterEngine not found in cache")
        Toast.makeText(context, "Flutter engine not available", Toast.LENGTH_SHORT).show()
        return
    }

    val channel = MethodChannel(
        flutterEngine.dartExecutor.binaryMessenger,
        MainActivity.CHANNEL_NAME
    )

    // Wait for Flutter to be ready before sending data
    Handler(Looper.getMainLooper()).postDelayed({
        checkFlutterReadiness(channel) { isReady ->
            if (isReady) {
                val dataMap = createSampleData()
                sendDataWithCallback(channel, dataMap, context)
            } else {
                Log.w(MainActivity.TAG, "Flutter not ready, sending data anyway")
                val dataMap = createSampleData()
                sendDataWithCallback(channel, dataMap, context)
            }
        }
    }, MainActivity.DATA_SEND_DELAY)
}

private fun checkFlutterReadiness(channel: MethodChannel, callback: (Boolean) -> Unit) {
    channel.invokeMethod("isReady", null, object : MethodChannel.Result {
        override fun success(result: Any?) {
            Log.d(MainActivity.TAG, "Flutter confirmed ready")
            callback(true)
        }

        override fun error(
            errorCode: String,
            errorMessage: String?,
            errorDetails: Any?
        ) {
            Log.w(MainActivity.TAG, "Flutter readiness check failed: $errorMessage")
            callback(false)
        }

        override fun notImplemented() {
            Log.w(MainActivity.TAG, "Flutter readiness check not implemented")
            callback(false)
        }
    })
}

private fun sendDataWithCallback(channel: MethodChannel, data: Map<String, Any>, context: Context) {
    channel.invokeMethod("sendData", data, object : MethodChannel.Result {
        override fun success(result: Any?) {
            Log.i(MainActivity.TAG, "Data sent successfully to Flutter: $result")
            Toast.makeText(context, "Data sent successfully!", Toast.LENGTH_SHORT).show()
        }

        override fun error(
            errorCode: String,
            errorMessage: String?,
            errorDetails: Any?
        ) {
            Log.e(MainActivity.TAG, "Failed to send data to Flutter: $errorMessage")
            Toast.makeText(context, "Failed to send data: $errorMessage", Toast.LENGTH_LONG).show()
        }

        override fun notImplemented() {
            Log.w(MainActivity.TAG, "sendData method not implemented in Flutter")
            Toast.makeText(context, "Data sending not supported by Flutter", Toast.LENGTH_SHORT).show()
        }
    })
}

private fun createSampleData(): Map<String, Any> {
    return mapOf(
        "userId" to "USER_${System.currentTimeMillis() % 10000}",
        "userName" to "John Doe",
        "isLoggedIn" to true,
        "timestamp" to System.currentTimeMillis(),
        "deviceInfo" to mapOf(
            "platform" to "Android",
            "version" to android.os.Build.VERSION.RELEASE
        ),
        "settings" to mapOf(
            "theme" to "dark",
            "notifications" to true,
            "language" to "en"
        ),
        "sessionData" to mapOf(
            "startTime" to System.currentTimeMillis(),
            "source" to "native_android"
        )
    )
}

private fun showEngineNotReadyMessage(context: Context, onRefreshReady: () -> Unit) {
    Toast.makeText(context, "Flutter engine not ready. Please wait...", Toast.LENGTH_SHORT).show()
    onRefreshReady()
}

private fun handleLaunchError(context: Context, e: Exception) {
    Log.e(MainActivity.TAG, "Failed to launch Flutter Activity", e)
    Toast.makeText(context, "Failed to launch Flutter: ${e.message}", Toast.LENGTH_LONG).show()
}

// Helper function to check if Flutter engine is ready
fun checkFlutterEngineReady(): Boolean {
    return try {
        val engine = FlutterEngineCache.getInstance().get(AddFlutterApp.FLUTTER_ENGINE_NAME)
        val isReady = engine != null && engine.dartExecutor.isExecutingDart
        Log.d(MainActivity.TAG, "Flutter engine ready: $isReady")
        isReady
    } catch (e: Exception) {
        Log.e(MainActivity.TAG, "Error checking Flutter engine status", e)
        false
    }
}

@Preview(showBackground = true)
@Composable
fun MainScreenPreview() {
    MyApplicationTheme {
        Surface {
            MainScreen()
        }
    }
}