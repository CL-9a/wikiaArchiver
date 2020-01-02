#!/bin/bash
## download all the pages of a wikia / fandom.com's wiki in xml format.
## TODO: script to update archive from the Special:RecentChanges page

archiveType="scrapper_xmlCurrent"
source ./init.sh
source ./functions_scrapper.sh

cd $folder

echo "fetching pages"
pages="$(getAllPages "$basepath")"
echo "got $(wc -l <<< "$pages") pages:"

for pagelink in $pages; do
	pagename="$(basename $pagelink)"
	cleanpagename="$(decodeURL $pagename)"

	echo "downloading xml for $cleanpagename ($pagename)"

	getCurrentXmlForPage $basepath $pagename > "./$cleanpagename.xml"

	sleep 5
done