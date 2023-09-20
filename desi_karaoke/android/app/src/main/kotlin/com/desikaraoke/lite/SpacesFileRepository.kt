package com.desikaraoke.lite

import android.content.Context
import android.util.Log
import com.amazonaws.HttpMethod
import com.amazonaws.auth.BasicAWSCredentials
import com.amazonaws.internal.StaticCredentialsProvider
import com.amazonaws.mobileconnectors.s3.transferutility.TransferListener
import com.amazonaws.mobileconnectors.s3.transferutility.TransferNetworkLossHandler
import com.amazonaws.mobileconnectors.s3.transferutility.TransferState
import com.amazonaws.mobileconnectors.s3.transferutility.TransferUtility
import com.amazonaws.regions.Region
import com.amazonaws.services.s3.AmazonS3Client
import com.amazonaws.services.s3.model.GeneratePresignedUrlRequest
import java.io.File
import java.net.URL


interface SpaceRegionRepresentable {
    fun endpoint(): String
}

/**
 * Represents a region in which a Digital Ocean Space can be created
 */
enum class SpaceRegion : SpaceRegionRepresentable {
    SFO {
        override fun endpoint(): String {
            return "https://sfo2.digitaloceanspaces.com"
        }
    },
    AMS {
        override fun endpoint(): String {
            return "https://ams3.digitaloceanspaces.com"
        }
    },
    SGP {
        override fun endpoint(): String {
            return "https://sgp1.digitaloceanspaces.com"
        }
    }
}

class SpacesFileRepository(context: Context) {
    private val accessKey = "MX63A2B35TQPORPAONDQ"
    private val secretKey = "JQQ6c+G4hxKqOvZ7kuEpM08KfmVnToLrdw7BI9c6y0U"
    private val spaceName = "d-karaoke"
    private val spaceRegion = SpaceRegion.SGP
    private var client: AmazonS3Client

    private var transferUtility: TransferUtility
    private var appContext: Context

    init {
        TransferNetworkLossHandler.getInstance(context)
        val credentials = StaticCredentialsProvider(BasicAWSCredentials(accessKey, secretKey))
        client = AmazonS3Client(credentials, Region.getRegion("us-east-1"))
        client.endpoint = spaceRegion.endpoint()

        transferUtility = TransferUtility.builder().s3Client(client).context(context).build()
        appContext = context
    }


    fun getPresignedUrl(path: String?, callback: (URL?, Exception?) -> Unit) {
        val expiration: java.util.Date = java.util.Date()
        var expTimeMillis: Long = expiration.time
        expTimeMillis += 1000 * 60 * 60.toLong()
        expiration.time = expTimeMillis
        val generatePresignedUrlRequest: GeneratePresignedUrlRequest = GeneratePresignedUrlRequest(spaceName, path)
                .withMethod(HttpMethod.GET)
                .withExpiration(expiration)
        val url: URL = client.generatePresignedUrl(generatePresignedUrlRequest)
        callback(url, null)
    }

    fun getDOBytes(path: String?, callback: (ByteArray?, Exception?) -> Unit) {
        //Create a local File object to save the remote file to
        val file = File("${appContext.cacheDir}/$path")

        //Download the file from DO Space
        val listener = transferUtility.download(spaceName, path, file)

        //Listen to the progress of the download, and call the callback when the download is complete
        listener.setTransferListener(object : TransferListener {
            override fun onProgressChanged(id: Int, bytesCurrent: Long, bytesTotal: Long) {
            }

            override fun onStateChanged(id: Int, state: TransferState?) {
                if (state == TransferState.COMPLETED) {
                    callback(file.readBytes(), null)
                }
            }

            override fun onError(id: Int, ex: Exception?) {
                callback(null, ex)
            }
        })
    }
}