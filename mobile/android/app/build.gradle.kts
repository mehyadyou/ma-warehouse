plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// ─── امضای release از key.properties (هرگز در گیت نیست) ───
// ساخت keystore (یک بار):
//   keytool -genkey -v -keystore android/app/ma-release-key.jks \
//     -keyalg RSA -keysize 2048 -validity 10000 -alias ma-upload
// سپس فایل android/key.properties بسازید:
//   storePassword=...  keyPassword=...  keyAlias=ma-upload
//   storeFile=../app/ma-release-key.jks
import java.util.Properties
import java.io.FileInputStream

val keystoreProperties = Properties().apply {
    val f = rootProject.file("key.properties")
    if (f.exists()) load(FileInputStream(f))
}

android {
    namespace = "com.ma.ma_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    signingConfigs {
        create("release") {
            if (keystoreProperties.isNotEmpty()) {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.ma.ma_app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // fail-closed: بیلد release بدون key.properties ممنوع — fallback بی‌صدا به
            // کلید debug قبلاً باعث می‌شد APK «ریلیز» با امضای debug منتشر شود.
            // نکته: این چک فقط وقتی اجرا می‌شود که واقعاً تسک release در حال اجراست،
            // چون فاز configuration گریدل برای همه تسک‌ها (حتی debug) اجرا می‌شود.
            if (keystoreProperties.isNotEmpty()) {
                signingConfig = signingConfigs.getByName("release")
            } else {
                val buildingRelease = gradle.startParameter.taskNames.any {
                    it.contains("Release", ignoreCase = true)
                }
                if (buildingRelease) {
                    throw GradleException(
                        " keystore برای بیلد release یافت نشد: android/key.properties بسازید " +
                        "(راهنما بالای همین فایل). برای اجرای محلی از بیلد debug استفاده کنید."
                    )
                } else {
                    // بیلد debug در حال اجراست — بلوک release فقط configure می‌شود
                    signingConfig = signingConfigs.getByName("debug")
                }
            }
            // کوچک‌سازی و obfuscation برای کاهش حجم و سختی مهندسی معکوس
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

flutter {
    source = "../.."
}
