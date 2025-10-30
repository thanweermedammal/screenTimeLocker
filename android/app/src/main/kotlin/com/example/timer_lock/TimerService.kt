package com.example.timer_lock

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.app.admin.DevicePolicyManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.CountDownTimer
import android.os.IBinder
import androidx.core.app.NotificationCompat
import io.flutter.plugin.common.EventChannel

class TimerService : Service() {
    private val CHANNEL_ID = "TimerLockChannel"
    private var countDownTimer: CountDownTimer? = null

    companion object {
        var events: EventChannel.EventSink? = null // 👈 Send updates to Flutter
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val seconds = intent?.getIntExtra("seconds", 10) ?: 10

        createNotificationChannel()

        startCountdown(seconds)

        return START_STICKY
    }

    private fun startCountdown(totalSeconds: Int) {
        countDownTimer?.cancel()
        countDownTimer = object : CountDownTimer(totalSeconds * 1000L, 1000L) {
            override fun onTick(millisUntilFinished: Long) {
                val remaining = (millisUntilFinished / 1000).toInt()

                // 🔔 Update Notification
                val notification: Notification = NotificationCompat.Builder(this@TimerService, CHANNEL_ID)
                    .setContentTitle("Timer Lock")
                    .setContentText("Screen will lock in $remaining seconds")
                    .setSmallIcon(android.R.drawable.ic_lock_lock)
                    .setOngoing(true)
                    .build()
                startForeground(1, notification)

                // 🔥 Send update to Flutter UI
                events?.success(remaining)
            }

            override fun onFinish() {
                events?.success(0)

                // 🔒 Lock Screen
                val dpm = getSystemService(Context.DEVICE_POLICY_SERVICE) as DevicePolicyManager
                val compName = ComponentName(this@TimerService, MyDeviceAdminReceiver::class.java)
                if (dpm.isAdminActive(compName)) {
                    dpm.lockNow()
                }

                stopSelf()
            }
        }.start()
    }

    override fun onBind(intent: Intent?): IBinder? = null

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val serviceChannel = NotificationChannel(
                CHANNEL_ID,
                "Timer Lock Service",
                NotificationManager.IMPORTANCE_LOW // 👈 Low importance = no sound
            ).apply {
                setSound(null, null)        // 👈 Disable sound
                enableVibration(false)      // 👈 Disable vibration
                setShowBadge(false)
            }
            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(serviceChannel)
        }
    }

    override fun onDestroy() {
        countDownTimer?.cancel()
        super.onDestroy()
    }
}
