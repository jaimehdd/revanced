#!/bin/bash
# Morphe build
source ./src/build/utils.sh
# Download requirements

morphe_dl(){
	dl_gh "morphe-patches" "MorpheApp" "latest"
	dl_gh "morphe-cli" "MorpheApp" "prerelease"
}

youtube() {
	morphe_dl
	# Patch YouTube:
	APP_NAME="youtube-beta"
	VARIANT="morphe"
	echo "APP_NAME=$APP_NAME" >> $GITHUB_ENV
	echo "VARIANT=$VARIANT" >> $GITHUB_ENV
	get_patches_key "youtube-morphe"
	prefer_version="$youtube_experimental_support"
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
	APP_NAME="reddit-beta"
	VARIANT="morphe"
	echo "APP_NAME=$APP_NAME" >> $GITHUB_ENV
	echo "VARIANT=$VARIANT" >> $GITHUB_ENV
	get_patches_key "reddit-morphe"
	prefer_version="$reddit_experimental_support"
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
	APP_NAME="youtube-music-beta"
	VARIANT="morphe"
	echo "APP_NAME=$APP_NAME" >> $GITHUB_ENV
	echo "VARIANT=$VARIANT" >> $GITHUB_ENV
	# Arm64-v8a
	get_patches_key "youtube-music-morphe"
	prefer_version="$youtube_music_experimental_support"
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
