package com.example.timer_lock

import android.app.admin.DevicePolicyManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.EventChannel

class MainActivity : FlutterFragmentActivity() {
    private val CHANNEL = "screen_lock"
    private lateinit var dpm: DevicePolicyManager
    private lateinit var compName: ComponentName

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        dpm = getSystemService(Context.DEVICE_POLICY_SERVICE) as DevicePolicyManager
        compName = ComponentName(this, MyDeviceAdminReceiver::class.java)

        // Timer method channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.example.timer_lock/timer")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "startTimer" -> {
                        val seconds = call.argument<Int>("seconds") ?: 10
                        val intent = Intent(this, TimerService::class.java)
                        intent.putExtra("seconds", seconds)
                        startForegroundService(intent)
                        result.success("Timer started")
                    }
                    else -> result.notImplemented()
                }
            }

        // Timer stream channel
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, "com.example.timer_lock/timer_stream")
            .setStreamHandler(object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    TimerService.events = events
                }

                override fun onCancel(arguments: Any?) {
                    TimerService.events = null
                }
            })

        // Admin + lock channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "enableAdmin" -> {
                        val intent = Intent(DevicePolicyManager.ACTION_ADD_DEVICE_ADMIN).apply {
                            putExtra(DevicePolicyManager.EXTRA_DEVICE_ADMIN, compName)
                            putExtra(
                                DevicePolicyManager.EXTRA_ADD_EXPLANATION,
                                "Enable device admin to lock screen and prevent uninstall."
                            )
                        }
                        startActivity(intent)
                        result.success(true)
                    }

                    "isAdminActive" -> {
                        result.success(dpm.isAdminActive(compName))
                    }

                    "lockScreen" -> {
                        if (dpm.isAdminActive(compName)) {
                            dpm.lockNow()
                            result.success("Locked")
                        } else {
                            result.error("NO_ADMIN", "Device admin not enabled", null)
                        }
                    }

                    else -> result.notImplemented()
                }
            }

        // Request admin automatically on launch
        if (!dpm.isAdminActive(compName)) {
            val intent = Intent(DevicePolicyManager.ACTION_ADD_DEVICE_ADMIN).apply {
                putExtra(DevicePolicyManager.EXTRA_DEVICE_ADMIN, compName)
                putExtra(
                    DevicePolicyManager.EXTRA_ADD_EXPLANATION,
                    "Enable device admin to lock screen and prevent uninstall."
                )
            }
            startActivity(intent)
        }
    }
}
