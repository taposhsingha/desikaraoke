package com.desikaraoke.lite

import android.bluetooth.*
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity : FlutterActivity(), EventChannel.StreamHandler {
    private var broadReceiver: BroadcastReceiver? = null
    private var bluetoothAdapter: BluetoothAdapter? = null
    var spacesFileRepository: SpacesFileRepository? = null

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine)
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setStreamHandler(this)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, METHOD_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getDownloadUrl" -> getDownloadURL(call.argument("path"), result)
                "getFileFromDo"  -> getFile(call.argument("path"), result)
                else             -> "hi"
            }

        }
    }

    private fun getDownloadURL(path: String?, result: MethodChannel.Result) {
        spacesFileRepository = spacesFileRepository ?: SpacesFileRepository(applicationContext)
        spacesFileRepository?.getPresignedUrl(path) { file, _ ->
            result.success(file.toString())
        }
    }

    private fun getFile(path: String?, result: MethodChannel.Result) {
        spacesFileRepository = spacesFileRepository ?: SpacesFileRepository(applicationContext)
        spacesFileRepository?.getDOBytes(path) { file, _ ->
            result.success(file)
        }

    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        val systemService: BluetoothManager? = getSystemService(Context.BLUETOOTH_SERVICE) as BluetoothManager?

        systemService?.let { bluetoothAdapter = systemService.adapter } ?: run {
            events?.success("none")
        }
        if (bluetoothAdapter == null || !bluetoothAdapter!!.isEnabled) events?.success("none")

        bluetoothAdapter?.getProfileProxy(this@MainActivity, object : BluetoothProfile.ServiceListener {
            override fun onServiceDisconnected(profile: Int) = Unit

            override fun onServiceConnected(profile: Int, proxy: BluetoothProfile?) {
                val bluetoothHeadset = proxy as BluetoothHeadset
                val connectedDevices = bluetoothHeadset.connectedDevices
                for (connectedDevice in connectedDevices) events?.success(connectedDevice.address)
                if (connectedDevices.size == 0) events?.success("none")
                bluetoothAdapter?.closeProfileProxy(BluetoothProfile.HEADSET, proxy)
            }
        }, BluetoothProfile.HEADSET)

        val filter = IntentFilter(BluetoothAdapter.ACTION_CONNECTION_STATE_CHANGED)
        broadReceiver = object : BroadcastReceiver() {
            override fun onReceive(context: Context?, intent: Intent?) {
                val asd = intent?.extras?.get(BluetoothDevice.EXTRA_DEVICE) as BluetoothDevice
                if (intent.extras?.get(BluetoothAdapter.EXTRA_CONNECTION_STATE) == BluetoothAdapter.STATE_DISCONNECTED) {
                    events?.success("none")
                } else if (intent.extras?.get(BluetoothAdapter.EXTRA_CONNECTION_STATE) == BluetoothAdapter.STATE_CONNECTED) {
                    events?.success(asd.address)
                }
            }
        }
        registerReceiver(broadReceiver, filter)
    }

    override fun onCancel(arguments: Any?) {
    }

    companion object {
        private const val CHANNEL = "desikaraoke.com/bluetooth_connected_devices"
        private const val METHOD_CHANNEL = "desikaraoke.com/filedownloader"
        private val TAG = MainActivity::class.java.simpleName
    }
}