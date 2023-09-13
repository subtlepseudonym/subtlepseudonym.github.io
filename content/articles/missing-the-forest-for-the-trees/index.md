---
date: 2023-07-27T13:06:12-04:00
title: "Missing the Forest for the Trees"
draft: false
_build:
  render: true
  list: false
---
[draft]
#### Or, Yet Another Discussion of Tech Company Interview Methodology
<!-- summary -->
The way we, as an industry, interview prospective individual contributors is exhausting and ineffective. The goal of these interviews is to hire engineers who can design and implement simple, maintainable software, so why are we asking them contrived questions about dynamic programming? Engineers ought to be at least competent programmers, but the work of software engineering is more often a question of design.
<!-- summary -->

{{< image src="screw-bits.jpg" alt="header image" >}}
Taken by [Mika Baumeister](https://unsplash.com/@mbaumi)
{{< /image >}}

## Contrasting methodologies
Building software is all about solving problems. So, to determine an interviewee's fitness, it makes sense to have them solve problems. In my experience, the two most common ways to do this are asking candidates to implement an algorithm or discuss system design. The former gets the candidate writing code and provides the interviewer with a quantifiable performance score. The latter is less structured, asking the candidate to describe a solution to a broadly defined issue and discuss the tradeoffs involved.

Real-world interview processes lie on a continuum between these archetypes and few adhere strictly to either end. The distribution along that continuum is not uniform though: many companies skew towards algorithmic problems, often strongly, for the quantifiable metrics they provide. Such policy indicates a category error in the understanding of how software is built.

## Precision vs accuracy
Precision is a great quality to have, but it's meaningless without accuracy. Imagine a thermometer that displays the temperature out to four decimal places, but it's incorrect by up to twenty degrees in either direction. That thermometer has great precision! And it's useless for taking the temperature.

Algorithmic programming problems are high-precision interview tools. They provide lots of measurable performance metrics that be can mapped directly to a pass / fail decision. This makes the interviewer's job relatively easy and makes comparing candidates straight-forward. Focusing on these advantages, however, misses the point. This high degree of precision isn't valuable because the method isn't _accurate_[^1].

Asking candidates to implement an algorithm is a great test of their performance _at deriving an algorithm_. Few organizations actually need anyone to do that. Why ask an employee to write a solution to a well-understood problem when excellent solutions exist and are readily available?

System design problems lack precision, but they're accurate. While they're light on quantifiable metrics, they require demonstration of the skills needed in the day-to-day responsibilities of software engineers. The reason organizations pay individual contributors is to create novel solutions to their specific problems. Discussing system design allows an interviewer to pose a problem similar to ones faced by their organization and in describing a solution, an interviewee demonstrates competency because they're _doing the job they're interviewing for_.

Asking candidates to solve contrived algorithmic problems may provide insight into how they manage memory or optimize for space or time complexity. Those skills, while _useful_, do not make an excellent software engineer. They are, at best, indicators of a skilled coder. And as is
[often](https://tomgamon.com/posts/writing-code-is-the-easy-part/)
[written](https://camlittle.com/posts/2020-05-04-coding-is-the-easy-part/)
[and](https://medium.com/@alexandruhogea1/writing-code-is-easy-ad0419d85065)
[more](https://swizec.com/blog/coding-is-the-easy-part/)
[often](https://www.reddit.com/r/learnprogramming/comments/s2zmz1/coding_is_the_easy_part/)
[repeated](https://pawnmaster.com/writing-code-is-the-easy-part/),
writing code is the easy part[^2], so let's test candidates for the hard stuff.

### Precise system design
Accuracy is great, but it cannot stand alone. Interview questions need _some_ precision to be useful[^3]. How can system design problems be made more precise? The same way organizations judge their own success: service-level objectives (SLOs). Given a design problem, a set of SLOs should determine how well a solution performs when faced with real-world problems. How well does the solution scale with increased traffic? Does the solution consider limited resources (web hosting can get expensive)? Does the solution make tradeoffs that align with the organization's existing business constraints?

### Algorithmic testing _can_ be useful!
There's nothing inherently wrong with using algothrimic problems for technical interviews. When that category of problems matches the role the interview is hiring for, they're a fantastic tool. If the role is primarily one of implementing tricky algorithms, the interview _should_ consist of implementing those algorithms. In such a case, algorithmic interview questions have _both_ precision and accuracy.


[^1]: This is an example of [the McNamara fallacy](https://en.wikipedia.org/wiki/McNamara_fallacy).

[^2]: This is not to say that hard programming problems don't exist, but that most folks aren't getting paid to solve those problems (or, quite likely, they're under-represented in the discourse regarding tech interviews).

[^3]: See [Mar's Law](https://spacecraft.ssl.umd.edu/akins_laws.html): Everything is linear if plotted log-log with a fat magic marker
