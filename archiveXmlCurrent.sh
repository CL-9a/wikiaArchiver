#!/bin/bash
## download all the pages of a wikia / fandom.com's wiki in xml format.
## TODO: script to update archive from the Special:RecentChanges page
## https://community.fandom.com/api/v1/

archiveType="xmlCurrent"
source ./init.sh
source ./functions_api.sh

echo "fetching pages"
pages="$(getAllPages "$basepath")"
echo "got $(wc -l <<< "$pages") pages:"

IFS=$'\n'; for pagetitle in $pages; do
	if [[ -z $pagetitle ]]; then
		echo skipping empty page
	else
		urlEncoded="$(encodeURL $pagetitle)"
		filename="$urlEncoded.xml"

		echo "downloading xml for $pagetitle into ./$folder/$filename"

		getCurrentXmlForPage $basepath $pagetitle > "./$folder/$filename"
		#todo: &rsquo;
		sleep 3
	fi
done
