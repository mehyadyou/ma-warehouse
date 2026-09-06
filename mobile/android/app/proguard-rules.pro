# قوانین ProGuard/R8 برای release بیلد
# Flutter خودش قوانین پایه را از flutter.gradle تزریق می‌کند؛ این‌ها مکمل هستند.

# نگه‌داشتن کلاس‌های مدل برای refleksion json_serializable/freezed
-keep class com.ma.ma_app.** { *; }

# socket.io / engine.io (okhttp websocket)
-keep class io.socket.** { *; }
-dontwarn io.socket.**

# flutter_secure_storage (keystore)
-keep class com.it_nomads.fluttersecurestorage.** { *; }

# local_auth (biometric)
-keep class androidx.biometric.** { *; }
