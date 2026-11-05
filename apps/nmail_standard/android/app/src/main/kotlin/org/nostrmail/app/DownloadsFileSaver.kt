package org.nostrmail.app

import android.content.ContentValues
import android.content.Context
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import java.io.File
import java.io.FileOutputStream
import java.io.OutputStream

object DownloadsFileSaver {
    // Bidi overrides can make "fodne.pdf" render as "note.pdf"; controls and
    // separators never belong in a name.
    private val unsuitableChars = Regex(
        "[\\u0000-\\u001f\\u007f\\u202a-\\u202e\\u2066-\\u2069\\u200e\\u200f\\u2028\\u2029]"
    )
    private val reservedWindowsNames = setOf(
        "CON", "PRN", "AUX", "NUL",
        "COM1", "COM2", "COM3", "COM4", "COM5", "COM6", "COM7", "COM8", "COM9",
        "LPT1", "LPT2", "LPT3", "LPT4", "LPT5", "LPT6", "LPT7", "LPT8", "LPT9"
    )

    /// Attachment names come from outside; make them safe before any File()
    /// or MediaStore DISPLAY_NAME sees them.
    private fun sanitizeFileName(name: String): String {
        var s = unsuitableChars.replace(name, "")
        s = s.replace(Regex("[/\\\\]"), "_").trim()
        if (s.isEmpty() || s == "." || s == "..") s = "attachment"
        val ext = s.substringAfterLast('.', "")
        if (s.length > 255) {
            // A pathological extension can alone exceed the cap; truncate the
            // whole name then, extension and all.
            s = if (ext.length >= 252) {
                s.take(255)
            } else {
                val stem = s.take(254 - ext.length)
                if (ext.isNotEmpty()) "$stem.$ext" else stem
            }
        }
        val stem = s.substringBeforeLast('.').uppercase()
        if (stem in reservedWindowsNames) s = "_$s"
        return s
    }

    fun saveToDownloads(context: Context, fileName: String, bytes: ByteArray, mimeType: String): String {
        val safe = sanitizeFileName(fileName)
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            saveWithMediaStoreApi(context, safe, bytes, mimeType)
        } else {
            saveDirectly(safe, bytes)
        }
    }

    private fun saveWithMediaStoreApi(context: Context, fileName: String, bytes: ByteArray, mimeType: String): String {
        val contentValues = ContentValues().apply {
            put(MediaStore.Downloads.DISPLAY_NAME, fileName)
            put(MediaStore.Downloads.MIME_TYPE, mimeType)
            put(MediaStore.Downloads.IS_PENDING, 1)
        }

        val resolver = context.contentResolver
        val uri = resolver.insert(MediaStore.Downloads.EXTERNAL_CONTENT_URI, contentValues)
            ?: throw Exception("Failed to create MediaStore entry")

        try {
            val outputStream: OutputStream = resolver.openOutputStream(uri)
                ?: throw Exception("Failed to open output stream")
            outputStream.use { stream ->
                stream.write(bytes)
                stream.flush()
            }

            contentValues.clear()
            contentValues.put(MediaStore.Downloads.IS_PENDING, 0)
            resolver.update(uri, contentValues, null, null)
        } catch (e: Exception) {
            // Clean up the entry if something goes wrong.
            resolver.delete(uri, null, null)
            throw e
        }

        return "Downloads/$fileName"
    }

    private fun saveDirectly(fileName: String, bytes: ByteArray): String {
        val downloadsDir = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS)
        if (!downloadsDir.exists()) {
            downloadsDir.mkdirs()
        }

        val file = File(downloadsDir, fileName)
        FileOutputStream(file).use { it.write(bytes) }

        return file.absolutePath
    }
}
