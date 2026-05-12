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

separate_morphe_universal_patches=true

morphe_universal_dl() {
	dl_gh "morphe-patches" "MorpheApp" "$tag"
	for patches_file in patches-*.mpp; do
		[ -e "$patches_file" ] || continue
		mv "$patches_file" "morphe-universal-$patches_file.disabled"
	done
}

community_patch() {
	patch "$1" "$2" "morphe"
	if [ "${detachPlayStoreUpdates:-false}" = true ]; then
		morphe_disable_play_store_updates "$1" "$2"
	fi
	unset detachPlayStoreUpdates
}

derevanced_dl(){
	dl_gh "morphe-cli" "MorpheApp" "latest"
	morphe_universal_dl
	dl_gh "De-ReVanced" "RookieEnough" "$tag"
}

hoo-dles_dl() {
	dl_gh "morphe-cli" "MorpheApp" "latest"
	morphe_universal_dl
	dl_gh "morphe-patches" "hoo-dles" "$tag"
}

brosssh_dl() {
	dl_gh "morphe-cli" "MorpheApp" "latest"
	morphe_universal_dl
	dl_gh "morphe-patches" "brosssh" "$tag"
}

piko_dl(){
	dl_gh "morphe-cli" "MorpheApp" "latest"
	morphe_universal_dl
	dl_gh "piko" "crimera" "prerelease"
}

binarymend_dl(){
	dl_gh "morphe-cli" "MorpheApp" "latest"
	morphe_universal_dl
	dl_gh "morphe-patches" "binarymend" "$tag"
}

meridianfresco_dl(){
	dl_gh "morphe-cli" "MorpheApp" "latest"
	morphe_universal_dl
	dl_gh "morphe-meta-patches" "meridianfresco" "$tag"
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
	get_apk "com.facebook.orca" "messenger-arm64-v8a" "apk" "arm64-v8a" "nodpi" "Android 9.0+"
	release_exists && return 0
	community_patch "messenger-arm64-v8a" "derevanced"
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
	get_apk "com.google.android.apps.photos" "gg-photos-arm64-v8a" "apk" "arm64-v8a" "nodpi"
	release_exists && return 0
	community_patch "gg-photos-arm64-v8a" "derevanced"
}

facebook() {
	meridianfresco_dl
	# Patch Facebook:
	APP_NAME="facebook"
	VARIANT="drv"
	echo "APP_NAME=$APP_NAME" >> $GITHUB_ENV
	echo "VARIANT=$VARIANT" >> $GITHUB_ENV
	# Arm64-v8a
	get_patches_key "facebook"
	get_apk "com.facebook.orca" "facebook-arm64-v8a" "bundle" "arm64-v8a" "nodpi" "Android 11+"
	release_exists && return 0
	community_patch "facebook-arm64-v8a" "meridianfresco"
}

strava() {
	derevanced_dl
	# Patch Strava:
	APP_NAME="strava"
	VARIANT="drv"
	echo "APP_NAME=$APP_NAME" >> $GITHUB_ENV
	echo "VARIANT=$VARIANT" >> $GITHUB_ENV
	get_patches_key "strava"
	get_apkpure "com.strava" "strava-arm64-v8a" "bundle"
	release_exists && return 0
	community_patch "strava-arm64-v8a" "derevanced"
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
	get_apk "com.instagram.android" "instagram-arm64-v8a" "bundle" "arm64-v8a" "120-640dpi"  "Android 9.0+"
	release_exists && return 0
	community_patch "instagram-arm64-v8a" "piko"
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
	get_apk "com.instagram.android" "instagram-arm64-v8a" "bundle" "arm64-v8a" "120-640dpi"  "Android 9.0+"
	release_exists && return 0
	community_patch "instagram-arm64-v8a" "brosssh"
}

komoot() {
	APP_NAME="komoot"
	VARIANT="brosssh"
	echo "APP_NAME=$APP_NAME" >> $GITHUB_ENV
	echo "VARIANT=$VARIANT" >> $GITHUB_ENV

	brosssh_dl
	get_patches_key "komoot"
	# https://apkpure.com/komoot-hike-bike-run/de.komoot.android
	get_apkpure "de.komoot.android" "komoot-arm64-v8a" "bundle"
	release_exists && return 0
	community_patch "komoot-arm64-v8a" "brosssh"
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
	community_patch "adguard" "hoo-dles"
}

fotmob() {
	APP_NAME="fotmob"
	VARIANT="hoo-dles"
	echo "APP_NAME=$APP_NAME" >> $GITHUB_ENV
	echo "VARIANT=$VARIANT" >> $GITHUB_ENV

	hoo-dles_dl
	get_patches_key "fotmob"
	# https://apkpure.com/fotmob-soccer-live-scores/com.mobilefootie.wc2010
	get_apkpure "com.mobilefootie.wc2010" "fotmob-arm64-v8a" "bundle"
	release_exists && return 0
	community_patch "fotmob-arm64-v8a" "hoo-dles"
}

windy() {
	APP_NAME="windy"
	VARIANT="hoo-dles"
	echo "APP_NAME=$APP_NAME" >> $GITHUB_ENV
	echo "VARIANT=$VARIANT" >> $GITHUB_ENV

	hoo-dles_dl
	get_patches_key "windy"
	# https://apkpure.com/windy-com-weather-forecast/com.windyty.android
	get_apkpure "com.windyty.android" "windy-arm64-v8a" "bundle"
	release_exists && return 0
	community_patch "windy-arm64-v8a" "hoo-dles"
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
	get_apkpure "com.flyersoft.moonreader" "moonreader-arm64-v8a" "bundle"
	release_exists && return 0
	community_patch "moonreader-arm64-v8a" "binarymend"
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
