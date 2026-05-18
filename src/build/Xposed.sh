#!/bin/bash
# Xposed build
source ./src/build/utils.sh

LSPatch_dl(){
	dl_gh "LSPatch" "JingMatrix" "latest"
}

xposed_morphe_universal_dl() {
	dl_gh "morphe-patches" "MorpheApp" "latest"
	for patches_file in patches-*.mpp; do
		[ -e "$patches_file" ] || continue
		mv "$patches_file" "morphe-universal-$patches_file.disabled"
	done
}

xposed_dl() {
	LSPatch_dl
	dl_gh "morphe-cli" "MorpheApp" "latest"
	xposed_morphe_universal_dl
	dl_gh "NexAlloy" "gnadgnaoh" "latest"
}

xposed_disable_play_store_updates() {
	local variant="playstore-detached"
	cp "./download/$1.apk" "./release/$1-$variant.apk"
	morphe_disable_play_store_updates "$1" "$variant"
	mv "./release/$1-$variant.apk" "./download/$1.apk"
}

facebook() {
    APP_NAME="facebook"
	VARIANT="xposed"
	echo "APP_NAME=$APP_NAME" >> $GITHUB_ENV
	echo "VARIANT=$VARIANT" >> $GITHUB_ENV
	echo "patch_version=1" >> $GITHUB_ENV

	xposed_dl
	# Patch Facebook:
	version="561.0.0.42.67"
	get_apk "com.facebook.katana" "facebook-arm64-v8a" "bundle" "arm64-v8a" "nodpi" "Android 11+"
	xposed_disable_play_store_updates "facebook-arm64-v8a"
	lspatch "facebook-arm64-v8a" "NexAlloy-nonroot-release*.apk" "gnadgnaoh"
}

messenger() {
    APP_NAME="messenger"
	VARIANT="xposed"
	echo "APP_NAME=$APP_NAME" >> $GITHUB_ENV
	echo "VARIANT=$VARIANT" >> $GITHUB_ENV
	echo "patch_version=1" >> $GITHUB_ENV

	xposed_dl
	# Patch Messenger:
	get_apk "com.facebook.orca" "messenger-arm64-v8a" "apk" "arm64-v8a" "nodpi" "Android 9.0+"
	xposed_disable_play_store_updates "messenger-arm64-v8a"
	lspatch "messenger-arm64-v8a" "NexAlloy-nonroot-release*.apk" "gnadgnaoh"
}

instagram() {
    APP_NAME="instagram"
	VARIANT="xposed"
	echo "APP_NAME=$APP_NAME" >> $GITHUB_ENV
	echo "VARIANT=$VARIANT" >> $GITHUB_ENV
	echo "patch_version=1" >> $GITHUB_ENV

	xposed_dl
	# Patch Instagram:
	get_apk "com.instagram.android" "instagram-arm64-v8a" "bundle" "arm64-v8a" "120-640dpi"  "Android 9.0+"
	xposed_disable_play_store_updates "instagram-arm64-v8a"
	lspatch "instagram-arm64-v8a" "NexAlloy-nonroot-release*.apk" "gnadgnaoh"
}

case "$1" in
    facebook)
        facebook
        ;;
	messenger)
		messenger
		;;
    instagram)
        instagram
        ;;
esac
