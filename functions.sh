decodeURL() {
   printf "$(sed 's#^file://##;s/+/ /g;s/%\(..\)/\\x\1/g;' <<< "$@")\n";
}

encodeURL() {
	#todo more proper way to remove newline (? itWorksTM)
	echo "$@" | jq -s -R -r @uri| sed 's/%0A$//' 
}

getCurrentXmlForPage() {
	local wikilink="$1"
	local pageName="$2"

	local urlEncoded="$(encodeURL $pagetitle)"
	local xmlUrl="$wikilink/wiki/Special:Export/$urlEncoded"

	curl --silent --location "$xmlUrl" | perl -MHTML::Entities -pe 'decode_entities($_);'
	#todo: &rsquo;
}
