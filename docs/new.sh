#!/bin/bash
now="$(date +%Y-%m-%d)"
downdir="$HOME/Documents/naolib/$now"
b=false
d=false
p=false

while [[ $# -gt 0 ]] ; do
	case "$1" in
	-b|--blog)
		b=true
		shift
		;;
	-d|--download)
		d=true
		shift
		;;
	-p|--page)
		p=true
		shift
		;;
	-*|--*)
		echo "Invalid option $1"
		echo "Usage: new.sh {-b,-d,-a} [URL]"
		echo "Options: "
		echo "    -b :: Create new blog entry"
		echo "    -d :: Download"
		echo "    -p :: Do not download the whole website"
		exit 0 ;
		;;
	*)
		POSITIONAL_ARGS+=("$1")
		shift
		;;
	esac
done

set -- "${POSITIONAL_ARGS[@]}"

url="$1"
filename=$(echo "$url" | tr -d 'http.\:\/\/' | tr -d '\/' | sed 's/\//%2F/g')

echo "URL: $url" 
echo "File: $filename" 

# Blog
if [ "$b" = true ] ; then
	mkdir -p ./blogs/
	tmp=./blogs/$(date)tmp.txt
	vim "$tmp"
	
	echo "<!DOCTYPE html><html><title>$now</title><link href=\"../styles.css\" rel=\"stylesheet\"/></head><body><div class=\"header\"><div class=\"wrapper\"><p class=\"heading\"><a href=../index.html>Naoto's Library</a></p></div></div><div class=\"sidepanel\"><p class=\"heading\">About</p><p>Hi, Naoto here.</p><p>This is a site where I will leave any pages I have found useful or interesting, for future reference.</p><p>Some links will inevitably be dead, but I will store a local copy of the site at the time of reading. This is to ensure that I can access them even twenty years into the future. I will also attempt to have each site uploaded to the <a href=\"archive.org\">Wayback Machine</a> where relevant and possible.</p><div id=\"contact\"><p><br>Contact:</p><ul><li>naoto@nao.jp.net</li><li><a href=\"finger://nao@plan.cat\">.plan (finger://)</a></li><li><a href=\"https://plan.cat/~nao\">.plan (https://)</a></li></ul></div></div><div class=\"content\"><div class=\"cell\"><p class=\"heading\"><a href=./blogs/\"$now-$filename.html\">$now</a> :: <a href=\"$url\">$url</a></p><p>$(cat "$tmp")</p></div></div></body></html>" > ./blogs/"$now-$filename".html
	rm "$tmp"
	title="<a href=\"./blogs/$now-$filename.html\">$now</a> :: <a href=\"$url\">$url</a>"
else
	title="$now :: <a href=\"$url\">$url</a>"
fi

# This is some absolutely disgusting solution, but it works so...
echo -e "<li>$title</li>\n$(cat links.txt)" > links.txt
echo "<head><link href=\"./styles.css\" rel=\"stylesheet\"><base target=\"_parent\"></head>" > ./links.html
cat ./links.txt >> ./links.html

# Download
if [ "$d" = true ] ; then
	mkdir -p "$downdir/$filename/"
	if [ "$p" = false ] ; then
		wget --recursive --no-clobber --page-requisites --convert-links "$url" -P "$downdir/$filename/"
	else
		wget --page-requisites --no-clobber "$url" -P "$downdir/$filename/"
	fi
	tar -cvjSf "$downdir/$now-$filename.tar.bz2" -C "$downdir/$filename" .
	rm -rf "$downdir/$filename"
fi
