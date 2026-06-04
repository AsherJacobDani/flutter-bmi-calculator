plugins {
    // Apply Android Application plugin
    id("com.android.application")
    // Apply Kotlin Android plugin (for Kotlin support in Android)
    id("org.jetbrains.kotlin.android")
    // Apply Firebase services plugin
    id("com.google.gms.google-services")
    // Apply Kotlin JVM plugin (for Kotlin support)
      // Set the correct Kotlin version
}

android {
    namespace = "dev.jahidhasanco.bmicalculator"  // Application namespace
    compileSdk = 34

    defaultConfig {
        applicationId = "dev.jahidhasanco.bmicalculator"
        minSdk = 23
        targetSdk = 34
        versionCode = 1
        versionName = "1.0"
        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"
    }

    buildTypes {
        release {
            isMinifyEnabled = true
            isShrinkResources = true
            isDebuggable = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }

    buildTypes.all { isCrunchPngs = false }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = "1.8"
    }

    buildFeatures {
        dataBinding = true
        viewBinding = true
    }
}

dependencies {
    // AndroidX Core Dependencies
    implementation("androidx.core:core-ktx:1.9.0")
    implementation("androidx.appcompat:appcompat:1.6.1")
    implementation("com.google.android.material:material:1.8.0")
    implementation("androidx.constraintlayout:constraintlayout:2.1.4")
    implementation ("com.google.code.gson:gson:2.10.1")
    // Kotlin Standard Library (using version 1.8.20)
    implementation("org.jetbrains.kotlin:kotlin-stdlib:1.8.20")
    implementation("org.jetbrains.kotlin:kotlin-stdlib-jdk8:1.8.0")

    // Firebase Dependencies
    implementation(platform("com.google.firebase:firebase-bom:32.7.4")) // BOM for version management
    implementation("com.google.firebase:firebase-analytics")
    implementation("com.google.firebase:firebase-auth-ktx:23.2.0")
    implementation("com.google.firebase:firebase-inappmessaging:21.0.2")

    // Testing Dependencies
    testImplementation("junit:junit:4.13.2")
    androidTestImplementation("androidx.test.ext:junit:1.1.5")
    androidTestImplementation("androidx.test.espresso:espresso-core:3.5.1")

    // Custom Library Dependencies
    implementation("com.github.adityagohad:HorizontalPicker:1.0.1")
    implementation("com.github.psuzn:WheelView:1.0.0")
    implementation("com.github.CNCoderX:WheelView:1.2.6")
    implementation("com.github.mhdmoh:swipe-button:1.0.3")
}
