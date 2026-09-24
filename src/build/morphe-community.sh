#!/bin/bash
# Morphe Community build
source ./src/build/utils.sh

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
	dl_gh "morphe-desktop" "MorpheApp" "latest"
	morphe_universal_dl
	dl_gh "De-Vanced" "RookieEnough" "$tag"
}

rushi_dl(){
	dl_gh "morphe-desktop" "MorpheApp" "latest"
	morphe_universal_dl
	dl_gh "morphe-patches" "rushiranpise" "$tag"
}

piko_dl(){
	dl_gh "morphe-desktop" "MorpheApp" "latest"
	morphe_universal_dl
	dl_gh "piko" "crimera" "$tag"
}

binarymend_dl(){
	dl_gh "morphe-desktop" "MorpheApp" "latest"
	morphe_universal_dl
	dl_gh "morphe-patches" "binarymend" "$tag"
}

hoo-dles_dl(){
	dl_gh "morphe-desktop" "MorpheApp" "latest"
	morphe_universal_dl
	dl_gh "morphe-patches" "hoo-dles" "$tag"
}

entree_dl(){
	dl_gh "morphe-desktop" "MorpheApp" "latest"
	morphe_universal_dl
	dl_gh "Morning-Entree-Patches" "Entree3k" "$tag"
}

dh6k_dl(){
	dl_gh "morphe-desktop" "MorpheApp" "latest"
	morphe_universal_dl
	dl_gh "morphe-patches" "dh6k" "$tag"
}

hooman_dl(){
	dl_gh "morphe-desktop" "MorpheApp" "latest"
	morphe_universal_dl
	dl_gh "hoomans-morphe-patches" "arandomhooman" "$tag"
}

tiktok_dl(){
	dl_gh "morphe-desktop" "MorpheApp" "latest"
	morphe_universal_dl
	dl_gh "tiktok-patches-for-morphe" "icysymmetra" "$tag"
}

adobo_dl(){
	dl_gh "morphe-desktop" "MorpheApp" "latest"
	morphe_universal_dl
	dl_gh "adobo" "jkennethcarino" "$tag"
}

andrew_dl(){
	dl_gh "morphe-desktop" "MorpheApp" "latest"
	morphe_universal_dl
	dl_gh "morphe-patches" "andrewliang25" "$tag"
}

prathxm_dl(){
	dl_gh "morphe-desktop" "MorpheApp" "latest"
	morphe_universal_dl
	dl_gh "Prathxm-Patches" "PrathxmOp" "$tag"
}

######################
####### andrew #######
######################
facebook-andrew() {
	APP_NAME="facebook"
	VARIANT="andrew"
	echo "APP_NAME=$APP_NAME" >> $GITHUB_ENV
	echo "VARIANT=$VARIANT" >> $GITHUB_ENV

	andrew_dl
	get_patches_key "facebook-andrew"
	version="577.0.0.50.72"
	get_apk "com.facebook.katana" "facebook-arm64-v8a" "bundle" "arm64-v8a" "160-640dpi" "Android 11+"

	release_exists && return 0

	detachPlayStoreUpdates=true
	community_patch "facebook-arm64-v8a" "andrew"
}

######################
####### rushi ########
######################
photos() {
	APP_NAME="google-photos"
	VARIANT="rushi"
	echo "APP_NAME=$APP_NAME" >> $GITHUB_ENV
	echo "VARIANT=$VARIANT" >> $GITHUB_ENV

	rushi_dl
	get_patches_key "gg-photos"
	get_apk "com.google.android.apps.photos" "gg-photos-arm64-v8a" "apk"

	release_exists && return 0

	community_patch "gg-photos-arm64-v8a" "rushi"
}

messenger-clone() {
	APP_NAME="messenger-clone"
	VARIANT="rushi"
	echo "APP_NAME=$APP_NAME" >> $GITHUB_ENV
	echo "VARIANT=$VARIANT" >> $GITHUB_ENV

	rushi_dl
	get_patches_key "messenger-clone"

	local clone_pkg="app.morphe.messenger.orca"
	if [[ "$includePatches" =~ messengerPackageName=([^[:space:],]+) ]]; then
		clone_pkg="${BASH_REMATCH[1]}"
	fi

	if [[ "$includePatches" != *"Spoof app signature"* && "$communityIncludePatches" != *"Spoof app signature"* ]]; then
		includePatches+=" -e \"Spoof app signature\" -O packageName=$clone_pkg"
	fi

	get_apk "com.facebook.orca" "messenger-clone-arm64-v8a" "apk" "arm64-v8a" "nodpi" "Android 9.0+"

	release_exists && return 0

	community_patch "messenger-clone-arm64-v8a" "rushi"
}

