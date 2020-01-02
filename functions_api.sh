#they don't specify an upper bound on the API and one could argue it's better to
#fetch everything in one go instead of having the overhead of multiple http requests
#since we're going to get everything anyway
#there is no api call to know the number of pages on the wiki though
limit=1000
getAllPages() {
	local wikiurl="$1"
	local apiurl="$wikiurl/api/v1/Articles/List"
	local offset=""

	local pages=""
	local nbitems=$limit
	while : ; do
		>&2 echo "querying "$apiurl with data $limit $offset""
		local res="$(curl --silent --location --url --get --data-urlencode "limit=$limit" --data-urlencode "$offset" "$apiurl")"
		if [[ -z "$res" ]]; then
			#todo stop retrying after X tries
			>&2 echo "?? empty res, waiting then retrying"
			sleep 30
			continue
		fi
		nbitems="$(echo "$res" | jq --raw-output '.items | length')"
		pages+="$(echo "$res" | jq --raw-output '.items[].title')"

		#>&2 echo "res: $res"
		>&2 echo "$(date) items: $nbitems"

		local offsetGiven="$(echo "$res" | jq --raw-output '.offset')"
		offset="offset=$offsetGiven"

		if [[ $nbitems -eq $limit ]]; then
			pages+=$'\n'
			sleep 5
			>&2 echo continuing
		else
			>&2 echo doneae
			break
		fi

	done

	echo "$pages"
}
