---
title: "Microcorruption: Getting Started"
date: 2024-03-25T15:36:16-04:00
draft: false
_build:
  render: true
  list: false
---

[draft]

<!-- summary -->
NCC Group hosts an embedded security CTF game at [microcorruption.com](https://microcorruption.com). I'm not much of an expert in embedded anything, but the game is quite a bit of fun. I completed the first few levels a few days ago, so this is post-facto write-up, but I intend to write an article as I go for future levels.
<!-- summary -->

{{< image src="hacker.png" alt="header image" >}}
Created by [Mohamed Hassan](https://pixabay.com/users/mohamed_hassan-5229782/)
{{< /image >}}

I found that the fun with this game was in figuring out each problem. If you feel similarly, I highly suggest trying out these problems yourself before reading this article. I've stopped short of directly providing answers to each problem, but I do break down my solutions, so: spoilers ahead!

While working on these problems, I found these links helpful:
- [assembler / disassembler](https://microcorruption.com/assembler)
- [Lockitall manual](https://microcorruption.com/public/manual.pdf)
- [MSP430 user guide](https://www.ti.com/lit/ug/slau049f/slau049f.pdf)
- [MSP430 application binary interface](https://www.ti.com/lit/an/slaa534a/slaa534a.pdf)

## New Orleans
This level is pretty straight-forward. Dropping a breakpoint on `check_password` (0x44bc in memory) reveals 0x2400 in the live memory dump, containing the password. It's also worth noting that there's a comparison at 0x44c2 that directly references 0x2400 in a comparison operation. Punching in the password completes the level!

## Sydney
Sydney is fairly similar to New Orleans. There's a `check_password` function with a simple equivalence check. The difference is in that the check is done against hard-coded values rather than against a value in memory. Dropping a breakpoint at the top of `check_password` (0x448a) allows you to step through each comparison operation. Reading each operation's arguments from the disassembly window (and remembering that memory for the MSP430 is little-endian!) gives the correct password string and unlocks the lock.

## Hanoi
With this level, we no longer have direct access to the password equivalence test; that's taken care of in the HSM-1 device. We do still have an `unlock_door` function though, so that's probably our way in.

Looking near 0x453c, where `getsn` is called from within `login`, we'll see that 0x2400 is moved into r15. The `getsn` function then uses the value of r15 as a memory location for storing the password we enter. I still don't fully grok how `INT` works (although I suspect I could resolve this by reading section 3.9 of the user manual), but we can confirm this behavior by stepping once after entering a password, then reading 0x2400 or taking a look at the live memory dump.

Further on in `login`, at 0x455a, we can see that a comparison against 0x2410 dictates whether our input is rejected or the door is unlocked. That memory address isn't too far from where our password attempt is stored! Punching in a longer string confirms that we can write to 0x2410. From there, we can count out our input string length and ensure that the value stored in 0x2410 matches the expected flag value from the HSM-1 and we're in.

## Cusco
The Lockitall folks have moved the HSM-1 flag location, so we won't be able to write the flag directly. In Cusco, our password attempt is written to much a much higher address, 0x43ec (suprisingly close to program code).

Stepping through `test_password_valid`, the function doesn't seem to reference a value we can write to, outside of sending our password to the HSM-1. I actually spent a fair amount of time going through `test_password_valid` with a fine-toothed comb to really confirm that I couldn't trick the HSM-1 into thinking I'd sent the correct password. It wasn't until I stepped through the rest of `login` that I realized I'd been focusing in the wrong place.

After the value returned by `test_password_valid` is checked (tst r15 @ 0x4524), the program prints the rejection message and _increments the stack pointer by 0x10_. This sets the stack pointer to 0x43fc, beyond the memory location where our attempt is written! In addition, the first operation called once the stack is in this new, writeable position is `RET`. Referencing the Lockitall manual, we can see that `RET` is essentially an alias for `MOV @sp+, pc`, moving the value referenced by the stack pointer into the program register and incrementing the stack pointer. Armed with this information, we can construct a password attempt that places the memory location of a function we want to call, `unlock_door` perhaps, into 0x43fc. Once done, when the program returns from `login`, it will call `unlock_door` rather than correctly returning up the call stack. We're in!

It's worth noting two things here: this solution only works because `getsn` sets a very generous length limit for passwords, 48 characters (set on 0x4514) and this solution is quite similar to Hanoi in that there's an important memory location 16 characters beyond where our password is written into memory.

## Reykjavik
This level was interesting in that it was the first problem that required the use of the [disassembler](https://microcorruption.com/assembler), but I found it less exciting than the others. Finding the solution didn't require modeling program execution in my head and discovering a clever vulnerability so much as finding when to read the password out of memory. That said, that's probably the point; not all solutions are clever and hard-coding passwords is still a bad idea even when it's obfuscated.

While the solution process wasn't my favorite, the program itself is pretty neat. The encryption function (`enc` @ 0x4486) steps through a three-part process that turns the values at 0x2400 into usable program code. Once done, 0x2400 is called, input is accepted, and the input is compared to a hard-coded value. Passing in that value passes the challenge and opens the lock.

## Whitehorse
This level was a lot of fun! Essentially, it's not all that different from Cusco, but I felt more like a hacker while solving this one.

Since Cusco, the HSM-1 now takes over responsibility for unlocking the door and we no longer have a convenient `unlock_door` function. Despite that, the same vulnerability is present in the code! Our stack pointer still ends up 0x10 beyond where our password attempt is stored (and `getsn` still provides a generous character limit). The issue here is that we've got to come up with a way to unlock the door ourselves.

In writing this article, I've realized that I could have looked back at Cusco to find the correct operations, but at the time, I took the long way round. I found the 0x7f interrupt documented in the [lockitall manual](https://microcorruption.com/public/manual.pdf) and substituted that for the 0x7e value used in `conditional_unlock_door`. My solution was a bit over-engineered, encoding a program that would push 0x7f, call `INT`, increment the stack pointer, and return to 0x451c (printing "Access granted." and proceeding from there). As it turns out, only the first two steps were required.
