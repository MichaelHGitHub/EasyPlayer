package com.pandasoft.easyplayer

import android.content.Context
import android.media.MediaCodec
import android.media.MediaExtractor
import android.media.MediaFormat
import android.net.Uri
import java.io.File
import java.io.FileOutputStream
import java.io.RandomAccessFile
import java.nio.ByteBuffer
import java.nio.ByteOrder

object AudioExtractor {
    fun extractAudioToWav(context: Context, inputPath: String, outputPath: String): Boolean {
        val extractor = MediaExtractor()
        var codec: MediaCodec? = null
        var fos: FileOutputStream? = null

        try {
            if (inputPath.startsWith("content://")) {
                val uri = Uri.parse(inputPath)
                val pfd = context.contentResolver.openFileDescriptor(uri, "r") ?: return false
                extractor.setDataSource(pfd.fileDescriptor)
            } else {
                val file = File(inputPath)
                if (file.exists()) {
                    extractor.setDataSource(file.absolutePath)
                } else {
                    val uri = Uri.parse(inputPath)
                    extractor.setDataSource(context, uri, null)
                }
            }

            var audioTrackIndex = -1
            var format: MediaFormat? = null
            var mime: String? = null

            for (i in 0 until extractor.trackCount) {
                val trackFormat = extractor.getTrackFormat(i)
                val trackMime = trackFormat.getString(MediaFormat.KEY_MIME) ?: ""
                if (trackMime.startsWith("audio/")) {
                    audioTrackIndex = i
                    format = trackFormat
                    mime = trackMime
                    break
                }
            }

            if (audioTrackIndex == -1 || format == null || mime == null) {
                return false
            }

            extractor.selectTrack(audioTrackIndex)
            val srcSampleRate = if (format.containsKey(MediaFormat.KEY_SAMPLE_RATE)) {
                format.getInteger(MediaFormat.KEY_SAMPLE_RATE)
            } else 44100
            val srcChannels = if (format.containsKey(MediaFormat.KEY_CHANNEL_COUNT)) {
                format.getInteger(MediaFormat.KEY_CHANNEL_COUNT)
            } else 2

            codec = MediaCodec.createDecoderByType(mime)
            codec.configure(format, null, null, 0)
            codec.start()

            val outputFile = File(outputPath)
            outputFile.parentFile?.mkdirs()
            if (outputFile.exists()) outputFile.delete()

            fos = FileOutputStream(outputFile)

            // Write 44-byte WAV header placeholder
            val headerBuffer = ByteArray(44)
            fos.write(headerBuffer)

            var totalPcmBytes = 0L

            val info = MediaCodec.BufferInfo()
            var isInputEOS = false
            var isOutputEOS = false
            val kTimeOutUs = 10000L

            val targetSampleRate = 16000
            val targetChannels = 1

            while (!isOutputEOS) {
                if (!isInputEOS) {
                    val inIndex = codec.dequeueInputBuffer(kTimeOutUs)
                    if (inIndex >= 0) {
                        val buffer = codec.getInputBuffer(inIndex)
                        if (buffer != null) {
                            val sampleSize = extractor.readSampleData(buffer, 0)
                            if (sampleSize < 0) {
                                codec.queueInputBuffer(inIndex, 0, 0, 0, MediaCodec.BUFFER_FLAG_END_OF_STREAM)
                                isInputEOS = true
                            } else {
                                val sampleTime = extractor.sampleTime
                                codec.queueInputBuffer(inIndex, 0, sampleSize, sampleTime, 0)
                                extractor.advance()
                            }
                        }
                    }
                }

                var outIndex = codec.dequeueOutputBuffer(info, kTimeOutUs)
                while (outIndex >= 0) {
                    if ((info.flags and MediaCodec.BUFFER_FLAG_END_OF_STREAM) != 0) {
                        isOutputEOS = true
                    }

                    val outBuffer = codec.getOutputBuffer(outIndex)
                    if (outBuffer != null && info.size > 0) {
                        outBuffer.position(info.offset)
                        outBuffer.limit(info.offset + info.size)

                        val chunkBytes = ByteArray(info.size)
                        outBuffer.get(chunkBytes)
                        outBuffer.clear()

                        val processedPcm = processPcmChunk(chunkBytes, srcChannels, srcSampleRate, targetSampleRate)
                        if (processedPcm.isNotEmpty()) {
                            fos.write(processedPcm)
                            totalPcmBytes += processedPcm.size
                        }
                    }
                    codec.releaseOutputBuffer(outIndex, false)
                    if (isOutputEOS) {
                        break
                    }
                    outIndex = codec.dequeueOutputBuffer(info, 0)
                }
            }

            fos.flush()
            fos.close()
            fos = null

            writeWavHeader(outputFile, totalPcmBytes.toInt(), targetSampleRate, targetChannels)

            return totalPcmBytes > 0
        } catch (e: Exception) {
            e.printStackTrace()
            return false
        } finally {
            try { codec?.stop() } catch (_: Exception) {}
            try { codec?.release() } catch (_: Exception) {}
            try { extractor.release() } catch (_: Exception) {}
            try { fos?.close() } catch (_: Exception) {}
        }
    }

