<<<<<<< HEAD
plugins {
    // other plugins
    id("com.google.gms.google-services") version "4.4.2" apply false
}

buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath("com.google.gms:google-services:4.3.15")

        // ✅ Upgrade Kotlin Gradle plugin version
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:2.1.21")
    }
}

=======
>>>>>>> 55a281068f42bc3c2d31d78d4b50483e8c7731e7
allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

<<<<<<< HEAD
// Optional: relocate the build directory
=======
>>>>>>> 55a281068f42bc3c2d31d78d4b50483e8c7731e7
val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
<<<<<<< HEAD

=======
>>>>>>> 55a281068f42bc3c2d31d78d4b50483e8c7731e7
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
