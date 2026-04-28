#!/bin/bash
# Morphe build
source ./src/build/utils.sh
# Download requirements
use_beta="${use_beta:-false}"

morphe_dl_beta(){
	dl_gh "morphe-patches" "MorpheApp" "prerelease"
	dl_gh "morphe-cli" "MorpheApp" "latest"
}

morphe_dl(){
	if [ "$use_beta" = true ]; then
		morphe_dl_beta
	else
		dl_gh "morphe-patches morphe-cli" "MorpheApp" "latest"
	fi
}
youtube() {
	morphe_dl
	# Patch YouTube:
	APP_NAME="youtube"
	VARIANT="morphe"
	echo "APP_NAME=$APP_NAME" >> $GITHUB_ENV
	echo "VARIANT=$VARIANT" >> $GITHUB_ENV
	get_patches_key "youtube-morphe"
	get_apk "com.google.android.youtube" "youtube" "youtube" "google-inc/youtube/youtube"
	release_exists && return 0
	patch "youtube" "morphe" "morphe"

	# Remove unused architectures
	for i in {0..0}; do
		split_arch "youtube" "morphe"
	done
}
reddit() {
	morphe_dl
	APP_NAME="reddit"
	VARIANT="morphe"
	echo "APP_NAME=$APP_NAME" >> $GITHUB_ENV
	echo "VARIANT=$VARIANT" >> $GITHUB_ENV
	get_patches_key "reddit-morphe"
	prefer_version="2026.16.0"
	get_apk "com.reddit.frontpage" "reddit" "reddit" "redditinc/reddit/reddit" "Bundle_extract"
	release_exists && return 0
	# split_editor "reddit" "reddit"
	# patch "reddit" "morphe" "morphe"
	# Patch Arm64-v8a:
	split_editor "reddit" "reddit-arm64-v8a" "exclude" "split_config.armeabi_v7a split_config.x86_64 split_config.mdpi split_config.ldpi split_config.hdpi split_config.xhdpi split_config.xxhdpi split_config.tvdpi"
	get_patches_key "reddit-morphe"
	patch "reddit-arm64-v8a" "morphe" "morphe"
}
youtube-music() {
	morphe_dl
	# Patch YouTube Music:
	APP_NAME="youtube-music"
	VARIANT="morphe"
	echo "APP_NAME=$APP_NAME" >> $GITHUB_ENV
	echo "VARIANT=$VARIANT" >> $GITHUB_ENV
	# Arm64-v8a
	get_patches_key "youtube-music-morphe"
	get_apk "com.google.android.apps.youtube.music" "youtube-music-arm64-v8a" "youtube-music" "google-inc/youtube-music/youtube-music" "arm64-v8a"
	release_exists && return 0
	patch "youtube-music-arm64-v8a" "morphe" "morphe"
}
case "$1" in
    youtube)
        youtube
        ;;
    reddit)
        reddit
        ;;
    youtube-music)
        youtube-music
        ;;
esac
