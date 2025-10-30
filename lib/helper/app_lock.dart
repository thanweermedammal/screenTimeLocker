import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

class AppLock extends StatefulWidget {
  final Widget child;
  const AppLock({super.key, required this.child});

  @override
  State<AppLock> createState() => _AppLockState();
}

class _AppLockState extends State<AppLock> with WidgetsBindingObserver {
  final LocalAuthentication auth = LocalAuthentication();
  bool _isLocked = true;
  bool _didFirstAuth = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // ask immediately on first launch
    _authenticate();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      setState(() {
        _isLocked = true;
        _didFirstAuth = false; // reset here when locking
      });
    } else if (state == AppLifecycleState.resumed && _isLocked && !_didFirstAuth) {
      _didFirstAuth = true; // mark so it doesn't ask twice
      if(!_isLocked)
      _authenticate();
    }
  }

  Future<void> _authenticate() async {
    try {
      bool canCheck = await auth.canCheckBiometrics;
      bool isSupported = await auth.isDeviceSupported();
      if (!(canCheck || isSupported)) {
        debugPrint("No biometric/PIN available on this device");
        return;
      }

      bool didAuthenticate = await auth.authenticate(
        localizedReason: 'Please unlock to access the app',
        options: const AuthenticationOptions(
          biometricOnly: false, // allows device PIN/pattern too
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );

      if (didAuthenticate && mounted) {
        setState((){ _isLocked = false;
            _didFirstAuth = true;});
      }
    } catch (e) {
      debugPrint("Auth error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLocked
        ? Scaffold(
      backgroundColor: Colors.indigo.shade900,
      body: Center(
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          color: Colors.white,
          margin: const EdgeInsets.symmetric(horizontal: 24),
          child: Padding(
            padding: const EdgeInsets.all(28.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.lock_outline,
                    size: 64, color: Colors.indigo.shade700),
                const SizedBox(height: 20),
                Text(
                  "Timer Lock",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo.shade900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Use your fingerprint, face, or PIN to unlock.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 28),
                ElevatedButton.icon(
                  onPressed: _authenticate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo.shade700,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.fingerprint),
                  label: const Text(
                    "Unlock",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    )
        : widget.child;
  }
}
