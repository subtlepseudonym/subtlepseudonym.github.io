---
date: 2024-03-27T10:57:11-04:00
title: "Microcorruption: Montevideo"
series: "Microcorruption"
draft: false
_build:
  render: true
  list: false
---

<!-- summary -->
Montevideo adds another layer of indirection to the problem we encountered in Whitehorse. The device is still vulnerable to overflow, but we can't just encode whatever we want!
<!-- summary -->

{{< image src="gator.jpg" alt="header image" >}}
Gator lounging in a swamp. Taken by me.
{{< /image >}}

## First pass
It looks like we've got access the same type of vulnerability that allowed us to solve the Whitehorse problem; the location that `login` returns to is stored in a memory location that our password attempt can write to. Attempting the same solution doesn't work though. Standard ascii characters are stored just fine and even the operations for pushing 0x7f onto the stack work (`3012 7f00`), but the operation for calling `INT` gets zeroed out.

We've got two new function calls in this level: `strcpy` and `memset`. Before stepping through them properly, my best guess is that they copy the password attempt from where it's initially written (0x2400) to a place closer to the program code, replacing potentially malicious patterns in the process. That or the vastly simpler case that `3012 7f00` ends in zero, which looks like the end of a password string.

## Making some attempts
After a punching in "password" and stepping through, it looks like `strcpy` is doing all the work of moving the attempt string into our target memory location. I'm not 100% on what `memset` does, but it doesn't appear to alter the sections of memory we're trying to overflow into, so I'm going to ignore it for now. The `strcpy` function does not, in fact, do any detection of malicious code and we're really only getting tripped up by the 00 written as a part of pushing 0x7f onto the stack.

Bypassing a check for 00 should be fairly straight-forward. Let's start with the least number of changes to our Whitehorse solution. Offsetting the zero in `7f00` by one position should allow us to sneak that value past `strcpy`. It remains to be seen if we can later move the program counter to an odd-numbered memory location though.

Turns out, it doesn't like that. Upon "returning" to 0x4401, the CPU cannot read the command and displays it as an invalid operation.

## Gotta be possible without 00
We've shown that we can execute code, so long as it doesn't contain 00. We can definitely push 0x7f onto the stack without directly including 00 in our password attempt.

Taking a look at the [lockitall manual](https://microcorruption.com/public/manual.pdf), we've got access to bitwise AND. That should let us encode something like 0x017f and 0x107f, AND the two, then push the result onto the stack.

As it turns out, exactly that is possible. Encoding a password attempt with the following commands gets us in:
- move 0x017f into r14
- move 0x107f into r15
- AND r14 and r15 (storing in r15)
- push r15
- call `INT`
