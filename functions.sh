decodeURL() {
   printf "$(sed 's#^file://##;s/+/ /g;s/%\(..\)/\\x\1/g;' <<< "$@")\n";
}

getAllPages() {
	local wikiUrl="$1"

	local html="$(curl --silent --location "$wikiUrl/wiki/Special:AllPages")"
	local links="$(echo "$html" | pup 'table.mw-allpages-table-chunk a attr{href}')"

	echo "$links"
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
