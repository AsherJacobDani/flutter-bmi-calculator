// settings.gradle.kts

pluginManagement {
    repositories {
        gradlePluginPortal()  // Gradle Plugin Portal for plugin resolution
        google()              // Google's Maven repository for Android plugins
        mavenCentral()        // Maven Central repository for dependencies
        maven("https://jitpack.io")  // JitPack repository for external libraries
    }
}

dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)  // Fail if any project-level repositories are found
    repositories {
        google()         // Google's Maven repository
        mavenCentral()   // Maven Central repository
        maven("https://jitpack.io")  // JitPack repository for external libraries
    }
}

rootProject.name = "BMI Calculator"
include(":app")
