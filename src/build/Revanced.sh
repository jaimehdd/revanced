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

1() {
	revanced_dl
	# Patch YouTube:
	echo "APP_NAME=youtube" >> $GITHUB_ENV
	echo "VARIANT=rv" >> $GITHUB_ENV
	get_patches_key "youtube-revanced"
	get_apk "com.google.android.youtube" "youtube" "youtube" "google-inc/youtube/youtube" "Bundle_extract"
	# Patch Youtube Arm64-v8a
	split_editor "youtube" "youtube-arm64-v8a" "exclude" "split_config.armeabi_v7a split_config.x86 split_config.x86_64"
	patch "youtube-arm64-v8a" "revanced"
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
	patch "messenger-arm64-v8a" "messenger-revanced"
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
	patch "instagram-arm64-v8a" "instagram-revanced"
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
	patch "facebook-arm64-v8a" "facebook-revanced"
}
6() {
	revanced_dl
	# Patch Tumblr:
	get_patches_key "tumblr"
	get_apk "com.tumblr" "tumblr" "tumblr" "tumblr-inc/tumblr/tumblr-social-media-art" "Bundle_extract"
	split_editor "tumblr" "tumblr"
	patch "tumblr" "revanced"
	# Patch Tumblr Arm64-v8a:
	get_patches_key "tumblr"
	split_editor "tumblr" "tumblr-arm64-v8a" "exclude" "split_config.armeabi_v7a split_config.x86 split_config.x86_64"
	patch "tumblr-arm64-v8a" "revanced"
	# Patch SoundCloud:
	get_patches_key "soundcloud"
	get_apk "com.soundcloud.android" "soundcloud" "soundcloud-soundcloud" "soundcloud/soundcloud-soundcloud/soundcloud-play-music-songs" "Bundle_extract"
	split_editor "soundcloud" "soundcloud"
	patch "soundcloud" "revanced"
	# Patch SoundCloud Arm64-v8a:
	get_patches_key "soundcloud"
	split_editor "soundcloud" "soundcloud-arm64-v8a" "exclude" "split_config.armeabi_v7a split_config.x86 split_config.x86_64"
	patch "soundcloud-arm64-v8a" "revanced"
}
7() {
	revanced_dl
	# Patch RAR:
	get_patches_key "rar"
	get_apk "com.rarlab.rar" "rar" "rar" "rarlab-published-by-win-rar-gmbh/rar/rar" "Bundle"
	patch "rar" "revanced"
	# Patch Lightroom:
	get_patches_key "lightroom"
	url="https://adobe-lightroom-mobile.en.uptodown.com/android/download/1033600808" #Use uptodown because apkmirror always ask pass Cloudflare on this app
	url="https://dw.uptodown.com/dwn/$(req "$url" - | $pup -p --charset utf-8 'button#detail-download-button attr{data-url}')"
	req "$url" "lightroom.apk"
	patch "lightroom" "revanced"
}
8() {
	revanced_dl
	get_apk "com.google.android.youtube" "youtube-lite" "youtube" "google-inc/youtube/youtube" "Bundle_extract"
	# Patch YouTube Lite Arm64-v8a:
	get_patches_key "youtube-revanced"
	split_editor "youtube-lite" "youtube-lite-arm64-v8a" "include" "split_config.arm64_v8a split_config.en split_config.xxxhdpi"
	patch "youtube-lite-arm64-v8a" "revanced"
}
9() {
	revanced_dl
	# Patch YouTube Music:
	echo "APP_NAME=youtube-music" >> $GITHUB_ENV
	echo "VARIANT=rv" >> $GITHUB_ENV
	# Arm64-v8a
	get_patches_key "youtube-music-revanced"
	get_apk "com.google.android.apps.youtube.music" "youtube-music-arm64-v8a" "youtube-music" "google-inc/youtube-music/youtube-music" "arm64-v8a"
	patch "youtube-music-arm64-v8a" "revanced"
}
10() {
	revanced_dl
	# Patch Strava:
	echo "APP_NAME=strava" >> $GITHUB_ENV
	echo "VARIANT=rv" >> $GITHUB_ENV
	get_patches_key "strava"
	get_apkpure "com.strava" "strava-arm64-v8a" "strava-run-hike-2025-health/com.strava" "Bundle"
	patch "strava-arm64-v8a" "strava-revanced"
}
11() {
	echo "APP_NAME=spotify" >> $GITHUB_ENV
	echo "VARIANT=rv" >> $GITHUB_ENV

	revanced_dl
	# Patch Spotjfy Arm64-v8a
	j="i"
	get_patches_key "Spotjfy-revanced"
	get_apkpure "com.spot"$j"fy.music" "spotjfy-arm64-v8a" "spot"$j"fy-music-and-podcasts-for-android/com.spot"$j"fy.music"
	patch "spotjfy-arm64-v8a" "spotify-revanced"
}
case "$1" in
    1)
        1
        ;;
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
    6)
        6
        ;;
    7)
        7
        ;;
    8)
        8
        ;;
    9)
        9
        ;;
	10)
		10
		;;
	11)
		11
		;;
esac
