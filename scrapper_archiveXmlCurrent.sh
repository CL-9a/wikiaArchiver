#!/bin/bash

## download all the pages of a wikia / fandom.com's wiki in xml format.
## TODO: script to update archive from the Special:RecentChanges page

wikiname="$1"
wikilanguage="$2"
wikilink="https://$wikiname.fandom.com"

if [[ ! -z "$wikilanguage" ]]; then
	wikilink="$wikilink/$wikilanguage"
fi

folder="./xmlwikiscurrent/$wikiname"

source ./functions.sh
source ./functions_scrapper.sh

mkdir --parents --verbose $folder
cd $folder

echo "fetching pages"
pages="$(getAllPages "$wikilink")"
echo "got $(wc -l <<< "$pages") pages:"

for pagelink in $pages; do
	pagename="$(basename $pagelink)"
	cleanpagename="$(decodeURL $pagename)"

	echo "downloading xml for $cleanpagename ($pagename)"

	getCurrentXmlForPage $wikilink $pagename > "./$cleanpagename.xml"

	sleep 5
done