    private fun processPcmChunk(srcBytes: ByteArray, channels: Int, srcRate: Int, targetRate: Int): ByteArray {
        val safeChannels = if (channels <= 0) 1 else channels
        val numSamples = srcBytes.size / (2 * safeChannels)
        if (numSamples <= 0) return ByteArray(0)

        val srcBuffer = ByteBuffer.wrap(srcBytes).order(ByteOrder.LITTLE_ENDIAN)

        val monoSamples = ShortArray(numSamples)
        for (i in 0 until numSamples) {
            var sum = 0
            for (c in 0 until safeChannels) {
                if (srcBuffer.remaining() >= 2) {
                    sum += srcBuffer.short.toInt()
                }
            }
            monoSamples[i] = (sum / safeChannels).coerceIn(-32768, 32767).toShort()
        }

        val outputSamples: ShortArray
        if (srcRate == targetRate || srcRate <= 0) {
            outputSamples = monoSamples
        } else {
            val ratio = srcRate.toDouble() / targetRate.toDouble()
            val targetLength = (numSamples / ratio).toInt()
            if (targetLength <= 0) return ByteArray(0)
            outputSamples = ShortArray(targetLength)
            for (i in 0 until targetLength) {
                val srcIdx = (i * ratio).toInt().coerceIn(0, numSamples - 1)
                outputSamples[i] = monoSamples[srcIdx]
            }
        }

        val outBytes = ByteArray(outputSamples.size * 2)
        val outBuffer = ByteBuffer.wrap(outBytes).order(ByteOrder.LITTLE_ENDIAN)
        for (s in outputSamples) {
            outBuffer.putShort(s)
        }

        return outBytes
    }

    private fun writeWavHeader(file: File, pcmDataLength: Int, sampleRate: Int, channels: Int) {
        val totalDataLen = pcmDataLength + 36
        val byteRate = sampleRate * channels * 2
        val header = ByteArray(44)
        val buffer = ByteBuffer.wrap(header).order(ByteOrder.LITTLE_ENDIAN)

        buffer.put("RIFF".toByteArray())
        buffer.putInt(totalDataLen)
        buffer.put("WAVE".toByteArray())

        buffer.put("fmt ".toByteArray())
        buffer.putInt(16)
        buffer.putShort(1.toShort())
        buffer.putShort(channels.toShort())
        buffer.putInt(sampleRate)
        buffer.putInt(byteRate)
        buffer.putShort((channels * 2).toShort())
        buffer.putShort(16.toShort())

        buffer.put("data".toByteArray())
        buffer.putInt(pcmDataLength)

        val raf = RandomAccessFile(file, "rw")
        raf.seek(0)
        raf.write(header)
        raf.close()
    }
}
