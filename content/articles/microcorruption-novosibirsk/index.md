---
date: 2026-06-03T16:50:55-04:00
title: "Microcorruption: Novosibirsk"
series: "Microcorruption"
draft: false
---

<!-- summary -->
Novosibirsk is a pretty straight-forward extension of the tools we figured out in Addis Ababa. Funny enough, the vulnerability is actually worse on this lock.
<!-- summary -->

{{< image src="canada-goose.jpeg" alt="header image" >}}
A very serious goose
{{< /image >}}

## First pass
The intro message gives us two major updates: we're now using the HSM-2 and we have access to `printf`. It looks like the latter still allows writing to memory, but the password validity check is now done on the HSM rather than where we can get at it directly.

## Once more, with feeling
The same vulnerability as Addis Ababa exists here, but with the added benefit that the input length restriction has been removed. As a result, we can use an input prepended with a memory location to write the input's length as a value to the embedded location in memory (a second location needs to be included to handle the `%n` verb behavior). So, sending `c844 ... 256e 256e` with a total length of 7f stores `44c8` in memory, then writes 7f to the location, updating the control code sent to the interrupt function and unlocking the deadbolt.
