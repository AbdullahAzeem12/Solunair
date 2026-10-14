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
subprojects {
    tasks.withType<JavaCompile>().configureEach {
        options.compilerArgs.add("-Xlint:-options")
    }
}
subprojects {
    if (project.name != "app") {
        val setCompileSdk: Project.() -> Unit = {
            val androidExt = extensions.findByName("android")
            if (androidExt != null) {
                try {
                    val method = androidExt.javaClass.getMethod("compileSdkVersion", Int::class.javaPrimitiveType)
                    method.invoke(androidExt, 36)
                } catch (_: Exception) {
                    try {
                        val method = androidExt.javaClass.getMethod("setCompileSdk", Integer::class.java)
                        method.invoke(androidExt, 36)
                    } catch (_: Exception) {}
                }
            }
        }

        if (state.executed) {
            setCompileSdk()
        } else {
            afterEvaluate {
                setCompileSdk()
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
