package com.example.timer_lock

import android.app.admin.DeviceAdminReceiver
import android.content.Context
import android.content.Intent
import android.widget.Toast

class MyDeviceAdminReceiver : DeviceAdminReceiver() {

    override fun onEnabled(context: Context, intent: Intent) {
        Toast.makeText(context, "Device Admin Enabled", Toast.LENGTH_SHORT).show()
    }

    override fun onDisabled(context: Context, intent: Intent) {
        Toast.makeText(context, "Device Admin Disabled", Toast.LENGTH_SHORT).show()
    }

    override fun onDisableRequested(context: Context, intent: Intent): CharSequence? {
        // Launch PIN screen
        val pinIntent = Intent(context, PinActivity::class.java)
        pinIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        context.startActivity(pinIntent)

        return "Admin rights require PIN to disable."
    }
}
