package org.nostrmail.app

import android.content.ClipData
import android.content.ClipDescription
import android.content.ClipboardManager
import android.content.Context
import android.os.Build
import android.os.PersistableBundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "app.nostrmail.client/native"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "saveToDownloads" -> {
                    val fileName = call.argument<String>("fileName")
                    val bytes = call.argument<ByteArray>("bytes")
                    val mimeType = call.argument<String>("mimeType") ?: "application/octet-stream"

                    try {
                        if (fileName != null && bytes != null) {
                            val savedPath = DownloadsFileSaver.saveToDownloads(this, fileName, bytes, mimeType)
                            result.success(savedPath)
                        } else {
                            result.error("INVALID_ARGUMENTS", "fileName and bytes are required", null)
                        }
                    } catch (e: Exception) {
                        result.error("SAVE_FAILED", e.message, null)
                    }
                }
                "copySensitive" -> {
                    val text = call.argument<String>("text")
                    val label = call.argument<String>("label") ?: "text"
                    try {
                        if (text != null) {
                            copySensitive(text, label)
                            result.success(null)
                        } else {
                            result.error("INVALID_ARGUMENTS", "text is required", null)
                        }
                    } catch (e: Exception) {
                        result.error("COPY_FAILED", e.message, null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun copySensitive(text: String, label: String) {
        val clipboard = getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager
        val clip = ClipData.newPlainText(label, text)
        // Mark the clip as sensitive so the system clipboard preview shows dots
        // instead of the actual content (Android 13+ / API 33+).
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            clip.description.extras = PersistableBundle().apply {
                putBoolean(ClipDescription.EXTRA_IS_SENSITIVE, true)
            }
        }
        clipboard.setPrimaryClip(clip)
    }
}
