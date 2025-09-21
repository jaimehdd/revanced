#!/bin/bash
# Revanced build
source ./src/build/utils.sh
# Download requirements
revanced_dl(){
	dl_gh "revanced-patches revanced-cli" "revanced" "latest"
}

revanced_dl_beta(){
	dl_gh "revanced-cli" "revanced" "latest"
	dl_gh "revanced-patches" "revanced" "prerelease"
}

1() {
	revanced_dl
	# Patch YouTube:
	echo "REPO_NAME=yt-rv" >> $GITHUB_ENV
	get_patches_key "youtube-revanced"
	get_apk "com.google.android.youtube" "youtube" "youtube" "google-inc/youtube/youtube" "Bundle_extract"
	split_editor "youtube" "youtube"
	patch "youtube" "revanced"
	# Patch Youtube Arm64-v8a
	get_patches_key "youtube-revanced"
	split_editor "youtube" "youtube-arm64-v8a" "exclude" "split_config.armeabi_v7a split_config.x86 split_config.x86_64"
	patch "youtube-arm64-v8a" "revanced"
}
2() {
	revanced_dl
	# Patch Messenger:
	echo "REPO_NAME=messenger-revanced" >> $GITHUB_ENV
	# Arm64-v8a
	get_patches_key "messenger"
	get_apkpure "com.facebook.orca" "messenger-arm64-v8a" "facebook-messenger/com.facebook.orca"
	patch "messenger-arm64-v8a" "revanced"
}
3() {
	revanced_dl
	# Patch Google photos:
	echo "REPO_NAME=ggphotos" >> $GITHUB_ENV
	# Arm64-v8a
	get_patches_key "gg-photos"
	get_apk "com.google.android.apps.photos" "gg-photos-arm64-v8a" "photos" "google-inc/photos/google-photos" "arm64-v8a" "nodpi"
	patch "gg-photos-arm64-v8a" "revanced"
}
4() {
	echo "REPO_NAME=instagram-revanced" >> $GITHUB_ENV

	# official ReVanced
	revanced_dl
	# Patch Instagram:
	get_patches_key "instagram"
	# version="378.0.0.52.68"
	# get_apk "com.instagram.android" "instagram-arm64-v8a" "instagram-instagram" "instagram/instagram-instagram/instagram" "arm64-v8a" "nodpi"
	get_apkpure "com.instagram.android" "instagram-arm64-v8a" "instagram-android/com.instagram.android" "Bundle"
	patch "instagram-arm64-v8a" "revanced"

	# # ReVancedExperiments
	# dl_gh "ReVancedExperiments" "Aunali321" "latest"
	# dl_gh "revanced-cli" "revanced" "latest"
	# # Patch Instagram:
	# get_patches_key "instagram-revanced-experiments"
	# # version="362.0.0.33.241"
	# # get_apk "com.instagram.android" "instagram-arm64-v8a" "instagram-instagram" "instagram/instagram-instagram/instagram" "arm64-v8a" "nodpi"
	# get_apkpure "com.instagram.android" "instagram-arm64-v8a" "instagram-android/com.instagram.android" "Bundle"
	# patch "instagram-arm64-v8a" "revanced-experiments"
}
5() {
	revanced_dl
	# Patch Facebook:
	echo "REPO_NAME=fb-rv" >> $GITHUB_ENV
	# Arm64-v8a
	get_patches_key "facebook"
	get_apkpure "com.facebook.katana" "facebook-arm64-v8a" "facebook/com.facebook.katana"
	patch "facebook-arm64-v8a" "revanced"
}
6() {
	revanced_dl
	# Patch Tumblr:
	get_patches_key "tumblr"
	get_apk "com.tumblr" "tumblr" "tumblr" "tumblr-inc/tumblr/tumblr" "Bundle"
	patch "tumblr" "revanced"
	# Patch SoundCloud:
	get_patches_key "soundcloud"
	get_apk "com.soundcloud.android" "soundcloud" "soundcloud-soundcloud" "soundcloud/soundcloud-soundcloud/soundcloud-soundcloud" "Bundle"
	patch "soundcloud" "revanced"
}
7() {
	revanced_dl
	# Patch RAR:
	get_patches_key "rar"
	get_apk "com.rarlab.rar" "rar" "rar" "rarlab-published-by-win-rar-gmbh/rar/rar" "arm64-v8a"
	patch "rar" "revanced"
	# Patch Lightroom:
	get_patches_key "lightroom"
	version="9.2.0"
	get_apk "com.adobe.lrmobile" "lightroom" "lightroom" "adobe/lightroom/lightroom"
	patch "lightroom" "revanced"
}
8() {
	revanced_dl
	get_apk "com.google.android.youtube" "youtube-lite" "youtube" "google-inc/youtube/youtube" "Bundle_extract"
	# Patch YouTube Lite Arm64-v8a:
	get_patches_key "youtube-revanced"
	split_editor "youtube-lite" "youtube-lite-arm64-v8a" "include" "split_config.arm64_v8a split_config.en split_config.xxxhdpi"
	patch "youtube-lite-arm64-v8a" "revanced"
	# Patch YouTube Lite Armeabi-v7a:
	get_patches_key "youtube-revanced"
	split_editor "youtube-lite" "youtube-lite-armeabi-v7a" "include" "split_config.armeabi_v7a split_config.en split_config.xxxhdpi"
	patch "youtube-lite-armeabi-v7a" "revanced"
}
9() {
	revanced_dl
	# Patch YouTube Music:
	echo "REPO_NAME=ytm-rv" >> $GITHUB_ENV
	# Arm64-v8a
	get_patches_key "youtube-music-revanced"
	get_apk "com.google.android.apps.youtube.music" "youtube-music-arm64-v8a" "youtube-music" "google-inc/youtube-music/youtube-music" "arm64-v8a"
	patch "youtube-music-arm64-v8a" "revanced"
}
10() {
	revanced_dl
	# Patch Strava:
	echo "REPO_NAME=strava-rv" >> $GITHUB_ENV
	get_patches_key "strava"
	get_apkpure "com.strava" "strava-arm64-v8a" "strava-run-hike-2025-health/com.strava" "Bundle"
	patch "strava-arm64-v8a" "revanced"
}
11() {
	echo "REPO_NAME=spotify-revanced" >> $GITHUB_ENV

	revanced_dl
	# revanced_dl_beta
	get_patches_key "Spotjfy-revanced"

	j="i"
	version="9.0.72.949"
	get_apkpure "com.spot"$j"fy.music" "spotjfy-arm64-v8a" "spot"$j"fy-music-and-podcasts-for-android/com.spot"$j"fy.music"
	patch "spotjfy-arm64-v8a" "revanced"
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