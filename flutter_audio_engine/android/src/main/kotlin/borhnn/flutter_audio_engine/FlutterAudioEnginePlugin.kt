package borhnn.flutter_audio_engine

import android.annotation.TargetApi
import android.content.Context
import android.media.AudioAttributes
import android.media.MediaPlayer
import android.os.Build
import android.view.Choreographer
import io.flutter.Log
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar
import kotlin.math.pow

class FlutterAudioEnginePlugin(private val context: Context) : MethodCallHandler, EventChannel.StreamHandler {
    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {

        Log.d("AudioEnginePlugin", " called on StreamHandler ${arguments.toString()}")
        when (arguments.toString()) {
            "forStatus"   -> {
                playerStatusEventSink = events
                playerStatusEventSink?.success(PlayerStatus.NOT_INITIALIZED.value)
            }
            "forPosition" -> {
                playerPositionEventSink = events
                choreographer = Choreographer.getInstance()
            }
        }
        Log.d("AudioEnginePlugin", "StatusSink: $playerStatusEventSink, PositionSink: $playerPositionEventSink")
    }

    override fun onCancel(arguments: Any?) {
        choreographer = null
        playerStatusEventSink = null
        playerPositionEventSink = null
    }

    private val TAG = "FlutterAudioEnginePlugin"
    var audioPlayer: MediaPlayer? = null
    var playerStatusEventSink: EventChannel.EventSink? = null
    var playerPositionEventSink: EventChannel.EventSink? = null
    var choreographer: Choreographer? = Choreographer.getInstance()


    companion object {
        @JvmStatic
        fun registerWith(registrar: Registrar) {
            val channel = MethodChannel(registrar.messenger(), "flutter_audio_engine")
            val instance = FlutterAudioEnginePlugin(registrar.activeContext())
            val playerStatusChannel = EventChannel(registrar.messenger(), "borhnn/playerStatus")
            val playerPositionChannel = EventChannel(registrar.messenger(), "borhnn/playerPosition")
            playerStatusChannel.setStreamHandler(instance)
            playerPositionChannel.setStreamHandler(instance)
            channel.setMethodCallHandler(instance)
        }
    }

    @TargetApi(Build.VERSION_CODES.LOLLIPOP)
    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "initPlayer"     -> {
                audioPlayer = audioPlayer ?: MediaPlayer()
                playerStatusEventSink?.success(PlayerStatus.NOT_INITIALIZED.value)
                audioPlayer?.setOnPreparedListener {
                    playerStatusEventSink?.success(PlayerStatus.READY.value)
                }
                audioPlayer?.apply {
                    setAudioAttributes(AudioAttributes.Builder()
                            .setUsage(AudioAttributes.USAGE_MEDIA)
                            .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
                            .build()
                    )
                    setDataSource(call.argument<String>("fileURL"))
                    prepareAsync()
                }
            }
            "play"           -> {
                audioPlayer?.start()
                audioPlayer?.setOnCompletionListener { playerStatusEventSink?.success(PlayerStatus.STOPPED.value) }
                choreographer?.postFrameCallback { playerPositionDeclaration() }
                playerStatusEventSink?.success(PlayerStatus.RESUMED.value)
            }
            "pause"          -> {
                audioPlayer?.pause()
                playerStatusEventSink?.success(PlayerStatus.PAUSED.value)
            }
            "stop"           -> {
                audioPlayer?.stop()
                playerStatusEventSink?.success(PlayerStatus.STOPPED.value)
                audioPlayer?.release()
                choreographer?.removeFrameCallback { }
                audioPlayer = null
            }
            "setPlayerSpeed" -> {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                    if (audioPlayer != null) {
                        val wasPlaying = audioPlayer?.isPlaying ?: false
                        audioPlayer?.playbackParams = audioPlayer?.playbackParams.apply {
                            this?.speed = call.argument<Double>("playbackRate")?.toFloat() ?: 0.0f
                        }
                        if (!wasPlaying) audioPlayer?.pause()
                    }
                }
            }
            "setPlayerPitch" -> {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                    if (audioPlayer != null) {
                        val wasPlaying = audioPlayer?.isPlaying ?: false
                        audioPlayer?.playbackParams = audioPlayer?.playbackParams.apply {
                            val hsDelta = call.argument<Int>("halfstepDelta") ?: 0
                            val pitch = 2f.pow(hsDelta.toFloat() / 12)
                            this?.pitch = pitch
                        }
                        if (!wasPlaying) audioPlayer?.pause()
                    }
                }
            }
            "setVolume"      -> {
                val newVolume = call.argument<Double>("volume")?.toFloat() ?: 1.0f
                audioPlayer?.setVolume(newVolume, newVolume)
            }
            else             -> result.notImplemented()
        }
    }

    private fun playerPositionDeclaration() {
        playerPositionEventSink?.success(audioPlayer?.currentPosition)
        choreographer?.postFrameCallback { playerPositionDeclaration() }
    }

    enum class PlayerStatus(val value: Int) {
        NOT_INITIALIZED(-4),
        INITIALIZED(-3),
        READY(-2),
        STOPPED(-1),
        PAUSED(0),
        RESUMED(1),
    }
}
