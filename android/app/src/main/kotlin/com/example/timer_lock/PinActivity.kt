package com.example.timer_lock

import android.app.Activity
import android.os.Bundle
import android.widget.Button
import android.widget.EditText
import android.widget.LinearLayout
import android.widget.Toast
import android.text.InputType

class PinActivity : Activity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        val editText = EditText(this).apply {
            hint = "Enter PIN"
            inputType = InputType.TYPE_CLASS_NUMBER or InputType.TYPE_NUMBER_VARIATION_PASSWORD
        }

        val button = Button(this).apply {
            text = "Confirm"
        }

        val layout = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            setPadding(50, 50, 50, 50)
            addView(editText)
            addView(button)
        }

        setContentView(layout)

        button.setOnClickListener {
            val enteredPin = editText.text.toString()
            if (enteredPin == "1234") { // 🔐 Replace with secure PIN later
                Toast.makeText(this, "Admin disable allowed", Toast.LENGTH_SHORT).show()
                setResult(Activity.RESULT_OK)
                finish()
            } else {
                Toast.makeText(this, "Wrong PIN! Cannot disable admin.", Toast.LENGTH_SHORT).show()
                setResult(Activity.RESULT_CANCELED)
            }
        }
    }

    override fun onBackPressed() {
        // Block back button
        Toast.makeText(this, "Enter PIN to continue", Toast.LENGTH_SHORT).show()
    }

    override fun onUserLeaveHint() {
        // Prevent swipe home
        moveTaskToBack(false)
    }
}