messenger() {
	APP_NAME="messenger"
	VARIANT="rushi"
	echo "APP_NAME=$APP_NAME" >> $GITHUB_ENV
	echo "VARIANT=$VARIANT" >> $GITHUB_ENV

	rushi_dl
	get_patches_key "messenger"

	local latest_vc
	latest_vc=$(get_apkmirror_version_code "com.facebook.orca" "arm64-v8a" "nodpi")
	if [[ -n "$latest_vc" ]]; then
		green_log "[+] Using latest APKMirror versionCode ($latest_vc) for Spoof package version"
		if [[ "$includePatches" == *"Spoof package version"* ]]; then
			includePatches="${includePatches/-e \"Spoof package version\"/-e \"Spoof package version\" -O messengerVersionCode=$latest_vc}"
		elif [[ "$communityIncludePatches" == *"Spoof package version"* ]]; then
			communityIncludePatches="${communityIncludePatches/-e \"Spoof package version\"/-e \"Spoof package version\" -O messengerVersionCode=$latest_vc}"
		else
			includePatches+=" -e \"Spoof package version\" -O messengerVersionCode=$latest_vc"
		fi
	else
		yellow_log "[!] Could not fetch latest versionCode from APKMirror, using patch default"
	fi

	get_apk "com.facebook.orca" "messenger-arm64-v8a" "apk" "arm64-v8a" "nodpi" "Android 9.0+"

	release_exists && return 0

	community_patch "messenger-arm64-v8a" "rushi"
}

adguard() {
	APP_NAME="adguard"
	VARIANT="rushi"
	echo "APP_NAME=$APP_NAME" >> $GITHUB_ENV
	echo "VARIANT=$VARIANT" >> $GITHUB_ENV

	rushi_dl
	get_patches_key "adguard"
	get_apk "com.adguard.android" "adguard" "apk"

	release_exists && return 0

	community_patch "adguard" "rushi"
}

windy() {
	APP_NAME="windy"
	VARIANT="rushi"
	echo "APP_NAME=$APP_NAME" >> $GITHUB_ENV
	echo "VARIANT=$VARIANT" >> $GITHUB_ENV

	rushi_dl
	get_patches_key "windy"
	get_apk "com.windyty.android" "windy-arm64-v8a" "bundle" "universal" "120-640dpi" "Android 12L+"

	release_exists && return 0

	community_patch "windy-arm64-v8a" "rushi"
}

komoot() {
	APP_NAME="komoot"
	VARIANT="rushi"
	echo "APP_NAME=$APP_NAME" >> $GITHUB_ENV
	echo "VARIANT=$VARIANT" >> $GITHUB_ENV

	rushi_dl
	get_patches_key "komoot"
	get_apk "de.komoot.android" "komoot-arm64-v8a" "bundle"

	release_exists && return 0

	community_patch "komoot-arm64-v8a" "rushi"
}

strava() {
	APP_NAME="strava"
	VARIANT="rushi"
	# echo "APP_NAME=$APP_NAME" >> $GITHUB_ENV
	# echo "VARIANT=$VARIANT" >> $GITHUB_ENV

	# rushi_dl
	# get_patches_key "strava"
	# get_apk_uptodown "com.strava" "strava-arm64-v8a" "bundle"

	# release_exists && return 0

	# community_patch "strava-arm64-v8a" "rushi"
}

homeworkout() {
	APP_NAME="homeworkout"
	VARIANT="rushi"
	# echo "APP_NAME=$APP_NAME" >> $GITHUB_ENV
	# echo "VARIANT=$VARIANT" >> $GITHUB_ENV

	# rushi_dl
	# get_patches_key "homeworkout"
	# get_apk_uptodown "homeworkout.homeworkouts.noequipment" "homeworkout" "apk"

	# release_exists && return 0

	# community_patch "homeworkout" "rushi"
}

######################
######## Piko ########
######################
instagram-piko() {
	APP_NAME="instagram"
	VARIANT="piko"
	echo "APP_NAME=$APP_NAME" >> $GITHUB_ENV
	echo "VARIANT=$VARIANT" >> $GITHUB_ENV

	piko_dl
	get_patches_key "instagram-piko"
	get_apk "com.instagram.android" "instagram-arm64-v8a" "bundle" "arm64-v8a" "120-640dpi" "Android 9.0+"

	release_exists && return 0

	community_patch "instagram-arm64-v8a" "piko"
}

######################
####### hoo-dles #####
######################
fotmob() {
	APP_NAME="fotmob"
	VARIANT="hoo-dles"
	echo "APP_NAME=$APP_NAME" >> $GITHUB_ENV
	echo "VARIANT=$VARIANT" >> $GITHUB_ENV

	hoo-dles_dl
	get_patches_key "fotmob"
	get_apk "com.mobilefootie.wc2010" "fotmob-arm64-v8a" "bundle" "universal" "nodpi" "Android 12L+"

	release_exists && return 0

	community_patch "fotmob-arm64-v8a" "hoo-dles"
}

