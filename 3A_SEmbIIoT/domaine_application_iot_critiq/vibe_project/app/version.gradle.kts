import org.gradle.api.GradleException
import java.io.File

tasks.register("bumpVersion") {
    group = "versioning"
    description = "Bumps the application's versionCode and versionName (minor version)."
    doLast {
        val appBuildFile = project.rootProject.file("app/build.gradle.kts")
        if (!appBuildFile.exists()) {
            throw GradleException("app/build.gradle.kts not found!")
        }

        var content = appBuildFile.readText()

        val versionCodeRegex = Regex("versionCode = (\\d+)")
        val versionNameRegex = Regex("versionName = \"(\\d+)\\.(\\d+)\"")

        val oldVersionCode = versionCodeRegex.find(content)?.groupValues?.get(1)?.toInt() ?: 1
        val oldVersionNameMatch = versionNameRegex.find(content)

        val newVersionCode = oldVersionCode + 1
        val newVersionName: String

        if (oldVersionNameMatch != null && oldVersionNameMatch.groupValues.size >= 3) {
            val major = oldVersionNameMatch.groupValues[1].toInt()
            val minor = oldVersionNameMatch.groupValues[2].toInt()
            newVersionName = "${major}.${minor + 1}"
        } else {
            newVersionName = "1.1"
        }

        content = content.replace(versionCodeRegex, "versionCode = ${newVersionCode}")
        content = content.replace(versionNameRegex, "versionName = \"${newVersionName}\"")

        appBuildFile.writeText(content)

        println("BUMPED VERSION: versionCode from ${oldVersionCode} to ${newVersionCode}, versionName from ${oldVersionNameMatch?.groupValues?.get(0) ?: "unknown"} to ${newVersionName}")
    }
}