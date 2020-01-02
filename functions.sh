decodeURL() {
   printf "$(sed 's#^file://##;s/+/ /g;s/%\(..\)/\\x\1/g;' <<< "$@")\n";
}
