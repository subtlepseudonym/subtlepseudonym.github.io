#!/bin/bash

starting_weight=990
weight_step=10

files="$(for line in $(rg --no-heading "weight:" content/projects/bird-photography/* | cut -d: -f1,3 | tr -d ' '); do
	printf \
		"%d %s %s\n" \
		"$(echo "$line" | cut -d: -f2)" \
		"$(echo "$line" | cut -d/ -f4,5 | cut -d: -f1)"
done | sort -n -k1 -r | cut -d' ' -f2)"

w=${starting_weight}
for f in ${files}; do
	sed -i --expression "s/weight: [0-9]\+/weight: ${w}/g" "content/projects/bird-photography/${f}"
	echo "${w} ${f}" | tr '/' ' ' | cut -d. -f1
	w=$((${w} - ${weight_step}))
done | sort -n -k1 | column -t
