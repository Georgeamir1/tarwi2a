plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

import java.util.Properties
import java.io.FileInputStream
import java.io.File
import org.gradle.api.GradleException

val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()

fun validateAndGetReleaseSigning(failOnError: Boolean): File? {
    if (!keystorePropertiesFile.exists()) {
        if (failOnError) {
            throw GradleException(
                "Release signing error: 'key.properties' was not found at ${keystorePropertiesFile.absolutePath}.\n" +
                "A signed release build cannot be produced without valid release credentials.\n" +
                "Please copy 'android/key.properties.example' to 'android/key.properties' and configure valid signing keys."
            )
        }
        return null
    }

    if (keystoreProperties.isEmpty) {
        keystoreProperties.load(FileInputStream(keystorePropertiesFile))
    }

    val storeFilePath = keystoreProperties.getProperty("storeFile")
    val storePassword = keystoreProperties.getProperty("storePassword")
    val keyAlias = keystoreProperties.getProperty("keyAlias")
    val keyPassword = keystoreProperties.getProperty("keyPassword")

    val missing = mutableListOf<String>()
    if (storeFilePath.isNullOrBlank()) missing.add("storeFile")
    if (storePassword.isNullOrBlank()) missing.add("storePassword")
    if (keyAlias.isNullOrBlank()) missing.add("keyAlias")
    if (keyPassword.isNullOrBlank()) missing.add("keyPassword")

    if (missing.isNotEmpty()) {
        if (failOnError) {
            throw GradleException(
                "Release signing error: 'key.properties' is missing or has blank required keys: ${missing.joinToString(", ")}.\n" +
                "All of 'storeFile', 'storePassword', 'keyAlias', and 'keyPassword' must be specified for a release build."
            )
        }
        return null
    }

    val resolvedStoreFile = file(storeFilePath).let {
        if (it.exists()) it else rootProject.file(storeFilePath)
    }

    if (!resolvedStoreFile.exists()) {
        if (failOnError) {
            throw GradleException(
                "Release signing error: Keystore file not found at '${resolvedStoreFile.absolutePath}' (configured as '$storeFilePath' in key.properties)."
            )
        }
        return null
    }

    return resolvedStoreFile
}

val isReleaseTaskRequested = gradle.startParameter.taskNames.any { taskName ->
    taskName.contains("Release", ignoreCase = true)
}

if (isReleaseTaskRequested) {
    validateAndGetReleaseSigning(failOnError = true)
}

gradle.taskGraph.whenReady {
    if (allTasks.any { it.name.contains("Release", ignoreCase = true) }) {
        validateAndGetReleaseSigning(failOnError = true)
    }
}

android {
    namespace = "com.tarwi2a.app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.tarwi2a.app"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            val storeFileResolved = validateAndGetReleaseSigning(failOnError = isReleaseTaskRequested)
            if (storeFileResolved != null) {
                storeFile = storeFileResolved
                storePassword = keystoreProperties.getProperty("storePassword")
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
            }
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
        debug {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

flutter {
    source = "../.."
}
