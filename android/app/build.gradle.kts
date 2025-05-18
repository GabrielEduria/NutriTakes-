plugins {
    id("com.android.application")
<<<<<<< HEAD
    id("org.jetbrains.kotlin.android")   // no version here
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
=======
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
>>>>>>> 55a281068f42bc3c2d31d78d4b50483e8c7731e7
}

android {
    namespace = "com.example.csth_nutritakes"
<<<<<<< HEAD
    compileSdk = 35
=======
    compileSdk = flutter.compileSdkVersion
>>>>>>> 55a281068f42bc3c2d31d78d4b50483e8c7731e7
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
<<<<<<< HEAD
        applicationId = "com.example.csth_nutritakes"
        minSdk = 23
        targetSdk = 35
        versionCode = 1
        versionName = "1.0.0"
    }

    buildTypes {
        getByName("release") {
        isMinifyEnabled = true
        isShrinkResources = true
        proguardFiles(
            getDefaultProguardFile("proguard-android-optimize.txt"),
            "proguard-rules.pro"
        )
=======
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.csth_nutritakes"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
>>>>>>> 55a281068f42bc3c2d31d78d4b50483e8c7731e7
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
<<<<<<< HEAD

dependencies {
    implementation(platform("com.google.firebase:firebase-bom:33.13.0"))
    implementation("com.google.firebase:firebase-analytics")
    implementation("org.tensorflow:tensorflow-lite-gpu:2.12.0")
}
=======
>>>>>>> 55a281068f42bc3c2d31d78d4b50483e8c7731e7
