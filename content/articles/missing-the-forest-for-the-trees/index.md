---
date: 2023-07-27T13:06:12-04:00
title: "Missing the Forest for the Trees"
draft: true
_build:
  render: true
  list: false
---
#### Or, Yet Another Discussion of Technical Interview Methodology
<!-- summary -->
The way we, as an industry, interview prospective individual contributors is exhausting and ineffective. Assuming, of course, that the goal is to hire engineers who can design and implement simple, maintainable software. This is a well-discussed topic, so we're unlikely to be treading new ground here, but hopefully this article will contribute some novel metaphors or approaches to the discussion.
<!-- summary -->

{{< image src="screw-bits.jpg" alt="header image" >}}
Taken by [Mika Baumeister](https://unsplash.com/@mbaumi)
{{< /image >}}

## Contrasting methodologies
Building software is all about solving problems. So, to determine an interviewee's fitness, it makes sense to have them solve problems. In my experience, the two most common ways to do this are asking candidates to implement an algorithm or discuss system design. The former gets the candidate writing code and provides the interviewer with a strong signal based upon how well the solution performs. The latter is less precise and asks the candidate to describe a solution to a broadly defined issue and discuss the tradeoffs involved.

Real-world interview processes tend to lie somewhere on a continuum between these archetypes. The distribution is not uniform though, as many companies hew towards algorithmic problems, specifically for the high-precision signal it provides. This is a categorical error.

## Precision vs accuracy
<!-- draft stuff
	- "high-signal" is provides precision due to rubric backing
	- high precision is great, but not at the expense of accuracy
		- define precision / accuracy
		- precision is how closely we can tell an eng conforms to the criteria we're testing for
		- accuracy is how closely the criteria we're testing for conforms to the job we're hiring for
	- very few engineers are actually solving algo problems in their day-to-day
	- list of things engineers generally care about / are responsible for
	- pivot into why systems design matches this list of items better than algo
-->
Precision is a great quality to have, but it's meaningless without accuracy. Imagine a thermometer that displays the temperature out to four decimal places, but it's incorrect by up to twenty degrees in either direction. That thermometer has great precision! And it's useless for taking the temperature.

Algorithmic programming problems are high-precision interview tools. They provide a specific performance score that be can mapped directly to a pass / fail decision. This makes the interviewer's job relatively easy and makes comparing candidates similarly straight-forward; both important qualities when senior engineers are running the interviews and there's a glut of prospects. Focusing on these advantages, however, misses the point. This high degree of precision isn't valuable because the method isn't _accurate_.

Asking candidates to implement an algorithm is a great test of their performance at deriving an algorithm. Very few organizations actually need anyone to do that. Why ask an employee to write a solution to the knapsack problem from scratch when perfectly good solutions already exist and are readily available.

System design problems lack precision, but they're accurate. While they don't have concise rubrics, they do map to the day-to-day responsibilities of software engineers. The reason organizations pay individual contributors is to create novel solutions to their specific problems. Discussing system design allows an interviewer to pose a problem similar to ones faced by their organization and in describing a solution, an interviewee demonstrates competency because they're _doing the job they're interviewing for_.

<!-- draft stuff
As an industry, we strive to become data-driven organizations. This is an admirable quality and confers the ability to view our business with precision and explain _why_ we do the things we do. Too often, however, this striving is myopic. Choosing an interview method that provides explicit results that can be mapped directly to a hiring decision misses the point. We want to hire competent engineers who can design and implement simple, maintainable software.
-->


### Algorithmic testing _can_ be useful!
<!-- draft stuff
- when you do need engineers to solve algo problems
- you want to hire folks fresh from college; they've been doing algo problems
-->

There's nothing inherently wrong with using algothrimic problems for technical interviews. When that category of problems matches the role, they're a fantastic tool. In such a case, algorithmic interview questions have _both_ precision and accuracy.

### Some meta-discussion
[draft]
- This topic has been discussed _a lot_. Why so little organizational change?
	- org change / fighting inertia is difficult and takes time (weak, but always plausible)
	- orgs value precision over accuracy because it shows that they're _doing something_ and doing it deliberately, regardless of whether it furthers their goals
