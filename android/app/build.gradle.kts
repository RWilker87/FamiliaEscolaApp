plugins {
    id("com.android.application")
    id("com.google.gms.google-services")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.a"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "28.2.13676358" // Match NDK version needed by integration_test plugin

    compileOptions {
        // ✅ Enables desugaring support
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.a"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion // Corrected to use Flutter's target SDK version
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // ✅ Add desugaring dependency
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")
}

// ❌ This line is redundant. The plugin is already applied at the top.
// apply(plugin = "com.google.gms.google-services")
