#!/bin/bash

for line in $(rg --no-heading "weight:" content/projects/bird-photography/* | cut -d: -f1,3 | tr -d ' '); do
	printf \
		"%d %s %s\n" \
		"$(echo "$line" | cut -d: -f2)" \
		"$(echo "$line" | cut -d/ -f4)" \
		"$(echo "$line" | cut -d/ -f5 | cut -d. -f1)"
done | sort -n -k1 | column -t
