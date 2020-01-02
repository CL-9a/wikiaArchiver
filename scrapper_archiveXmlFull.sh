#!/bin/bash
## download all the pages of a wikia / fandom.com's wiki in xml format.
## TODO: script to update archive from the Special:RecentChanges page
## note that wikia says that individual exports can't be more than 2Mb
## https://community.fandom.com/wiki/Help:Exporting_pages

archiveType="scrapper_xmlFull"
source ./init.sh
source ./functions_scrapper.sh

cd $folder

echo "fetching pages"
pages="$(getAllPages "$basepath")"
echo "got $(wc -l <<< "$pages") pages:"

for pagelink in $pages; do
	pagename="$(basename $pagelink)"
	cleanpagename="$(decodeURL $pagename)"

	xmlUrl="$basepath/wiki/Special:Export?action=submit"

	echo "downloading xml for $cleanpagename ($pagename)"

	curl --silent --location "$xmlUrl" --data "pages=$pagename" \
		| perl -MHTML::Entities -pe 'decode_entities($_);' 		\
		> "$cleanpagename.xml"

	sleep 5
done