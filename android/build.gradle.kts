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

    // Some plugins (e.g. geocoding_android 3.3.1) hardcode an old compileSdk (33),
    // which AGP 9 rejects because transitive AndroidX libs require 34+. Force any
    // lagging Android library subproject up to the app's compileSdk. Registered
    // here (before the evaluationDependsOn block below) so afterEvaluate runs in time.
    afterEvaluate {
        extensions.findByName("android")?.let { ext ->
            val android = ext as com.android.build.gradle.BaseExtension
            val current = android.compileSdkVersion?.removePrefix("android-")?.toIntOrNull()
            if (current != null && current < 34) {
                android.compileSdkVersion(36)
            }
        }
    }
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
