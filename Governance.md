# Governance of rules_scala

[bazelbuild/rules_scala](https://github.com/bazelbuild/rules_scala) is under the [bazelbuild](https://github.com/bazelbuild) org
but is governed by contributors from the community.

## Goals of this document

To clarify:

1. Values of the project.
2. How to get a PR merged
3. How long you should need to wait for a review
4. How to resolve conflicts in project direction
5. How to make larger and potentially disruptive changes

## Values of rules_scala

1. **Correctness**: Bazel values fully reproducible builds which are reliable and hermetic (only depend on the current state of your repository)
2. **Speed**: we want to build as fast as possible. In a large repository, we believe caching and remote parallel builds are the only way to achieve this. Without correctness, we can't cache and use remote builds, so correctness enables speed. We will almost never trade off correctness for speed.
3. **Usability**: we want it to be as easy as possible to adopt and to maintain a build with these rules. Usability is a lower priority than correctness or speed. We will virtually never trade either correctness or speed for more usability. Usability includes stability: we seek to absolutely minimize breaking changes. We will prefer to keep some warts or deprecated methods than force users to constantly make changes to keep their builds on the latest version of the rules.

## How to make a PR

We welcome pull requests and do all development in the open. Pull requests
should be in the smallest testable units possible. Ideally, a PR is fewer than 400 lines of
change, but we understand in some cases it may be more. If your PR is much larger than normal, we
may ask you to split it into smaller changes. You should see a comment
in 24 business hours on your PR. Your PR *may* be ignored if it has a red CI. It
is your responsibility to get your PR green, or to ask for clarification if you
doubt a test failure is due to your change.

Code review increases the quality of our code.  We welcome code review by anyone:
you don't need to be a maintainer to offer your review.

PRs are merged when 2 or more maintainers have approved the PR and there are no
blocking objections by any maintainers, and not before 24 business hours have
passed to allow sufficient time review. When there are disagreements by
maintainers that cannot be settled in PR discussion, we will use a video chat
scheduled when 3/4 or more of the maintainers can make it. After the video chat we
will choose a course of action. If we cannot all agree, if 2/3 or more support
merging a change, it will be done, otherwise we bias to no-merge.

## Reporting bugs

We welcome bug reports and aspire to create an environment in which bug fixes are easy to contribute.
There is currently no one paid to fix bugs that have been filed, so patience
and direct contributions are greatly appreciated. The contributors and maintainers
are happy to help coach prospective contributors in fixing bugs.

An ideal bug report should include an issue filed in GitHub that is linked to a
corresponding PR that adds a failing test to the repo. That way: we can track the issue,
have a goalpost test to turn green, and also have an enduring test case to
protect against regressions.

## Proposing designs

For any change to design or the code that will span many PRs, we recommend
submitting a PR containing an md file that outlines the planned change. We can
then discuss the change on that PR. When there is a consensus, we can open a
series of issues to track various portions of the work.

## Maintainers

Maintainers should generally be [top contributors to the repo](https://github.com/bazelbuild/rules_scala/graphs/contributors).
Being a maintainer is not an honorific, but a responsibility to keep the project
active and useful for a broad base of Scala and Bazel users.

Being a maintainer is a responsibility to review *each* PR that is submitted
within 24 business hours. Maintainers should be advocates for the many current
users as well as for the goal of improving the rules for future users. We want
to give a high quality of service to PRs to encourage more contribution from the
community.

Maintainers are selected by 2/3 or more approval of the current set of
maintainers. Any maintainer who has served for more than 6 months
may propose new maintainers. Any maintainer who is no longer responsive may
be removed by other maintainers by a 2/3 or more approval. Changing the rules
of this document requires a 2/3 or more approval of the current maintainers.

Current maintainers: (edit as needed)
* Oscar Boykin, @johnynek
* Ittai Zeidman, @ittaiz

Past maintainers:
