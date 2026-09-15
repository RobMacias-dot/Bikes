import java.util.Properties

plugins {
    id("com.android.application")
    id("dev.flutter.flutter-gradle-plugin")
}

val releaseProperties = Properties()
val releasePropertiesFile = rootProject.file("key.properties")
if (releasePropertiesFile.exists()) {
    releasePropertiesFile.inputStream().use { releaseProperties.load(it) }
    val requiredSigningProperties =
        listOf("storeFile", "storePassword", "keyAlias", "keyPassword")
    val missingSigningProperties = requiredSigningProperties.filter {
        releaseProperties.getProperty(it).isNullOrBlank()
    }
    if (missingSigningProperties.isNotEmpty()) {
        throw GradleException(
            "Faltan propiedades de firma release: ${missingSigningProperties.joinToString()}"
        )
    }
}

android {
    namespace = "com.robmac.bicifirme"
    compileSdk = 36
    ndkVersion = flutter.ndkVersion
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
    defaultConfig {
        applicationId = "com.robmac.bicifirme"
        minSdk = 24
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }
    signingConfigs {
        if (releasePropertiesFile.exists()) {
            create("production") {
                keyAlias = releaseProperties.getProperty("keyAlias")
                keyPassword = releaseProperties.getProperty("keyPassword")
                storeFile = file(releaseProperties.getProperty("storeFile"))
                storePassword = releaseProperties.getProperty("storePassword")
            }
        }
    }
    buildTypes {
        release {
            // Sin credenciales el artefacto queda sin firmar. Nunca usar debug.
            if (releasePropertiesFile.exists()) {
                signingConfig = signingConfigs.getByName("production")
            }
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"))
        }
    }
}
kotlin {
    compilerOptions { jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17 }
}
flutter { source = "../.." }
