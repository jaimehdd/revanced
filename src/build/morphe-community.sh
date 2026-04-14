#!/bin/bash
# Morphe Community build
source ./src/build/utils.sh
# Download requirements
use_beta="${use_beta:-false}"

derevanced_dl(){
	dl_gh "morphe-cli" "MorpheApp" "latest"
	dl_gh "De-ReVanced" "RookieEnough" "latest"
}

hoo-dles_dl() {
	dl_gh "morphe-cli" "MorpheApp" "latest"
	dl_gh "morphe-patches" "hoo-dles" "latest"
}

brosssh_dl() {
	dl_gh "morphe-cli" "MorpheApp" "latest"
	dl_gh "morphe-patches" "brosssh" "latest"
}

piko_dl(){
	dl_gh "morphe-cli" "MorpheApp" "latest"
	dl_gh "piko" "crimera" "latest"
}

messenger() {
	derevanced_dl
	# Patch Messenger:
	echo "APP_NAME=messenger" >> $GITHUB_ENV
	echo "VARIANT=drv" >> $GITHUB_ENV
	# Arm64-v8a
	get_patches_key "messenger"
	get_apkpure "com.facebook.orca" "messenger-arm64-v8a" "facebook-messenger/com.facebook.orca"
	patch "messenger-arm64-v8a" "derevanced" "morphe"
}

photos() {
	derevanced_dl
	# Patch Google photos:
	echo "APP_NAME=google-photos" >> $GITHUB_ENV
	echo "VARIANT=drv" >> $GITHUB_ENV
	# Arm64-v8a
	get_patches_key "gg-photos"
	get_apk "com.google.android.apps.photos" "gg-photos-arm64-v8a" "photos" "google-inc/photos/google-photos" "arm64-v8a" "nodpi"
	patch "gg-photos-arm64-v8a" "derevanced" "morphe"
}

instagram() {
	# Patch Instagram:
	echo "APP_NAME=instagram" >> $GITHUB_ENV
	echo "VARIANT=brosssh" >> $GITHUB_ENV

	brosssh_dl
	get_patches_key "instagram"
	get_apkpure "com.instagram.android" "instagram-arm64-v8a" "instagram-android/com.instagram.android" "Bundle"
	patch "instagram-arm64-v8a" "brosssh" "morphe"
}

instagram-piko() {
	# Patch Instagram:
	echo "APP_NAME=instagram" >> $GITHUB_ENV
	echo "VARIANT=piko" >> $GITHUB_ENV

	piko_dl
	# Patch Instagram
	get_patches_key "instagram-piko"
	get_apkpure "com.instagram.android" "instagram-arm64-v8a" "instagram-android/com.instagram.android" "Bundle"
	patch "instagram-arm64-v8a" "piko" "morphe"
}

komoot() {
	echo "APP_NAME=komoot" >> $GITHUB_ENV
	echo "VARIANT=brosssh" >> $GITHUB_ENV

	brosssh_dl
	get_patches_key "komoot"
	# https://apkpure.com/komoot-hike-bike-run/de.komoot.android
	get_apkpure "de.komoot.android" "komoot-arm64-v8a" "komoot-hike-bike-run/de.komoot.android" "Bundle"
	patch "komoot-arm64-v8a" "brosssh" "morphe"
}

fotmob() {
	echo "APP_NAME=fotmob" >> $GITHUB_ENV
	echo "VARIANT=hoo-dles" >> $GITHUB_ENV

	hoo-dles_dl
	get_patches_key "fotmob"
	# https://apkpure.com/fotmob-soccer-live-scores/com.mobilefootie.wc2010
	get_apkpure "com.mobilefootie.wc2010" "fotmob-arm64-v8a" "fotmob-soccer-live-scores/com.mobilefootie.wc2010" "Bundle"
	patch "fotmob-arm64-v8a" "hoo-dles" "morphe"
}

windy() {
	echo "APP_NAME=windy" >> $GITHUB_ENV
	echo "VARIANT=hoo-dles" >> $GITHUB_ENV

	hoo-dles_dl
	get_patches_key "windy"
	# https://apkpure.com/windy-com-weather-forecast/com.windyty.android
	get_apkpure "com.windyty.android" "windy-arm64-v8a" "windy-com-weather-forecast/com.windyty.android" "Bundle"
	patch "windy-arm64-v8a" "hoo-dles" "morphe"
}

facebook() {
	derevanced_dl
	# Patch Facebook:
	echo "APP_NAME=facebook" >> $GITHUB_ENV
	echo "VARIANT=drv" >> $GITHUB_ENV
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
	echo "VARIANT=drv" >> $GITHUB_ENV
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
	instagram-piko)
		instagram-piko
		;;
	facebook)
		facebook
		;;
	strava)
		strava
		;;
	komoot)
		komoot
		;;
	fotmob)
		fotmob
		;;
	windy)
		windy
		;;
esac
