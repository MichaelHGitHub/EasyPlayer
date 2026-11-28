package com.pandasoft.easyplayer

import android.app.Activity
import android.content.ContentValues
import android.content.ContentUris
import android.content.Intent
import android.database.Cursor
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.provider.DocumentsContract
import android.provider.MediaStore
import com.ryanheise.audioservice.AudioServiceActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: AudioServiceActivity() {
    private val CHANNEL = "com.pandasoft.easyplayer/app"
    private val PICK_FILE_REQUEST_CODE = 9988
    private var pendingResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "moveToBackground" -> {
                    moveTaskToBack(true)
                    result.success(true)
                }
                "pickMediaFile" -> {
                    if (pendingResult != null) {
                        result.error("BUSY", "File picker is already active", null)
                        return@setMethodCallHandler
                    }
                    pendingResult = result
                    try {
                        val intent = Intent(Intent.ACTION_OPEN_DOCUMENT).apply {
                            addCategory(Intent.CATEGORY_OPENABLE)
                            type = "*/*"
                            putExtra(Intent.EXTRA_MIME_TYPES, arrayOf("audio/*", "video/*"))
                        }
                        startActivityForResult(intent, PICK_FILE_REQUEST_CODE)
                    } catch (e: Exception) {
                        pendingResult = null
                        result.error("ERROR", "Failed to launch picker: ${e.message}", null)
                    }
                }
                "extractAudio" -> {
                    val inputPath = call.argument<String>("inputPath")
                    val outputPath = call.argument<String>("outputPath")
                    if (inputPath != null && outputPath != null) {
                        Thread {
                            val success = AudioExtractor.extractAudioToWav(context, inputPath, outputPath)
                            runOnUiThread {
                                result.success(success)
                            }
                        }.start()
                    } else {
                        result.error("INVALID_ARGS", "inputPath and outputPath required", null)
                    }
                }
                "saveScreenshot" -> {
                    val fileName = call.argument<String>("fileName")
                    val bytes = call.argument<ByteArray>("bytes")
                    if (fileName.isNullOrBlank() || bytes == null || bytes.isEmpty()) {
                        result.error("INVALID_ARGS", "fileName and image bytes are required", null)
                    } else {
                        saveScreenshot(fileName, bytes, result)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == PICK_FILE_REQUEST_CODE) {
            val result = pendingResult
            pendingResult = null
            if (resultCode == Activity.RESULT_OK && data?.data != null) {
                val uri = data.data!!
                val realPath = getPathFromUri(uri)
                result?.success(realPath ?: uri.toString())
            } else {
                result?.success(null)
            }
        }
    }

    private fun getPathFromUri(uri: Uri): String? {
        try {
            // 1. DocumentProvider
            if (DocumentsContract.isDocumentUri(context, uri)) {
                // ExternalStorageProvider
                if ("com.android.externalstorage.documents" == uri.authority) {
                    val docId = DocumentsContract.getDocumentId(uri)
                    val split = docId.split(":".toRegex()).toTypedArray()
                    val type = split[0]
                    if ("primary".equals(type, ignoreCase = true)) {
                        return Environment.getExternalStorageDirectory().toString() + "/" + (if (split.size > 1) split[1] else "")
                    } else {
                        val storageDir = System.getenv("SECONDARY_STORAGE") ?: "/storage/$type"
                        return "$storageDir/${if (split.size > 1) split[1] else ""}"
                    }
                }
                // DownloadsProvider
                else if ("com.android.providers.downloads.documents" == uri.authority) {
                    val id = DocumentsContract.getDocumentId(uri)
                    if (id.startsWith("raw:")) {
                        return id.replaceFirst("raw:".toRegex(), "")
                    }
                    return try {
                        val contentUri = ContentUris.withAppendedId(
                            Uri.parse("content://downloads/public_downloads"), java.lang.Long.valueOf(id)
                        )
                        getDataColumn(contentUri, null, null)
                    } catch (e: Exception) {
                        null
                    }
                }
                // MediaProvider
                else if ("com.android.providers.media.documents" == uri.authority) {
                    val docId = DocumentsContract.getDocumentId(uri)
                    val split = docId.split(":".toRegex()).toTypedArray()
                    val type = split[0]
                    var contentUri: Uri? = null
                    when (type) {
                        "image" -> contentUri = MediaStore.Images.Media.EXTERNAL_CONTENT_URI
                        "video" -> contentUri = MediaStore.Video.Media.EXTERNAL_CONTENT_URI
                        "audio" -> contentUri = MediaStore.Audio.Media.EXTERNAL_CONTENT_URI
                    }
                    val selection = "_id=?"
                    val selectionArgs = arrayOf(if (split.size > 1) split[1] else "")
                    return getDataColumn(contentUri, selection, selectionArgs)
                }
            }
            // 2. MediaStore (and general content:// URIs)
            else if ("content".equals(uri.scheme, ignoreCase = true)) {
                return getDataColumn(uri, null, null)
            }
            // 3. File scheme
            else if ("file".equals(uri.scheme, ignoreCase = true)) {
                return uri.path
            }
        } catch (e: Exception) {
            // Ignore & fallback to null
        }
        return null
    }

    private fun getDataColumn(uri: Uri?, selection: String?, selectionArgs: Array<String>?): String? {
        if (uri == null) return null
        var cursor: Cursor? = null
        val column = "_data"
        val projection = arrayOf(column)
        try {
            cursor = contentResolver.query(uri, projection, selection, selectionArgs, null)
            if (cursor != null && cursor.moveToFirst()) {
                val columnIndex = cursor.getColumnIndex(column)
                if (columnIndex != -1) {
                    return cursor.getString(columnIndex)
                }
            }
        } catch (e: Exception) {
            // Ignore
        } finally {
            cursor?.close()
        }
        return null
    }

    private fun saveScreenshot(fileName: String, bytes: ByteArray, result: MethodChannel.Result) {
        Thread {
            var imageUri: Uri? = null
            try {
                val values = ContentValues().apply {
                    put(MediaStore.Images.Media.DISPLAY_NAME, fileName)
                    put(MediaStore.Images.Media.MIME_TYPE, "image/png")
                    put(
                        MediaStore.Images.Media.RELATIVE_PATH,
                        "${Environment.DIRECTORY_PICTURES}/Screenshots"
                    )
                    put(MediaStore.Images.Media.IS_PENDING, 1)
                }

                val uri = contentResolver.insert(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, values)
                    ?: throw java.io.IOException("Unable to create a screenshot in the system media store")
                imageUri = uri

                val output = contentResolver.openOutputStream(uri, "w")
                    ?: throw java.io.IOException("Unable to open the screenshot output stream")
                output.use { it.write(bytes) }

                val completed = ContentValues().apply {
                    put(MediaStore.Images.Media.IS_PENDING, 0)
                }
                if (contentResolver.update(uri, completed, null, null) <= 0) {
                    throw java.io.IOException("Unable to publish the screenshot to the system gallery")
                }

                val relativePath = "${Environment.DIRECTORY_PICTURES}/Screenshots/$fileName"
                runOnUiThread { result.success(relativePath) }
            } catch (error: Exception) {
                try {
                    imageUri?.let { contentResolver.delete(it, null, null) }
                } catch (cleanupError: Exception) {
                    error.addSuppressed(cleanupError)
                }
                runOnUiThread {
                    result.error("SAVE_FAILED", "Unable to save screenshot: ${error.message}", null)
                }
            }
        }.start()
    }
}
