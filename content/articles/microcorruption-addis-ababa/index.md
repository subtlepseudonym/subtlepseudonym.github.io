---
date: 2026-06-03T10:51:24-04:00
title: "Microcorruption Addis Ababa"
series: "Microcorruption"
draft: false
_build:
  render: true
  list: false
---

<!-- summary -->
It's been a while since I've played around with microcorruption, so I'm hoping that ramping back up shouldn't take too long. Judging by the leaderboard, more people have actually finished this level than Jakarta, so that's a good sign.
<!-- summary -->

{{< image src="grumpy-bananaquit.jpeg" alt="header image" >}}
A grumpy bananaquit. Taken by me.
{{< /image >}}

## First pass
The last couple of levels tended to use long (or specific length) passwords to embed instructions into our input. Typing in a few test passwords has me thinking that that approach won't work as well this time. The first new feature of this level that stands out is that our input is printed to the console "for verification". Looks like they're using `printf` for that, so maybe we can print out the password? We're also running the `test_password_valid` check prior to `printf`, which makes me further suspect that some malicious formatting is the way forward.

## Fun with Formatting
I spent some time looking at CMP calls and an ASCII code table before realizing that the behavior of `printf` is actually documented [in the manual](https://microcorruption.com/public/manual.pdf). We've got `%s`, `%x`, `%c`, and `%n` to play with (although I didn't see any checks for `%c` in the code). The `%n` verb is the most interesting; it saves the number of characters printed so far.

## Corruption
On my first few inputs, I stumbled upon a memory error. The input `%s%x%n` produces the error `load address unaligned: 7825`. Inspecting the memory dump just after the crash revealed `%s%x` in memory starting at `30ae`. The crash happened due to this sequence of instructions:

```asm
cmp.b  #0x6e, r14
jnz    $+0x8 <printf+0xf6>
mov    @r9, r15
mov    r10, 0x0(r15)
```

So long as we're currently reading an `n` character from our input, the program will load the value pointed to by r9 (`30b0` in this case), then write whatever's in r10 to the location pointed to by the loaded value. A little more investigation seems to show that r10 holds the number of characters preceding `%n`. This turns out to be important later.

## Writing something useful
So far, all the values I've been able to write into `30b0` have included percent signs. There don't appear to be any useful memory locations ending in `25`, however. Can I write an arbitrary value to `30b0`?

The instructions that control writing to that section of memory are a loop from `461a` to `4626`, which copies values from the input to a block ending at `30b2`. The loop iterates over the input as many times as there are percent signs in the input, copying from just before the input (the first copied value is 0x000), so all that's needed to write an arbitrary value to `30b0` is an input with the value followed by two formatting verbs. And if the second verb is `%n`, we'll write the input length (2, in this example) to that location in memory.

## Writing somewhere useful
I was considering the problem of how to enable writing to the program part of memory before I realized that I'd only be able to write values up to the input length limit. Considering that limitation, I started over looking at the main function and realized that the solution was simpler than I'd thought. The `test_password_valid` function writes a 1 or 0 to memory to indicate whether the password matches. And that memory location is already writeable.

Luckily, `test_password_valid` writes a 0 to indicate a password match, so unlocking the door only requires writing a non-zero value (the length of our non-verb input) to `30c6`. With the memory address and two verbs, the latter being `%n`, the door unlocks!

## Finishing up
These are a lot of fun, so I'll try to avoid going a year between puzzles again. The list of projects never seems to get any shorter though, so we'll see.
