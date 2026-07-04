package app.nostrmail.client

import android.content.ContentValues
import android.content.Context
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import java.io.File
import java.io.FileOutputStream
import java.io.OutputStream

object DownloadsFileSaver {
    fun saveToDownloads(context: Context, fileName: String, bytes: ByteArray, mimeType: String): String {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            saveWithMediaStoreApi(context, fileName, bytes, mimeType)
        } else {
            saveDirectly(fileName, bytes)
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
