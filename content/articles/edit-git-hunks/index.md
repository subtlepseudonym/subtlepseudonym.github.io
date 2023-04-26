---
date: 2019-10-19
title: "Editing Git Hunks for Fun and Profit"
draft: false
---
{{< image src="angry-annoyed-coffee.jpg" alt="header image" >}}
Taken by [Tim Gouw](https://www.pexels.com/@punttim)
{{< /image >}}

<!-- summary -->
If your development process is anything like mine, you tend to make lots of changes and worry about organizing the commits afterwards. This can lead to some frustration in separating the changes into neat, logical increments. Adding commits on a per-hunk basis can help.
<!-- summary -->

### Add changes by patch

Adding changes with the `--patch` flag makes telling a clear commit "story" easy. For example, after making a few minor changes to my dotfiles readme, running `git add --patch` outputs the following hunk:

```bash
$ git add . --patch
diff --git a/README.md b/README.md
index 741178e..447cdb7 100644
--- a/README.md
+++ b/README.md
@@ -1,5 +1,5 @@
 ## Custom files for various environments

-Miner change.
+Minor change.

Some context.

-Major change.
+Take a look at this major change.
Stage this hunk [y,n,q,a,d,s,e,?]?
```

The important part of this output is the last line —

`Stage this hunk [y,n,q,a,d,s,e,?]?`

These options let you decide what to do with each hunk of changes.

- **y** — stage this hunk
- **n** — don't stage this hunk
- **q** — do not stage this hunk or any of the remaining ones
- **a** — stage this hunk and all later hunks in the file
- **d** — do not stage this hunk or any of the later hunks in the file
- **s** — split the curent hunk into smaller hunks
- **e** — manually edit the current hunk
- **?** — print help (displays this list)

The **s** option is only present when git knows how to split up the hunk. Often, this is a good option to use before doing any manual editing. If we were to split up our above example, the first hunk would look like this:

```bash
diff --git a/README.md b/README.md
index 741178e..447cdb7 100644
--- a/README.md
+++ b/README.md
@@ -1,5 +1,5 @@
 ## Custom files for various environments

-Miner change.
+Minor change.
Stage this hunk [y,n,q,a,d,e,?]?
```

### Manually editing a hunk
Once we've decided on a hunk to edit, we can enter the **e** option and we're dropped into our default editor (as specified by `$EDITOR`). The file will contain the hunk as well as a few comments describing how to edit the hunk. For this example, I've elected not to split the hunk prior to editing.

```diff
# Manual hunk edit mode -- see bottom for a quick guide.
@@ -1,5 +1,5 @@
 ## Custom files for various environments

-Miner change.
+Minor change.

Some context.

-Major change.
+Take a look at this major change.
# ---
# To remove '-' lines, make them ' ' lines (context).
# To remove '+' lines, delete them.
# Lines starting with # will be removed.
#
# If the patch applies cleanly, the edited hunk will immediately be
# marked for staging.
# If it does not apply cleanly, you will be given an opportunity to
# edit again.  If all lines of the hunk are removed, then the edit is
# aborted and the hunk is left unchanged.
```

From here we can negate line additions or deletions. If we make any other edits, we should ensure that the edited line is prepended with a ‘+'. For example, we can change our example like so:

```diff
@@ -1,5 +1,5 @@
 ## Custom files for various environments

 Miner change.
# Here we've negated the line deletion
# Notice that the line is prepended with a ' '

 Some context.

-Major change.
+Take a look at this enormous change!
# Here we've changed the added line to say something different
# In my experience, this is the most useful type of edit
```

### Conclusion
I use git patch adding everyday and honestly can't believe how long I'd been writing code without it. The intent of this article was to provide a simple walkthrough of `git add --patch` along with a brief explanation of its features.

The best way to learn about this git feature is, of course, using it directly, but hopefully this article cleared up any points of confusion or made the process more approachable. If not, check out these posts on the same subject by [Markus Wein](https://nuclearsquid.com/writings/git-add/) and [Kenny Ballou](https://kennyballou.com/blog/2015/10/art-manually-edit-hunks).
