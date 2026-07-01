#!/bin/bash
# Xposed build
source ./src/build/utils.sh

NPatch_dl(){
	dl_gh "NPatch" "7723mod" "latest"
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
	NPatch_dl
	if [ "$use_beta" = true ]; then
		dl_gh "morphe-cli" "MorpheApp" "prerelease"
		dl_gh "NexAlloy" "gnadgnaoh" "prerelease"
	else
		dl_gh "morphe-cli" "MorpheApp" "latest"
		dl_gh "NexAlloy" "gnadgnaoh" "v5.0"
	fi
	xposed_morphe_universal_dl
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
	version="567.1.0.52.74"
	get_apk "com.facebook.katana" "facebook-arm64-v8a" "bundle" "arm64-v8a" "nodpi" "Android 11+"

	release_exists && return 0

	xposed_disable_play_store_updates "facebook-arm64-v8a"
	npatch "facebook-arm64-v8a" "NexAlloy-nonroot-release*.apk" "gnadgnaoh" "--injectdex --sigbypasslv 3"
}

messenger() {
	APP_NAME="messenger"
	VARIANT="xposed"
	echo "APP_NAME=$APP_NAME" >> $GITHUB_ENV
	echo "VARIANT=$VARIANT" >> $GITHUB_ENV
	echo "patch_version=1" >> $GITHUB_ENV

	xposed_dl
	get_apk "com.facebook.orca" "messenger-arm64-v8a" "apk" "arm64-v8a" "nodpi" "Android 9.0+"

	release_exists && return 0

	xposed_disable_play_store_updates "messenger-arm64-v8a"
	npatch "messenger-arm64-v8a" "NexAlloy-nonroot-release*.apk" "gnadgnaoh" "--injectdex --sigbypasslv 3"
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
	npatch "instagram-arm64-v8a" "NexAlloy-nonroot-release*.apk" "gnadgnaoh" "--injectdex --sigbypasslv 3"
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
