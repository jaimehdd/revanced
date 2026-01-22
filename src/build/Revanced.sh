#!/bin/bash
# Revanced build
source ./src/build/utils.sh
# Download requirements
use_beta="${use_beta:-false}"

revanced_dl_beta(){
	dl_gh "revanced-cli" "revanced" "latest"
	dl_gh "revanced-patches" "revanced" "prerelease"
}

revanced_dl(){
	if [ "$use_beta" = true ]; then
		revanced_dl_beta
	else
		dl_gh "revanced-patches revanced-cli" "revanced" "latest"
	fi
}

2() {
	revanced_dl
	# Patch Messenger:
	echo "APP_NAME=messenger" >> $GITHUB_ENV
	echo "VARIANT=rv" >> $GITHUB_ENV
	# Arm64-v8a
	get_patches_key "messenger"
	# Download from Uptodown and extract version
	uptodown_page="https://facebook-messenger.en.uptodown.com/android/download"
	page_content=$(req "$uptodown_page" -)
	version=$(echo "$page_content" | $pup -p --charset utf-8 'span.version text{}' | head -1 | tr -d ' ')
	echo "APP_VERSION=$version" >> $GITHUB_ENV
	green_log "[+] Downloading messenger version: $version"
	url="https://dw.uptodown.com/dwn/$(echo "$page_content" | $pup -p --charset utf-8 'button#detail-download-button attr{data-url}')"
	req "$url" "messenger-arm64-v8a.apk"
	patch "messenger-arm64-v8a" "revanced"
}
3() {
	revanced_dl
	# Patch Google photos:
	echo "APP_NAME=google-photos" >> $GITHUB_ENV
	echo "VARIANT=rv" >> $GITHUB_ENV
	# Arm64-v8a
	get_patches_key "gg-photos"
	get_apk "com.google.android.apps.photos" "gg-photos-arm64-v8a" "photos" "google-inc/photos/google-photos" "arm64-v8a" "nodpi"
	patch "gg-photos-arm64-v8a" "revanced"
}
4() {
	echo "APP_NAME=instagram" >> $GITHUB_ENV
	echo "VARIANT=rv" >> $GITHUB_ENV

	# official ReVanced
	revanced_dl
	# Patch Instagram:
	get_patches_key "instagram"
	get_apkpure "com.instagram.android" "instagram-arm64-v8a" "instagram-android/com.instagram.android" "Bundle"
	patch "instagram-arm64-v8a" "revanced"
}
5() {
	revanced_dl
	# Patch Facebook:
	echo "APP_NAME=facebook" >> $GITHUB_ENV
	echo "VARIANT=rv" >> $GITHUB_ENV
	# Arm64-v8a
	get_patches_key "facebook"
	# Download from APKPure with specific version code
	# versionCode 457020009 = 490.0.0.63.82
	version="490.0.0.63.82"
	echo "APP_VERSION=$version" >> $GITHUB_ENV
	green_log "[+] Downloading facebook version: $version"
	url="https://d.apkpure.com/b/APK/com.facebook.katana?versionCode=457020009"
	req "$url" "facebook-arm64-v8a.apk"
	patch "facebook-arm64-v8a" "revanced"
}
10() {
	revanced_dl
	# Patch Strava:
	echo "APP_NAME=strava" >> $GITHUB_ENV
	echo "VARIANT=rv" >> $GITHUB_ENV
	get_patches_key "strava"
	get_apkpure "com.strava" "strava-arm64-v8a" "strava-run-hike-2025-health/com.strava" "Bundle"
	patch "strava-arm64-v8a" "revanced"
}
11() {
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
    2)
        2
        ;;
    3)
        3
        ;;
    4)
        4
        ;;
    5)
        5
        ;;
	10)
		10
		;;
	11)
		11
		;;
esac
