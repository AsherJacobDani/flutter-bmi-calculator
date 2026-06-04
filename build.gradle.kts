// Project-level build.gradle.kts
plugins {
    kotlin("jvm") version "2.1.0" // Upgrade to Kotlin 2.1.0 or the latest stable version
}

buildscript {
    repositories {
        google()       // Google's Maven repository
        mavenCentral() // Maven Central repository
    }
    dependencies {
        // Add the Google Services Plugin to the dependencies block
        classpath("com.android.tools.build:gradle:8.2.1")  // Android Gradle Plugin
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:1.8.0")  // Kotlin plugin
        classpath("com.google.gms:google-services:4.3.15")  // Google Services plugin version
    }
}

allprojects {

}

// Clean task to delete the build directory
tasks.register("cleanCustom", Delete::class) {
    delete(rootProject.buildDir)
}
