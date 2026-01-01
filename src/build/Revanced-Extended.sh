#!/bin/bash
# Revanced Extended build
source src/build/utils.sh

# Download requirements
use_beta="${use_beta:-true}"

revanced_dl_beta(){
	dl_gh "revanced-patches revanced-cli" "inotia00" "prerelease"
}

revanced_dl(){
	if [ "$use_beta" = true ]; then
		revanced_dl_beta
	else
		dl_gh "revanced-patches revanced-cli" "inotia00" "latest"
	fi
}

1() {
	revanced_dl
	# Patch YouTube:
	echo "APP_NAME=youtube" >> $GITHUB_ENV
	echo "VARIANT=rve" >> $GITHUB_ENV
	get_patches_key "youtube-revanced-extended"
	get_apk "com.google.android.youtube" "youtube" "youtube" "google-inc/youtube/youtube" "Bundle_extract"
	# Patch Youtube Arm64-v8a
	split_editor "youtube" "youtube-arm64-v8a" "exclude" "split_config.armeabi_v7a split_config.x86 split_config.x86_64"
	patch "youtube-arm64-v8a" "revanced-extended" "inotia"
}
4() {
	revanced_dl
	# Patch YouTube:
	echo "APP_NAME=youtube" >> $GITHUB_ENV
	echo "VARIANT=rve" >> $GITHUB_ENV
	get_patches_key "youtube-revanced-extended"
	get_apk "com.google.android.youtube" "youtube" "youtube" "google-inc/youtube/youtube"
	patch "youtube" "revanced-extended" "inotia"
	# Split architecture Youtube:
	get_patches_key "youtube-revanced-extended"
	for i in {0..0}; do
		split_arch "youtube" "revanced-extended" "$(gen_rip_libs ${libs[i]})"
	done
}
2() {
	revanced_dl
	# Patch YouTube Music Extended:
	echo "APP_NAME=youtube-music" >> $GITHUB_ENV
	echo "VARIANT=rve" >> $GITHUB_ENV
	# Arm64-v8a
	get_patches_key "youtube-music-revanced-extended"
	get_apk "com.google.android.apps.youtube.music" "youtube-music-arm64-v8a" "youtube-music" "google-inc/youtube-music/youtube-music" "arm64-v8a"
	patch "youtube-music-arm64-v8a" "revanced-extended" "inotia"
}
3() {
	dl_gh "revanced-patches-arsclib revanced-integrations revanced-cli-arsclib" "inotia00" "latest"
	# Patch Reddit:
	echo "APP_NAME=reddit" >> $GITHUB_ENV
	echo "VARIANT=rve" >> $GITHUB_ENV
	get_patches_key "reddit-rve-arsclib"
	get_apk "com.reddit.frontpage" "reddit" "reddit" "redditinc/reddit/reddit" "Bundle_extract"
	# Patch Arm64-v8a:
	split_editor "reddit" "reddit-arm64-v8a" "exclude" "split_config.armeabi_v7a split_config.x86_64 split_config.mdpi split_config.ldpi split_config.hdpi split_config.xxhdpi split_config.tvdpi"
	patch "reddit-arm64-v8a" "reddit-rve"
	mv ./release/reddit-arm64-v8a-reddit-rve.apk/base.apk ./reddit-arm64-v8a-reddit-rve.apk
	rm -f -d ./release/reddit-arm64-v8a-reddit-rve.apk
	mv ./reddit-arm64-v8a-reddit-rve.apk ./release/reddit-arm64-v8a-reddit-rve-arsclib.apk
}
case "$1" in
    1)
        1
        ;;
    4)
        4
        ;;
    2)
        2
        ;;
    3)
        3
        ;;
esac