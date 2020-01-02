#!/bin/bash

## download all the pages of a wikia / fandom.com's wiki in xml format.
## TODO: script to update archive from the Special:RecentChanges page
## https://community.fandom.com/api/v1/

wikiname="$1"
wikilanguage="$2"
wikilink="https://$wikiname.fandom.com"

if [[ ! -z "$wikilanguage" ]]; then
	wikilink="$wikilink/$wikilanguage"
fi

#todo handle language
folder="./xmlwikiscurrent/$wikiname"

source ./functions.sh
source ./functions_api.sh

mkdir --parents --verbose $folder
cd $folder

echo "fetching pages"
pages="$(getAllPages "$wikilink")"
echo "got $(wc -l <<< "$pages") pages:"

IFS=$'\n'; for pagetitle in $pages; do
	if [[ -z $pagetitle ]]; then
		echo skipping empty page
	else
		urlEncoded="$(encodeURL $pagetitle)"
		filename="$urlEncoded.xml"

		echo "downloading xml for $pagetitle into $filename"

		getCurrentXmlForPage $wikilink $pagetitle > "./$filename"
		#todo: &rsquo;
		sleep 3
	fi
done
