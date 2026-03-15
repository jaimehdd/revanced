#!/bin/bash
# Revanced build
source ./src/build/utils.sh
# Download requirements
use_beta="${use_beta:-false}"

revanced_dl_beta(){
	dl_gh "revanced-cli" "revanced" "prerelease"
	dl_gh "revanced-patches" "revanced" "prerelease"
}

revanced_dl(){
	if [ "$use_beta" = true ]; then
		revanced_dl_beta
	else
		dl_gh "revanced-patches revanced-cli" "revanced" "latest"
	fi
}

messenger() {
	revanced_dl
	# Patch Messenger:
	echo "APP_NAME=messenger" >> $GITHUB_ENV
	echo "VARIANT=rv" >> $GITHUB_ENV
	# Arm64-v8a
	get_patches_key "messenger"
	get_apkpure "com.facebook.orca" "messenger-arm64-v8a" "facebook-messenger/com.facebook.orca"
	patch "messenger-arm64-v8a" "revanced"
}
photos() {
	revanced_dl
	# Patch Google photos:
	echo "APP_NAME=google-photos" >> $GITHUB_ENV
	echo "VARIANT=rv" >> $GITHUB_ENV
	# Arm64-v8a
	get_patches_key "gg-photos"
	get_apk "com.google.android.apps.photos" "gg-photos-arm64-v8a" "photos" "google-inc/photos/google-photos" "arm64-v8a" "nodpi"
	patch "gg-photos-arm64-v8a" "revanced"
}
instagram() {
	revanced_dl
	# Patch Instagram:
	echo "APP_NAME=instagram" >> $GITHUB_ENV
	echo "VARIANT=rv" >> $GITHUB_ENV
	get_patches_key "instagram"
	# # Skip patch version limit and download the absolute latest
	# lock_version="1"
	get_apkpure "com.instagram.android" "instagram-arm64-v8a" "instagram-android/com.instagram.android" "Bundle"
	patch "instagram-arm64-v8a" "revanced"
}
facebook() {
	revanced_dl
	# Patch Facebook:
	echo "APP_NAME=facebook" >> $GITHUB_ENV
	echo "VARIANT=rv" >> $GITHUB_ENV
	# Arm64-v8a
	get_patches_key "facebook"
	# Download from APKPure with specific version code
	# versionCode 457020014 = 490.0.0.63.82
	version="490.0.0.63.82"
	echo "APP_VERSION=$version" >> $GITHUB_ENV
	green_log "[+] Downloading facebook version: $version"
	url="https://d.apkpure.com/b/APK/com.facebook.katana?versionCode=457020014"
	req "$url" "facebook-arm64-v8a.apk"
	patch "facebook-arm64-v8a" "revanced"
}
strava() {
	revanced_dl
	# Patch Strava:
	echo "APP_NAME=strava" >> $GITHUB_ENV
	echo "VARIANT=rv" >> $GITHUB_ENV
	get_patches_key "strava"
	get_apkpure "com.strava" "strava-arm64-v8a" "strava-run-hike-android-exercise-laugh/com.strava" "Bundle"
	patch "strava-arm64-v8a" "revanced"
}
spotify() {
	echo "APP_NAME=spotify" >> $GITHUB_ENV
	echo "VARIANT=rv" >> $GITHUB_ENV

	revanced_dl
	# Patch Spotjfy Arm64-v8a
	j="i"
	get_patches_key "Spotjfy-revanced"
	get_apkpure "com.spot"$j"fy.music" "spotjfy-arm64-v8a" "spot"$j"fy-music-and-podcasts-for-android/com.spot"$j"fy.music"
	patch "spotjfy-arm64-v8a" "revanced"
}
case "$1" in
    messenger)
        messenger
        ;;
    photos)
        photos
        ;;
    instagram)
        instagram
        ;;
    facebook)
        facebook
        ;;
	strava)
		strava
		;;
	spotify)
		spotify
		;;
esac
