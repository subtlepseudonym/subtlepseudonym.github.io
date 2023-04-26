#!/bin/bash

settings="$(
	exiftool -args -FNumber -ExposureTime -FocalLength -ISO "$1" \
	| sed '
		s#-FNumber=#f/#g;
		s/-ExposureTime=//g;
		s/-FocalLength=//g;
		s/-ISO=/iso/g' \
	| paste -s -d "," \
	| sed 's/,/, /g'
)"

width="$(exiftool -s3 -ImageWidth "$1")"
height="$(exiftool -s3 -Imageheight "$1")"

target_path="$(basename "$1" | gawk 'gsub(/_/, "-", $0) match($0, /(.*)-([0-9]{8}-[0-9]+\..*)/, a) { print a[1] "/" a[2] }')"
bird_dir="$(dirname ${target_path})"
image_filename="$(basename ${target_path})"
thumb_filename="$(gawk 'match($0, /(.*)\.(.*)$/, a) { print a[1] "-thumb." a[2] }' <<< ${image_filename})"
page_filename="$(gawk 'match($0, /(.*)\.(.*)$/, a) { print a[1] ".md" }' <<< ${image_filename})"

target_dir="content/projects/bird-photography/${bird_dir}"
mkdir -p "${target_dir}"
cp "$1" "${target_dir}/${image_filename}"
ffmpeg -i "${target_dir}/${image_filename}" -vf scale=840:-1 "${target_dir}/${thumb_filename}" 2> /dev/null

printf "weight: "
read -r weight

printf "description: "
read -r description

echo "---
weight: ${weight}
image: \"${bird_dir}/${image_filename}\"
width: ${width}
height: ${height}
description: \"${description}<br/>${settings}\"
---" >> "${target_dir}/${page_filename}"
