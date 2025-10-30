
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:timer_lock/helper/native_helper.dart';
import 'package:permission_handler/permission_handler.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedHour = 0;
  int selectedMinute = 0;
  Timer? _timer;
  int remainingSeconds = 0;

  Future<void> requestDeviceAdmin() async {
    const intent = AndroidIntent(
      action: 'android.app.action.ADD_DEVICE_ADMIN',
      arguments: <String, dynamic>{
        'android.app.extra.DEVICE_ADMIN':
        'com.example.timer_lock/.MyDeviceAdminReceiver',
        'android.app.extra.ADD_EXPLANATION':
        'This app needs admin rights to lock the screen',
      },
    );
    await intent.launch();
  }

  Future<void> requestNotificationPermission() async {
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
  }

  @override
  void initState() {
    super.initState();
    ScreenLock.enableAdmin();
    requestDeviceAdmin();
    requestNotificationPermission();
    ScreenLock.timerStream.listen((remaining) {
      setState(() {
        remainingSeconds = remaining;
      });
    });
  }

  void startTimer() async {
    bool isAdmin = await ScreenLock.isAdminActive();
    if (!isAdmin) {
      await ScreenLock.enableAdmin();
      return;
    }

    int totalSeconds = (selectedHour * 3600) + (selectedMinute * 60);
    await ScreenLock.startNativeTimer(totalSeconds);
  }

  String formatTime(int totalSeconds) {
    int hours = totalSeconds ~/ 3600;
    int minutes = (totalSeconds % 3600) ~/ 60;
    int seconds = totalSeconds % 60;
    return "${hours.toString().padLeft(2, '0')}:"
        "${minutes.toString().padLeft(2, '0')}:"
        "${seconds.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo.shade900,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(height: 40),
            Text(
              "Set Lock Timer",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 30),

            // Time Pickers
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                timerWidget(
                  label: "Hour",
                  maxNumber: 23,
                  selectedValue: selectedHour,
                  onChanged: (value) {
                    setState(() => selectedHour = value);
                  },
                ),
                const SizedBox(width: 16),
                Padding(
                  padding: const EdgeInsets.only(bottom: 30),
                  child: Text(
                    ":",
                    style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
                const SizedBox(width: 16),
                timerWidget(
                  label: "Minute",
                  maxNumber: 59,
                  selectedValue: selectedMinute,
                  onChanged: (value) {
                    setState(() => selectedMinute = value);
                  },
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Digital Preview
            Text(
              "$selectedHour hr : $selectedMinute min",
              style: const TextStyle(
                fontSize: 22,
                color: Colors.white70,
                fontWeight: FontWeight.w500,
              ),
            ),

            const Spacer(),

            // Remaining time
            if (remainingSeconds > 0)
              Column(
                children: [
                  Text(
                    "Remaining Time",
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    formatTime(remainingSeconds),
                    style: const TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
                  // const SizedBox(height: 40),
                ],
              ),

            // Start Button
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: ElevatedButton(
                onPressed: startTimer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.indigo.shade900,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 80, vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 6,
                ),
                child: const Text(
                  "Start Timer",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            SizedBox(height: 20,)
          ],
        ),
      ),
    );
  }

  Widget timerWidget({
    required String label,
    required int maxNumber,
    required int selectedValue,
    required Function(int) onChanged,
  }) {
    return Column(
      children: [
        Container(
          width: 110,
          height: 140,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [Colors.white.withOpacity(0.1), Colors.white24],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                  color: Colors.black26, blurRadius: 6, offset: Offset(0, 4)),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: ListWheelScrollView.useDelegate(
              itemExtent: 40.0,
              physics: const FixedExtentScrollPhysics(),
              onSelectedItemChanged: (index) => onChanged(index),
              childDelegate: ListWheelChildBuilderDelegate(
                childCount: maxNumber + 1,
                builder: (context, index) {
                  bool isSelected = index == selectedValue;
                  return Center(
                    child: Text(
                      index.toString(),
                      style: TextStyle(
                        fontSize: isSelected ? 26 : 20,
                        fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? Colors.white : Colors.white54,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 16),
        ),
      ],
    );
  }
}
