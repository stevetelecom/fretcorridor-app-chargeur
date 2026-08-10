allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

// Force tous les modules Android de type "library" (donc les plugins,
// ex. geocoding_android) a compiler contre le meme SDK que l'app.
// Necessaire car le compileSdk d'un plugin est fixe par le plugin
// lui-meme et n'est pas herite depuis android/app/build.gradle.kts.
subprojects {
    val applyCompileSdkOverride: () -> Unit = {
        if (plugins.hasPlugin("com.android.library")) {
            extensions.configure<com.android.build.gradle.LibraryExtension> {
                compileSdk = 36
            }
        }
    }
    if (state.executed) {
        applyCompileSdkOverride()
    } else {
        afterEvaluate { applyCompileSdkOverride() }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
