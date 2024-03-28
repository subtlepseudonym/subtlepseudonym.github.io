---
date: 2024-03-28T08:06:19-04:00
title: "Microcorruption: Johannesburg"
series: "Microcorruption"
draft: false
_build:
  render: true
  list: false
---

<!-- summary -->
I sat down for this one at the end of the night hoping to take a look at it before bed and get a sense of the problem for tomorrow. Johannesburg turned out to be a fairly small modification of Montevideo and I was able to get a working attempt string in twenty minutes or so.
<!-- summary -->

{{< image src="dragonfly.jpg" alt="header image" >}}
A dragonfly, briefly alighting on a blade of grass. Taken by me.
{{< /image >}}

## First pass
The manual states that the hardware is the same, but the software's been updated to reject passwords that are too long. That's not ideal. We've been using the 17th character to redirect program execution.

Looks like they branched off an older revision of the code; `unlock_door` is back! We've got a few new lines in `login` that reject our password based upon a comparison operation. And that comparison value is hardcoded! Nice.

## Making edits
The hardcoded "password length" check is really just inspecting an expected value at 0x43fd. Beyond changing a few memory locations in our attempt string from Montevideo, the only new addition here is adding that expected value in the right place.
