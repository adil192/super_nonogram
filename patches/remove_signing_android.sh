# This patch is necessary when building an appbundle on GitHub Actions,
# as the signing action will fail if the .aab was already signed.

# Remove `signingConfig = signingConfigs.getByName("release")` from android/app/build.gradle.kts
sed -i -e 's/signingConfig = signingConfigs.getByName("release")//g' android/app/build.gradle.kts
