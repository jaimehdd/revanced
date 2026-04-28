#!/bin/bash
# Morphe Community build
source ./src/build/utils.sh
# Download requirements
use_beta="${use_beta:-false}"

if [ "$use_beta" = false ]; then
	tag="latest"
else
	tag="prerelease"
fi

derevanced_dl(){
	dl_gh "morphe-cli" "MorpheApp" "latest"
	dl_gh "De-ReVanced" "RookieEnough" "$tag"
}

hoo-dles_dl() {
	dl_gh "morphe-cli" "MorpheApp" "latest"
	dl_gh "morphe-patches" "hoo-dles" "$tag"
}

brosssh_dl() {
	dl_gh "morphe-cli" "MorpheApp" "latest"
	dl_gh "morphe-patches" "brosssh" "$tag"
}

piko_dl(){
	dl_gh "morphe-cli" "MorpheApp" "latest"
	dl_gh "piko" "crimera" "prerelease"
}

binarymend_dl(){
	dl_gh "morphe-cli" "MorpheApp" "latest"
	dl_gh "morphe-patches" "binarymend" "$tag"
}

#############
# De-ReVanced
#############
messenger() {
	derevanced_dl
	# Patch Messenger:
	APP_NAME="messenger"
	VARIANT="drv"
	echo "APP_NAME=$APP_NAME" >> $GITHUB_ENV
	echo "VARIANT=$VARIANT" >> $GITHUB_ENV
	# Arm64-v8a
	get_patches_key "messenger"
	get_apkpure "com.facebook.orca" "messenger-arm64-v8a" "facebook-messenger/com.facebook.orca"
	release_exists && return 0
	patch "messenger-arm64-v8a" "derevanced" "morphe"
}

photos() {
	derevanced_dl
	# Patch Google photos:
	APP_NAME="google-photos"
	VARIANT="drv"
	echo "APP_NAME=$APP_NAME" >> $GITHUB_ENV
	echo "VARIANT=$VARIANT" >> $GITHUB_ENV
	# Arm64-v8a
	get_patches_key "gg-photos"
	get_apk "com.google.android.apps.photos" "gg-photos-arm64-v8a" "photos" "google-inc/photos/google-photos" "arm64-v8a" "nodpi"
	release_exists && return 0
	patch "gg-photos-arm64-v8a" "derevanced" "morphe"
}

facebook() {
	derevanced_dl
	# Patch Facebook:
	APP_NAME="facebook"
	VARIANT="drv"
	echo "APP_NAME=$APP_NAME" >> $GITHUB_ENV
	echo "VARIANT=$VARIANT" >> $GITHUB_ENV
	# Arm64-v8a
	get_patches_key "facebook"
	version="490.0.0.63.82"
	echo "APP_VERSION=$version" >> $GITHUB_ENV
	release_exists && return 0
	url="https://d.apkpure.com/b/APK/com.facebook.katana?versionCode=457020014"
	req "$url" "facebook-arm64-v8a.apk"
	patch "facebook-arm64-v8a" "derevanced" "morphe"
}

strava() {
	derevanced_dl
	# Patch Strava:
	APP_NAME="strava"
	VARIANT="drv"
	echo "APP_NAME=$APP_NAME" >> $GITHUB_ENV
	echo "VARIANT=$VARIANT" >> $GITHUB_ENV
	get_patches_key "strava"
	get_apkpure "com.strava" "strava-arm64-v8a" "strava-run-hike-android-exercise-laugh/com.strava" "Bundle"
	release_exists && return 0
	patch "strava-arm64-v8a" "derevanced" "morphe"
}

#############
# Piko
#############
instagram-piko() {
	# Patch Instagram:
	APP_NAME="instagram"
	VARIANT="piko"
	echo "APP_NAME=$APP_NAME" >> $GITHUB_ENV
	echo "VARIANT=$VARIANT" >> $GITHUB_ENV

	piko_dl
	# Patch Instagram
	get_patches_key "instagram-piko"
	get_apkpure "com.instagram.android" "instagram-arm64-v8a" "instagram-android/com.instagram.android" "Bundle"
	release_exists && return 0
	patch "instagram-arm64-v8a" "piko" "morphe"
}

