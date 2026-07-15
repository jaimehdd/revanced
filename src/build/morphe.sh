#!/bin/bash
# Morphe build
source ./src/build/utils.sh

use_beta="${use_beta:-false}"

morphe_dl(){
	if [ "$use_beta" = true ]; then
		dl_gh "morphe-patches" "MorpheApp" "prerelease"
		dl_gh "morphe-desktop" "MorpheApp" "prerelease"
	else
		dl_gh "morphe-patches" "MorpheApp" "latest"
		dl_gh "morphe-desktop" "MorpheApp" "prerelease"
	fi
}

youtube() {
	APP_NAME="youtube"
	VARIANT="morphe"
	echo "APP_NAME=$APP_NAME" >> $GITHUB_ENV
	echo "VARIANT=$VARIANT" >> $GITHUB_ENV

	morphe_dl
	get_patches_key "youtube-morphe"
	prefer_version="$youtube_experimental_support"
	get_apk "com.google.android.youtube" "youtube" "apk"

	release_exists && return 0

	patch "youtube" "morphe" "morphe"

	# Remove unused architectures
	for i in {0..0}; do
		split_arch "youtube" "morphe"
	done
}

reddit() {
	APP_NAME="reddit"
	VARIANT="morphe"
	echo "APP_NAME=$APP_NAME" >> $GITHUB_ENV
	echo "VARIANT=$VARIANT" >> $GITHUB_ENV

	morphe_dl
	get_patches_key "reddit-morphe"
	prefer_version="${reddit_experimental_support:-2026.16.0}"
	get_apk "com.reddit.frontpage" "reddit" "bundle_extract"

	release_exists && return 0

	# Patch Arm64-v8a:
	split_editor "reddit" "reddit-arm64-v8a" "exclude" "split_config.armeabi_v7a split_config.x86_64 split_config.mdpi split_config.ldpi split_config.hdpi split_config.xhdpi split_config.xxhdpi split_config.tvdpi"
	get_patches_key "reddit-morphe"
	patch "reddit-arm64-v8a" "morphe" "morphe"
}

youtube-music() {
	APP_NAME="youtube-music"
	VARIANT="morphe"
	echo "APP_NAME=$APP_NAME" >> $GITHUB_ENV
	echo "VARIANT=$VARIANT" >> $GITHUB_ENV

	morphe_dl
	get_patches_key "youtube-music-morphe"
	prefer_version="$youtube_music_experimental_support"
	get_apk "com.google.android.apps.youtube.music" "youtube-music-arm64-v8a" "apk" "arm64-v8a"

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
