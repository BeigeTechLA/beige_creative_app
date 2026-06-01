
import java.util.Properties
import java.util.Base64
import java.io.FileInputStream
import org.jetbrains.kotlin.gradle.dsl.JvmTarget

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
    id("com.google.firebase.crashlytics")
}

// Load keystore properties for release signing
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.app.cpbiege"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }


    defaultConfig {
        applicationId = "com.app.cpbiege"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // Parse dart-defines for Google Maps API Key
        val dartDefinesString = project.properties["dart-defines"]?.toString() ?: ""
        var googleMapsKey = "AIzaSyB55dzOzA9np8T1rn-DpKKqcqGcgbGmgOc" // Fallback key
        if (dartDefinesString.isNotEmpty()) {
            dartDefinesString.split(",").forEach {
                try {
                    val decoded = String(Base64.getDecoder().decode(it), Charsets.UTF_8)
                    val parts = decoded.split("=")
                    if (parts.size >= 2 && parts[0] == "GOOGLE_MAPS_KEY") {
                        googleMapsKey = parts[1]
                    }
                } catch (e: Exception) {
                    // Ignore decoding errors
                }
            }
        }
        manifestPlaceholders["GOOGLE_MAPS_KEY"] = googleMapsKey
    }

    flavorDimensions += "environment"

    productFlavors {
        create("dev") {
            dimension = "environment"
            applicationIdSuffix = ".dev"
            resValue("string", "app_name", "BeigeCp Dev")
        }
        create("prod") {
            dimension = "environment"
            resValue("string", "app_name", "BeigeCp")
        }
    }

    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String?
            keyPassword = keystoreProperties["keyPassword"] as String?
            storeFile = keystoreProperties["storeFile"]?.let { path -> file(path as String) }
            storePassword = keystoreProperties["storePassword"] as String?
        }
    }

    buildTypes {
        release {
            signingConfig = if (keystorePropertiesFile.exists()) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
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

kotlin {
    compilerOptions {
        jvmTarget.set(JvmTarget.JVM_11)
    }
}
