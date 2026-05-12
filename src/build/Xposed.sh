#!/bin/bash
# Xposed build
source ./src/build/utils.sh

LSPatch_dl(){
	dl_gh "LSPatch" "JingMatrix" "latest"
}

facebook() {
    APP_NAME="facebook"
	VARIANT="xposed"
	echo "APP_NAME=$APP_NAME" >> $GITHUB_ENV
	echo "VARIANT=$VARIANT" >> $GITHUB_ENV

	LSPatch_dl
	dl_gh "NexAlloy" "gnadgnaoh" "prerelease"
	# Patch Facebook:
	get_apk "com.facebook.katana" "facebook-arm64-v8a" "bundle" "arm64-v8a" "nodpi" "Android 9+"
	lspatch "facebook-arm64-v8a" "NexAlloy*.apk" "gnadgnaoh"
}

instagram() {
    APP_NAME="instagram"
	VARIANT="xposed"
	echo "APP_NAME=$APP_NAME" >> $GITHUB_ENV
	echo "VARIANT=$VARIANT" >> $GITHUB_ENV

	LSPatch_dl
	dl_gh "NexAlloy" "gnadgnaoh" "prerelease"
	# Patch Instagram:
	get_apk "com.instagram.android" "instagram-arm64-v8a" "bundle" "arm64-v8a" "120-640dpi"  "Android 9.0+"
	lspatch "instagram-arm64-v8a" "NexAlloy*.apk" "gnadgnaoh"
}

case "$1" in
    facebook)
        facebook
        ;;
    instagram)
        instagram
        ;;
esac