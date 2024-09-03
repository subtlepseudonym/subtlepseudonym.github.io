---
date: 2024-03-28T08:40:13-04:00
title: "Microcorruption: Santa Cruz"
series: "Microcorruption"
draft: false
---

<!-- summary -->
Santa Cruz introduces the username input! We've got multiple locations to write to, new values to corrupt, and our old friend `unlock_door` plays a central role.
<!-- summary -->

{{< image src="turnstone.jpeg" alt="header image" >}}
A Ruddy Turnstone running along the beach. Taken by me.
{{< /image >}}

## First pass
Multiple inputs! We now need to enter a username and a password. I suspect that won't constitute a huge difference for now, but that's definitely going to get interesting as we keep going. Another thing that's changed since Johannesburg is our password location. We're stored at an odd-numbered offset. We've still got `unlock_door` back and there's still a value after our stored password that looks suspiciously like a call stack value.

## Stepping through login
The `login` function has a few new behaviors, so I spent some time stepping through those and found something interesting. The max password length is now stored in memory. Specifically, it's stored between where our username and password are. Let's see if we can put our own value in there.

Overflowing the username and storing 0xff in place of 0x10 works as expected. And `strcpy` then copies a nice long password attempt (loads of 1's followed by the address of `unlock_door`). Stepping through the rest of login, we eventually fail due to a final check for a null character at the expected end of the password. We, of course, don't have one there because we want to write beyond it while still getting `strcpy` to move our attempt into the target portion of memory. Maybe we need to _really_ overflow username?

## My (user)name is John Jacob Jingleheimer Schmidt
There don't appear to be any checks on username length. Overflowing well past the minimum and maximum length values, over the whole password section, and into our target stack pointer value works! We can follow that up with a password of length 17 (and thereby a null character at character position 18).

The length checks pass, our target null character is read, and we jump over the short-circuit at the end of `login` before successfully returning into `unlock_door`. We're in!
