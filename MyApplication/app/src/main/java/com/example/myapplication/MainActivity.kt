// Improved MainActivity with better error handling
package com.example.myapplication

import android.annotation.SuppressLint
import android.content.Intent
import android.os.Bundle
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

class MainActivity : ComponentActivity() {

    companion object {
        const val TAG = "MainActivity"
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
    val context = LocalContext.current
    var isFlutterReady by remember { mutableStateOf(checkFlutterEngineReady()) }

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

        LauncherFlutterButton(
            title = "Launch Flutter Settings",
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
                    val intent = FlutterActivity
                        .withCachedEngine(AddFlutterApp.FLUTTER_ENGINE_NAME)
                        .build(context)
                    context.startActivity(intent)
                    Log.d("MainActivity", "Launched Flutter Activity: $title")
                } else {
                    Toast.makeText(context, "Flutter engine not ready. Please wait...", Toast.LENGTH_SHORT).show()
                    onRefreshReady()
                }
            } catch (e: Exception) {
                Log.e("MainActivity", "Failed to launch Flutter Activity", e)
                Toast.makeText(context, "Failed to launch Flutter: ${e.message}", Toast.LENGTH_LONG).show()
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

// Helper function to check if Flutter engine is ready
fun checkFlutterEngineReady(): Boolean {
    return try {
        FlutterEngineCache.getInstance().get(AddFlutterApp.FLUTTER_ENGINE_NAME) != null
    } catch (e: Exception) {
        Log.e("MainActivity", "Error checking Flutter engine status", e)
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