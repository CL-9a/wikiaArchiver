decodeURL() {
   printf "$(sed 's#^file://##;s/+/ /g;s/%\(..\)/\\x\1/g;' <<< "$@")\n";
}

encodeURL() {
	#todo more proper way to remove newline (? itWorksTM)
	echo "$@" | jq -s -R -r @uri| sed 's/%0A$//' 
}