pluginManagement {
    repositories {
        google {
            content {
                includeGroupByRegex("com\\.android.*")
                includeGroupByRegex("com\\.google.*")
                includeGroupByRegex("androidx.*")
            }
        }
        mavenCentral()
        gradlePluginPortal()
    }
}
dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        google()
        mavenCentral()

        // 👇 Add your Flutter module repositories here
        val storageUrl = System.getenv("FLUTTER_STORAGE_BASE_URL") ?: "https://storage.googleapis.com"
        maven {
            url = uri("D:/Flutter apptoapp/flutter_nps/build/host/outputs/repo")
        }
        maven {
            url = uri("$storageUrl/download.flutter.io")
        }
    }
}

rootProject.name = "My Application"
include(":app")
 