######################
##### binarymend #####
######################
moonreader() {
	APP_NAME="moonreader"
	VARIANT="binarymend"
	echo "APP_NAME=$APP_NAME" >> $GITHUB_ENV
	echo "VARIANT=$VARIANT" >> $GITHUB_ENV

	binarymend_dl
	get_patches_key "moonreader"
	get_apk "com.flyersoft.moonreader" "moonreader-arm64-v8a" "bundle"

	release_exists && return 0

	community_patch "moonreader-arm64-v8a" "binarymend"
}

######################
####### dh6k #########
######################
brave() {
	APP_NAME="brave"
	VARIANT="dh6k"
	echo "APP_NAME=$APP_NAME" >> $GITHUB_ENV
	echo "VARIANT=$VARIANT" >> $GITHUB_ENV

	dh6k_dl
	get_patches_key "brave"
	get_apk "com.brave.browser" "brave-arm64-v8a" "bundle" "arm64-v8a"

	release_exists && return 0

	community_patch "brave-arm64-v8a" "dh6k"
}

######################
###### hooman ########
######################
poweramp() {
	APP_NAME="poweramp"
	VARIANT="hooman"
	echo "APP_NAME=$APP_NAME" >> $GITHUB_ENV
	echo "VARIANT=$VARIANT" >> $GITHUB_ENV

	hooman_dl
	get_patches_key "poweramp"
	get_apk "com.maxmpz.audioplayer" "poweramp" "bundle"

	release_exists && return 0

	community_patch "poweramp" "hooman"
}

symfonium() {
	APP_NAME="symfonium"
	VARIANT="hooman"
	echo "APP_NAME=$APP_NAME" >> $GITHUB_ENV
	echo "VARIANT=$VARIANT" >> $GITHUB_ENV

	hooman_dl
	get_patches_key "symfonium"
	get_apk "app.symfonik.music.player" "symfonium-arm64-v8a" "bundle" "arm64-v8a"

	release_exists && return 0

	community_patch "symfonium-arm64-v8a" "hooman"
}

######################
#### icysymmetra #####
######################
tiktok() {
	APP_NAME="tiktok"
	VARIANT="icysymmetra"
	echo "APP_NAME=$APP_NAME" >> $GITHUB_ENV
	echo "VARIANT=$VARIANT" >> $GITHUB_ENV

	tiktok_dl
	get_patches_key "tiktok"
	get_apk "com.zhiliaoapp.musically" "tiktok-arm64-v8a" "bundle" "arm64-v8a" || \
	get_apk_uptodown "com.zhiliaoapp.musically" "tiktok-arm64-v8a" "apk"

	release_exists && return 0

	community_patch "tiktok-arm64-v8a" "icysymmetra"
}

######################
###### prathxm #######
######################
chess() {
	APP_NAME="chess"
	VARIANT="prathxm"
	echo "APP_NAME=$APP_NAME" >> $GITHUB_ENV
	echo "VARIANT=$VARIANT" >> $GITHUB_ENV

	prathxm_dl
	get_patches_key "chess"
	get_apk "com.chess" "chess" "apk"

	release_exists && return 0

	community_patch "chess" "prathxm"
}

######################
####### adobo ########
######################
reddit-adobo() {
	APP_NAME="reddit"
	VARIANT="adobo"
	echo "APP_NAME=$APP_NAME" >> $GITHUB_ENV
	echo "VARIANT=$VARIANT" >> $GITHUB_ENV

	adobo_dl
	get_patches_key "reddit-adobo"
	get_apk "com.reddit.frontpage" "reddit" "bundle_extract"

	release_exists && return 0

	# Patch Arm64-v8a:
	split_editor "reddit" "reddit-arm64-v8a" "exclude" "split_config.armeabi_v7a split_config.x86_64 split_config.mdpi split_config.ldpi split_config.hdpi split_config.xhdpi split_config.xxhdpi split_config.tvdpi"
	for patches_file in morphe-universal-*.mpp.disabled; do
		[ -e "$patches_file" ] || continue
		mv "$patches_file" "${patches_file%.disabled}"
	done
	separate_morphe_universal_patches=false
	get_patches_key "reddit-adobo"
	patch "reddit-arm64-v8a" "adobo" "morphe"
}

case "$1" in
	messenger)
		messenger
		;;
	messenger-clone)
		messenger-clone
		;;
	photos)
		photos
		;;
	instagram-piko)
		instagram-piko
		;;
	strava)
		strava
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
	komoot)
		komoot
		;;
	homeworkout)
		homeworkout
		;;
	brave)
		brave
		;;
	poweramp)
		poweramp
		;;
	symfonium)
		symfonium
		;;
	tiktok)
		tiktok
		;;
	reddit-adobo)
		reddit-adobo
		;;
	facebook-andrew)
		facebook-andrew
		;;
	chess)
		chess
		;;
esac
