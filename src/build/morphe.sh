#!/bin/bash
# Morphe build
source ./src/build/utils.sh
# Download requirements
morphe_dl(){
	dl_gh "morphe-patches" "MorpheApp" "latest"
	dl_gh "morphe-cli" "MorpheApp" "latest"
}
1() {
	morphe_dl
	# Patch YouTube:
	echo "APP_NAME=youtube" >> $GITHUB_ENV
	echo "VARIANT=morphe" >> $GITHUB_ENV
	get_patches_key "youtube-morphe"
	get_apk "com.google.android.youtube" "youtube" "youtube" "google-inc/youtube/youtube"
	# Remove unused architectures
	for i in {0..0}; do
		apk_editor "youtube" "${archs[i]}" ${libs[i]}
	done
	# Patch Youtube Arm64-v8a
	patch "youtube-arm64-v8a" "morphe" "morphe"
}
2() {
	morphe_dl
	# Patch YouTube Lite Arm64-v8a:
	#get_patches_key "youtube-morphe"
	#get_apk "com.google.android.youtube" "youtube-lite" "youtube" "google-inc/youtube/youtube" "Bundle_extract"
	#split_editor "youtube-lite" "youtube-lite-arm64-v8a" "include" "split_config.arm64_v8a split_config.en split_config.xxxhdpi"
	#patch "youtube-lite-arm64-v8a" "morphe" "morphe"
	# Patch YouTube Lite Armeabi-v7a:
	#get_patches_key "youtube-morphe"
	#split_editor "youtube-lite" "youtube-lite-armeabi-v7a" "include" "split_config.armeabi_v7a split_config.en split_config.xxxhdpi"
	#patch "youtube-lite-armeabi-v7a" "morphe" "morphe"
}
3() {
	morphe_dl
	# Patch YouTube Music:
	echo "APP_NAME=youtube-music" >> $GITHUB_ENV
	echo "VARIANT=morphe" >> $GITHUB_ENV
	# Arm64-v8a
	get_patches_key "youtube-music-morphe"
	get_apk "com.google.android.apps.youtube.music" "youtube-music-arm64-v8a" "youtube-music" "google-inc/youtube-music/youtube-music" "arm64-v8a"
	patch "youtube-music-arm64-v8a" "morphe" "morphe"
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
esac