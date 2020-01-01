decodeURL() {
   printf "$(sed 's#^file://##;s/+/ /g;s/%\(..\)/\\x\1/g;' <<< "$@")\n";
}

getAllPages() {
	local wikiUrl="$1"
	local relPageUrl="/wiki/Special:AllPages"

	_getAllPagesChunks "$wikiUrl" "$relPageUrl"
}

_getAllPagesChunks () {
	local wikiUrl="$1"
	local relPageUrl="$2"
	local toQuery="${1}${2}"

	#>&2 echo "_getAllPagesChunks $toQuery"

	local html="$(curl --silent --location -H 'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:72.0) Gecko/20100101 Firefox/72.0' "$toQuery")"

	local htmlAllPagesList="$(echo "$html" | pup 'table.allpageslist a attr{href}' | uniq)"
	if [[ -z "$htmlAllPagesList" ]]; then
		#>&2 echo "no allpageslist - got a page list chunk:"

		local chunk="$(echo "$html" | pup 'table.mw-allpages-table-chunk a attr{href}')"
		#>&2 echo "$chunk"
		echo "$chunk"
	else
		#>&2 echo "has allpageslist - got a list of page lists: $htmlAllPagesList"

		local allPagesChunks=""
		for url in $htmlAllPagesList; do
			sleep 1

			#>&2 echo "recursively getting allPages from $wikiUrl$url"
			local lowerPageChunks="$(_getAllPagesChunks "$wikiUrl$url")"

			#>&2 echo "adding to main list"
			allPagesChunks+="\n$lowerPageChunks"
		done
		#>&2 echo "all done, sending to parent"
		echo "$allPagesChunks"
	fi
}

getPageHistoryLink () {
	local wikiUrl="$1"
	local pageUrl="$2"

	local historyHtml="$(curl --silent --location "${wikiUrl}${pageUrl}?action=history")"
	local historyLinks="$(echo "$historyHtml" | pup 'ul#pagehistory > li > a attr{href}')"

	echo "$historyLinks"
}

getPageHistoryData() {
	local wikiUrl="$1"
	local pageUrl="$2"

	local historyHtml="$(curl --silent --location "${wikiUrl}${pageUrl}?action=history")"

	echo $historyHtml | pup 'ul#pagehistory > li json{}' | jq '
	[.[] |
		[ .children[] |(
			  (select(.tag=="a").href | sub(".*oldid="; ""))
			, (select(.tag=="a").text)
			, (select(has("class") and .class=="history-user").children[] | select(.class | contains("mw-userlink")).text )
			, (select(has("class") and .class=="history-size").text)
			, (select(has("class") and .class=="comment").text)
		)]
	] | reverse'
}

getPageHistoryOldIds () {
	local wikiUrl="$1"
	local pageUrl="$2"

	local historyLinks="$(getPageHistoryLink $wikiUrl $pageUrl)"
	local oldids="$(echo "$historyLinks" | sed 's/.*oldid=//')"

	echo "$oldids"
}

getPageWikitextSource () {
	local wikiUrl="$1"
	local pageUrl="$2"
	local oldId="$3"

	local url="${wikiUrl}${pageUrl}?action=edit"
	if [ ! -z "$oldId" ]; then
		url="${url}&oldid=$oldId"
	fi

	local editHtml="$(curl --silent --location "$url")"
	local source="$(echo "$editHtml" | pup 'textarea#wpTextbox1 text{}' | recode html)" # | recode html..ascii)"

	echo "$source"
}