#############
# Brosssh
#############
instagram() {
	# Patch Instagram:
	APP_NAME="instagram"
	VARIANT="brosssh"
	echo "APP_NAME=$APP_NAME" >> $GITHUB_ENV
	echo "VARIANT=$VARIANT" >> $GITHUB_ENV

	brosssh_dl
	get_patches_key "instagram"
	get_apkpure "com.instagram.android" "instagram-arm64-v8a" "instagram-android/com.instagram.android" "Bundle"
	release_exists && return 0
	patch "instagram-arm64-v8a" "brosssh" "morphe"
}

komoot() {
	APP_NAME="komoot"
	VARIANT="brosssh"
	echo "APP_NAME=$APP_NAME" >> $GITHUB_ENV
	echo "VARIANT=$VARIANT" >> $GITHUB_ENV

	brosssh_dl
	get_patches_key "komoot"
	# https://apkpure.com/komoot-hike-bike-run/de.komoot.android
	get_apkpure "de.komoot.android" "komoot-arm64-v8a" "komoot-hike-bike-run/de.komoot.android" "Bundle"
	release_exists && return 0
	patch "komoot-arm64-v8a" "brosssh" "morphe"
}

#############
# Hoo-dles
#############
adguard() {
	APP_NAME="adguard"
	VARIANT="hoo-dles"
	echo "APP_NAME=$APP_NAME" >> $GITHUB_ENV
	echo "VARIANT=$VARIANT" >> $GITHUB_ENV

	hoo-dles_dl
	get_patches_key "adguard"
	get_apk "com.adguard.android" "adguard" "adguard" "adguard-software-limited/adguard/adguard-for-android"
	release_exists && return 0
	patch "adguard" "hoo-dles" "morphe"
}

fotmob() {
	APP_NAME="fotmob"
	VARIANT="hoo-dles"
	echo "APP_NAME=$APP_NAME" >> $GITHUB_ENV
	echo "VARIANT=$VARIANT" >> $GITHUB_ENV

	hoo-dles_dl
	get_patches_key "fotmob"
	# https://apkpure.com/fotmob-soccer-live-scores/com.mobilefootie.wc2010
	get_apkpure "com.mobilefootie.wc2010" "fotmob-arm64-v8a" "fotmob-soccer-live-scores/com.mobilefootie.wc2010" "Bundle"
	release_exists && return 0
	patch "fotmob-arm64-v8a" "hoo-dles" "morphe"
}

windy() {
	APP_NAME="windy"
	VARIANT="hoo-dles"
	echo "APP_NAME=$APP_NAME" >> $GITHUB_ENV
	echo "VARIANT=$VARIANT" >> $GITHUB_ENV

	hoo-dles_dl
	get_patches_key "windy"
	# https://apkpure.com/windy-com-weather-forecast/com.windyty.android
	get_apkpure "com.windyty.android" "windy-arm64-v8a" "windy-com-weather-forecast/com.windyty.android" "Bundle"
	release_exists && return 0
	patch "windy-arm64-v8a" "hoo-dles" "morphe"
}

#############
# Binarymend
#############
moonreader() {
	APP_NAME="moonreader"
	VARIANT="binarymend"
	echo "APP_NAME=$APP_NAME" >> $GITHUB_ENV
	echo "VARIANT=$VARIANT" >> $GITHUB_ENV

	binarymend_dl
	get_patches_key "moonreader"
	# https://apkpure.com/moon-reader/com.flyersoft.moonreader
	get_apkpure "com.flyersoft.moonreader" "moonreader-arm64-v8a" "moon-reader/com.flyersoft.moonreader" "Bundle"
	release_exists && return 0
	patch "moonreader-arm64-v8a" "binarymend" "morphe"
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
	moonreader)
		moonreader
		;;
	adguard)
		adguard
		;;
esac
