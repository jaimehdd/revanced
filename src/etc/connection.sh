#!/bin/bash

# Check github connection stable or not:
check_connection() {
	local auth_header=()
	if [ -n "$GITHUB_TOKEN" ]; then
		auth_header=(-H "Authorization: Bearer $GITHUB_TOKEN")
	fi
	local http_code
	http_code=$(curl -s -o /dev/null -w "%{http_code}" --connect-timeout 5 --max-time 10 "${auth_header[@]}" "https://api.github.com/zen")
	if [ "$http_code" = "200" ]; then
		echo "internet_error=0" >> $GITHUB_OUTPUT
		echo -e "\e[32mGitHub connection OK (HTTP 200)\e[0m"
	else
		echo "internet_error=1" >> $GITHUB_OUTPUT
		echo -e "\e[31mGitHub connection failed or rate limited (HTTP $http_code)!\e[0m"
	fi
}
check_connection