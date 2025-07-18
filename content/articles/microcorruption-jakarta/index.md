---
date: 2024-03-28T13:37:58-04:00
title: "Microcorruption: Jakarta"
series: "Microcorruption"
draft: false
_build:
  render: true
  list: false
---

<!-- summary -->
Multipart corruption! Like paying a lobbyist to pay a senator! This is our first example of corrupting one value, thereby changing the behavior of the program and allowing further corruption.
<!-- summary -->

{{< image src="piping-plover.jpeg" alt="header image" >}}
A Piping Plover standing among rocks on the beach. Taken by me.
{{< /image >}}

## First pass
Compared to Santa Cruz, our username and password are now stored adjacently to one another, so we can't overwrite the length limit information directly. The new combined limit for username and password length is nominally 32 characters. That said, the calls to `getsn` provide buffers of size 255 and (possibly) 511 for username and password, respectively. Determining the total length of our input is done by stepping through our input, then subtracting the starting memory address from the final one (where the null character is found). Looks like they're only using one byte to hold the counter though, so we may be able to overflow it.

## Password protection
Password inputs appear to be truncated by 31 minus the length of the username. It looks as though we can get around this though by providing a maximum length username: 32 characters. In determining the password buffer length, 31 minus 32 overflows and allows us the maximum length of 511 (0x1ff).

Now that we've got a bigger character buffer, we can use it to overflow the input length counter. After typing up some huge strings (32 and 224 characters worth) and embedding the memory location of our pal `unlock_door` into the latter, both the password buffer limit and input length counters overflow, letting us slip past the length checks and unlock the door.
