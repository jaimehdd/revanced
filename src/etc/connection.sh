#!/bin/bash

# Check github connection stable or not:
check_connection() {
	url=$(curl -sL "https://api.github.com/repos/revanced/revanced-patches/releases/tags/v4.17.0" | jq -r '.assets[] | select(.name == "patches.json") | .browser_download_url')
	if [ -n "$url" ] && [ "$url" != "null" ]; then
		curl -sL -o "patches.json" "$url"
	fi
	
	if [ -f patches.json ]; then
		[ -n "$GITHUB_OUTPUT" ] && echo "internet_error=0" >> "$GITHUB_OUTPUT"
		echo -e "\e[32mGithub connection OK\e[0m"
		rm -f "patches.json"
	else
		[ -n "$GITHUB_OUTPUT" ] && echo "internet_error=1" >> "$GITHUB_OUTPUT"
		echo -e "\e[31mGithub connection not stable!\e[0m"
	fi
}
check_connection
