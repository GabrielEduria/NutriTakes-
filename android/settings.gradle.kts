pluginManagement {
    val flutterSdkPath = run {
        val properties = java.util.Properties()
        file("local.properties").inputStream().use { properties.load(it) }
        val flutterSdkPath = properties.getProperty("flutter.sdk")
        require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
        flutterSdkPath
    }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.7.0" apply false
<<<<<<< HEAD
    id("org.jetbrains.kotlin.android") version "2.1.21" apply false
=======
    id("org.jetbrains.kotlin.android") version "1.8.22" apply false
>>>>>>> 55a281068f42bc3c2d31d78d4b50483e8c7731e7
}

include(":app")
