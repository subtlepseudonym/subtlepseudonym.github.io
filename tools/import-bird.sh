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

filename="$(basename "$1" | gawk 'gsub(/_/, "-", $0) match($0, /(.*)-([0-9]{8}-[0-9]+\..*)/, a) { print a[1] "/" a[2] }')"

target_dir="content/projects/bird-photography/$(dirname ${filename})"
mkdir -p "${target_dir}"
cp "$1" "${target_dir}/$(basename ${filename})"

thumb_filename="$(gawk 'match($0, /(.*)\.(.*)$/, a) { print a[1] "-thumb." a[2] }' <<< $(basename ${filename}))"
ffmpeg -i "${target_dir}/$(basename ${filename})" -vf scale=840:-1 "${target_dir}/${thumb_filename}"

printf "##### INPUT #####\nweight: "
read -r weight

printf "description: "
read -r description

echo "---
weight: ${weight}
image: \"${filename}\"
width: ${width}
height: ${height}
description: \"${description}<br/>${settings}\"
---" >> "${target_dir}/index.md"
