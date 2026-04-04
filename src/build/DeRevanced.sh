#!/bin/bash
# DeRevanced build
source ./src/build/utils.sh
# Download requirements
use_beta="${use_beta:-false}"

derevanced_dl_beta(){
	dl_gh "morphe-cli" "MorpheApp" "prerelease"
	dl_gh "De-ReVanced" "RookieEnough" "prerelease"
}

derevanced_dl(){
	if [ "$use_beta" = true ]; then
		derevanced_dl_beta
	else
		dl_gh "morphe-cli" "MorpheApp" "latest"
		dl_gh "De-ReVanced" "RookieEnough" "latest"
	fi
}

messenger() {
	derevanced_dl
	# Patch Messenger:
	echo "APP_NAME=messenger" >> $GITHUB_ENV
	echo "VARIANT=rv" >> $GITHUB_ENV
	# Arm64-v8a
	get_patches_key "messenger"
	version="552.0.0.44.65"
	get_apkpure "com.facebook.orca" "messenger-arm64-v8a" "facebook-messenger/com.facebook.orca"
	patch "messenger-arm64-v8a" "derevanced" "morphe"
}

photos() {
	derevanced_dl
	# Patch Google photos:
	echo "APP_NAME=google-photos" >> $GITHUB_ENV
	echo "VARIANT=rv" >> $GITHUB_ENV
	# Arm64-v8a
	get_patches_key "gg-photos"
	get_apk "com.google.android.apps.photos" "gg-photos-arm64-v8a" "photos" "google-inc/photos/google-photos" "arm64-v8a" "nodpi"
	patch "gg-photos-arm64-v8a" "derevanced" "morphe"
}

instagram() {
	dl_gh "morphe-cli" "MorpheApp" "latest"
	# dl_gh "piko" "crimera" "prerelease"
	dl_gh "morphe-patches" "brosssh" "prerelease"
	# Patch Instagram:
	echo "APP_NAME=instagram" >> $GITHUB_ENV
	echo "VARIANT=rv" >> $GITHUB_ENV
	get_patches_key "instagram"
	get_apkpure "com.instagram.android" "instagram-arm64-v8a" "instagram-android/com.instagram.android" "Bundle"
	# patch "instagram-arm64-v8a" "piko" "morphe"
	patch "instagram-arm64-v8a" "brosssh" "morphe"
}

facebook() {
	derevanced_dl
	# Patch Facebook:
	echo "APP_NAME=facebook" >> $GITHUB_ENV
	echo "VARIANT=rv" >> $GITHUB_ENV
	# Arm64-v8a
	get_patches_key "facebook"
	version="490.0.0.63.82"
	echo "APP_VERSION=$version" >> $GITHUB_ENV
	url="https://d.apkpure.com/b/APK/com.facebook.katana?versionCode=457020014"
	req "$url" "facebook-arm64-v8a.apk"
	patch "facebook-arm64-v8a" "derevanced" "morphe"
}

strava() {
	derevanced_dl
	# Patch Strava:
	echo "APP_NAME=strava" >> $GITHUB_ENV
	echo "VARIANT=rv" >> $GITHUB_ENV
	get_patches_key "strava"
	get_apkpure "com.strava" "strava-arm64-v8a" "strava-run-hike-android-exercise-laugh/com.strava" "Bundle"
	patch "strava-arm64-v8a" "derevanced" "morphe"
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
esac