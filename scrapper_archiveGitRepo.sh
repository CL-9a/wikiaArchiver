#!/bin/bash
## export an entire wikia / fandom.com's wiki into a git repository.
## TODO: script to update repo from the Special:RecentChanges page
## Don't use: getPageWikitextSource doesn't handle wikia's wysiwyg editor
## TODO: script to convert from archiveXmlFull.sh's dump to git repo

archiveType="scrapper_gitRepo"
source ./init.sh
source ./functions_scrapper.sh

cd $folder
touch "./storedIds.txt"
git init .

echo "fetching pages"
pages="$(getAllPages "$basepath")"
echo "got $(wc -l <<< "$pages") pages:"

for pagelink in $pages; do
	pagename="$(basename $pagelink)"
	pagename="$(decodeURL $pagename)"

	echo "getting old versions for page $pagelink"
	jsondata="$(getPageHistoryData $basepath $pagelink)"
	nbelems="$(echo $jsondata | jq '. | length')"
	echo "old ids fetched: $nbelems"
	echo ""

	for i in $(seq 0 $(expr $nbelems - 1)); do
		#use an index to run through the json array via jq
		data="$(echo "$jsondata" | jq -r ".[$i][]")"

		#echo data: $(echo "$data" | tr '\n' '@')
		#for some reason I can't use newline as a separator for read eventho they're here for tr
		IFS='@' read id date author size comment <<< "$(echo "$data" | tr '\n' '@')"
		if grep -Fxq "$id" "storedIds.txt"; then
			echo "skipping stored modification id $id"
			#this is going to be trouble is somehow we end up with an unknown id that is below a known id
		else
			echo "$id" >> "storedIds.txt"

			if [[ ! -z "$comment" ]]; then
				comment="$(echo "$comment" | recode html)"
			fi

			echo "getting source for page $pagename with id $id"
			#echo "id:$id date:$date author:$author size:$size comment:$comment"

			getPageWikitextSource "$basepath" "$pagelink" "$id" > "${pagename}.md"

			git add "${pagename}.md"
			git -c user.name="$author" -c user.email="anon@ymous.com" commit	\
				--allow-empty --allow-empty-message --untracked-files=no		\
				--message="(id:${id}) .. $size .. $comment"						\
				--date="$date UTC"
				
				

			#echo ""
			sleep 5
		fi
	done
done
