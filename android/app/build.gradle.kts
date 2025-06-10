plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
<<<<<<< Updated upstream
    id("com.google.gms.google-services")
=======
    id("com.google.gms.google-services") version "4.4.0" // ✅ ajoute cette ligne avec version
>>>>>>> Stashed changes
}


android {
<<<<<<< Updated upstream
    namespace = "com.kkc.kkc_reservation"
    compileSdk = 35
    ndkVersion = "28.1.13356709"
=======
    namespace = "com.example.reservation_kkc"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"
>>>>>>> Stashed changes

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    sourceSets {
        getByName("main") {
            java.srcDirs("src/main/kotlin")
        }
    }

    defaultConfig {
<<<<<<< Updated upstream
        applicationId = "com.kkc.kkc_reservation"
        minSdk = 23
        targetSdk = 35
        versionCode = flutter.versionCode.toInt()
        versionName = flutter.versionName.toString()
=======
        applicationId = "com.example.reservation_kkc"
        minSdk = 23
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
>>>>>>> Stashed changes
    }

    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("debug")
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
        getByName("debug") {
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
} // ✅ Ajouté ici

flutter {
    source = "../.."
}

dependencies {
<<<<<<< Updated upstream
    implementation("androidx.core:core-ktx:1.12.0")
    implementation(platform("com.google.firebase:firebase-bom:33.14.0"))
=======
    // tes dépendances ici si besoin (ex: Firebase Auth, Firestore, etc.)
>>>>>>> Stashed changes
}
