#!/bin/bash
# Xposed build
source ./src/build/utils.sh

LSPatch_dl(){
	dl_gh "LSPatch" "JingMatrix" "latest"
}

patch_dl(){
	dl_gh "NexAlloy" "gnadgnaoh" "v1.0"
}

use_beta="${use_beta:-false}"

if [ "$use_beta" = false ]; then
	tag="latest"
else
	tag="prerelease"
fi

xposed_morphe_universal_dl() {
	dl_gh "morphe-patches" "MorpheApp" "$tag"
	for patches_file in patches-*.mpp; do
		[ -e "$patches_file" ] || continue
		mv "$patches_file" "morphe-universal-$patches_file.disabled"
	done
}

xposed_dl() {
	LSPatch_dl
	xposed_morphe_universal_dl
	if [ "$use_beta" = true ]; then
		dl_gh "morphe-desktop" "MorpheApp" "prerelease"
		dl_gh "NexAlloy" "gnadgnaoh" "prerelease"
	else
		dl_gh "morphe-desktop" "MorpheApp" "latest"
		patch_dl
	fi
}

xposed_disable_play_store_updates() {
	local variant="playstore-detached"
	cp "./download/$1.apk" "./release/$1-$variant.apk"
	morphe_disable_play_store_updates "$1" "$variant"
	mv "./release/$1-$variant.apk" "./download/$1.apk"
}

xposed_facebook_dl() {
	dl_gh "morphe-patches" "andrewliang25" "$tag"
}

xposed_facebook_prepatch() {
	local input_apk="./download/$1.apk"
	local prepatch_apk="./download/$1-prepatched.apk"
	local patches_args

	get_patches_key "facebook-xposed"
	patches_args="$(morphe_patches_args "-p" "patches-*.mpp")"

	if [ -n "$patches_args" ]; then
		green_log "[+] Applying Morphe background patches to $1:"
		if eval java -jar morphe-desktop-*.jar patch $patches_args --options-file ./src/options/andrew.json \
			--out="$prepatch_apk"$communityExcludePatches$communityIncludePatches \
			--keystore=./src/morphe.keystore --force --continue-on-error "$input_apk"; then
			mv "$prepatch_apk" "$input_apk"
		else
			red_log "[-] Warning: Failed to apply Morphe background patches for $1, continuing with original APK"
		fi
	fi

	xposed_disable_play_store_updates "$1"
}

facebook() {
	APP_NAME="facebook"
	VARIANT="xposed"
	echo "APP_NAME=$APP_NAME" >> $GITHUB_ENV
	echo "VARIANT=$VARIANT" >> $GITHUB_ENV
	echo "patch_version=1" >> $GITHUB_ENV

	xposed_dl
	xposed_facebook_dl
	version="577.0.0.50.72"
	get_apk "com.facebook.katana" "facebook-arm64-v8a" "bundle" "arm64-v8a" "160-640dpi" "Android 11+"

	release_exists && return 0

	xposed_facebook_prepatch "facebook-arm64-v8a"
	lspatch "facebook-arm64-v8a" "NexAlloy-nonroot*.apk" "gnadgnaoh" "--injectdex --sigbypasslv 3"
}

instagram() {
	APP_NAME="instagram"
	VARIANT="xposed"
	echo "APP_NAME=$APP_NAME" >> $GITHUB_ENV
	echo "VARIANT=$VARIANT" >> $GITHUB_ENV
	echo "patch_version=1" >> $GITHUB_ENV

	xposed_dl
	get_apk "com.instagram.android" "instagram-arm64-v8a" "bundle" "arm64-v8a" "120-640dpi" "Android 9.0+"

	release_exists && return 0

	xposed_disable_play_store_updates "instagram-arm64-v8a"
	lspatch "instagram-arm64-v8a" "NexAlloy-nonroot*.apk" "gnadgnaoh" "--injectdex --sigbypasslv 3"
}

case "$1" in
    facebook)
        facebook
        ;;
    instagram)
        instagram
        ;;
esac
