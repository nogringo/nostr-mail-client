import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "org.nostrmail.app.foss"
    compileSdk = flutter.compileSdkVersion
    // NDK r27+ is required for 16KB page alignment (Android 15+ devices)
    ndkVersion = "27.0.12077973"

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String?
            keyPassword = keystoreProperties["keyPassword"] as String?
            storeFile = keystoreProperties["storeFile"]?.let { file(it) }
            storePassword = keystoreProperties["storePassword"] as String?
        }
    }

    defaultConfig {
        applicationId = "org.nostrmail.app.foss"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // 16KB page alignment for Android 15+ compatibility
        ndk {
            abiFilters += listOf("arm64-v8a", "x86_64")
        }
    }

    flavorDimensions += "distribution"

    productFlavors {
        create("foss") {
            dimension = "distribution"
            applicationId = "org.nostrmail.app.foss"
        }

        create("zapstore") {
            dimension = "distribution"
            applicationId = "app.nostrmail.client"
        }
    }

    buildTypes {
        release {
            signingConfig = if (keystorePropertiesFile.exists()) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
        }
    }
}

configurations.all {
    // unifiedpush pulls tink-android; another dep pulls the JVM tink, and the
    // two duplicate every class. Keep the Android variant.
    exclude(group = "com.google.crypto.tink", module = "tink")
}

flutter {
    source = "../.."
}

dependencies {
    // flutter_local_notifications requires core library desugaring (its AAR mandates it)
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
