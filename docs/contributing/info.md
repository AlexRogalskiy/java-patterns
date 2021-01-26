# Contributing

Thanks for contributing to ObjectMappers!

This is a set of guidelines for contributing to IceCore Hashids. Please take a moment to review this document in order to make the contribution process easy and effective for everyone involved.

Following these guidelines helps to communicate that you respect the time of the developers managing and developing this open source project. In return, they should reciprocate that respect in addressing your issue, assessing changes, and helping you finalize your pull requests.

As for everything else in the project, the contributions to IceCore Hashids are governed by our [Code of Conduct](https://github.com/AlexRogalskiy/object-mappers-playground/blob/develop/CODE_OF_CONDUCT.md). By participating, you are expected to uphold this code. Please report unacceptable behavior via [email](mailto:development@nullables.io).

## _Getting Started_

ObjectMappers is an open source project and we love to receive contributions from the community! There are many ways to contribute, from [writing- and improving documentation and tutorials](info.md), [reporting bugs](info.md#bug-reports), [submitting enhancement suggestions](info.md#enhancement-suggestions) which can be incorporated into IceCore Hashids itself by [submitting a pull request](info.md#pull-requests).

The project development workflow and process uses [GitHub Issues](https://github.com/AlexRogalskiy/object-mappers-playground/issues)- and [Pull Requests](https://github.com/AlexRogalskiy/object-mappers-playground/pulls) management to track issues and pull requests.

Before you continue with this contribution guideslines we highly recommend to read the awesome GitHub [Open Source Guide](https://opensource.guide) on how to [making open source contributions](https://opensource.guide/how-to-contribute).

### _Bug Reports_

A bug is a _demonstrable problem_ that is caused by the code in the repository. This section guides you through submitting a bug report for IceCore Hashids. Following these guidelines helps maintainers and the community understand your report, reproduce the behavior and find related reports.

**Do NOT report security vulnerabilities in public issues!** Please contact the core team members and the project owner in a responsible manner by [email](mailto:development@nullables.io) only. We will assess the issue as soon as possible on a best-effort basis and will give you an estimate for when we have a fix and release available for an eventual public disclosure.

* **Use the** [**GitHub Issues search**](https://github.com/AlexRogalskiy/object-mappers-playground/issues) — check if the issue has already been reported. If it has **and the issue is still open**, add a comment to the existing issue instead of opening a new one. If you find a closed issue that seems like it is the same thing that you are experiencing, open a new issue and include a link to the original issue in the body of your new one.
* **Check if the issue has been fixed** — try to reproduce it using the [latest version](https://github.com/AlexRogalskiy/object-mappers-playground/releases/latest) and [`develop`](https://github.com/AlexRogalskiy/object-mappers-playground/tree/develop) branch in the repository.
* **Isolate the problem** — ideally create a [MCVE](info.md#mcve).

When you are creating a bug report, please provide as much detail and context as possible. Fill out [the required template](https://github.com/AlexRogalskiy/object-mappers-playground/blob/develop/.github/ISSUE_TEMPLATE.md), the information it asks for helps maintainers to reproduce the problem and resolve issues faster.

* **Use a clear and descriptive title** for the issue to identify the problem.
* **Describe the exact steps which reproduce the problem** in as many details as possible.
* **Include screenshots and animated GIFs** which show you following the described steps and clearly demonstrate the problem.
* **Provide specific examples to demonstrate the steps**. Include links to files or GitHub projects, or copy/pasteable snippets. If you are providing snippets in the issue, use [Markdown code blocks](https://help.github.com/articles/basic-writing-and-formatting-syntax) or [attach files to the issue](https://help.github.com/articles/file-attachments-on-issues-and-pull-requests).

If possible please provide more context by answering these questions:

* **Did the problem start happening recently** \(e.g. after updating to a new version of IceCore Hashids\) or was this always a problem? If the problem started happening recently, **can you reproduce the problem in an older version of IceCore Hashids**? What is the most recent version in which the problem does not happen?
* **Can you reliably reproduce the issue?** If not, provide details about how often the problem happens and under which conditions it normally happens.

Please include details about your configuration and environment:

* What is the version of IceCore Hashids you are using?
* What is the name and the version of the OS you're using?
  * Have you tried to reproduce it on different OS environments and if yes is the behavior the same for all?
* Which Java JDK/JRE distribution and version are you using? \(_Oracle_, _OpenJDK_, ...\)
* Are you running the project with your IDE or Maven?
  * Are you using any additional CLI arguments for Java or Maven?
  * What is the name and the version of the IDE you're using?

### _Enhancement Suggestions_

This section guides you through submitting an enhancement suggestion, including completely new features and minor improvements to existing functionality. Following these guidelines helps maintainers and the community understand your suggestion and find related suggestions.

* **Use the** [**GitHub Issues search**](https://github.com/AlexRogalskiy/object-mappers-playground/issues) — check if this enhancement has already been suggested. If it has **and the issue is still open**, add your additions as comment to the existing issue instead of opening a new one.
* **Check if the enhancement has already been implemented** — use the [latest version](https://github.com/AlexRogalskiy/object-mappers-playground/releases/latest) and [`develop`](https://github.com/AlexRogalskiy/object-mappers-playground/tree/develop) branch to ensure that the feature or improvement has not already been added.
* **Provide a reduced show case** — ideally create a [MCVE](info.md#mcve).

Before creating enhancement suggestions, please check if your idea fits with the scope and provide as much detail and context as possible using a structured layout like the [the issue template](https://github.com/AlexRogalskiy/object-mappers-playground/blob/develop/.github/ISSUE_TEMPLATE.md).

* **Use a clear and descriptive title** for the issue to identify the suggestion.
* **Provide a step-by-step description of the suggested enhancement** in as many details as possible and provide use-cases.
* **Provide examples to demonstrate the need of an enhancement**. Include copy/pasteable snippets which you use in those examples, use [Markdown code blocks](https://help.github.com/articles/basic-writing-and-formatting-syntax) or [attach files to the issue](https://help.github.com/articles/file-attachments-on-issues-and-pull-requests).
* **Describe the current behavior** and **explain which behavior you expected to see instead** and why.
* **Explain why this enhancement would be useful** to most IceCore Hashids users.
* **List some other libraries where this enhancement exists.**

### _Pull Requests_

This section guides you through submitting an pull request. Following these guidelines helps maintainers and the community to better understand your code.

**Please** [**suggest an enhancement**](info.md#enhancement-suggestions) **or** [**report a bug**](info.md#bug-reports) **first before embarking on any significant pull request** \(e.g. implementing features, refactoring code, fixing a bug\), otherwise you risk spending a lot of time working on something that the core team members and project owner might not want to merge into the project.

When you are submitting an pull request, please provide as much detail and context as possible. Fill out [the required template](https://github.com/AlexRogalskiy/object-mappers-playground/blob/develop/.github/PULL_REQUEST_TEMPLATE.md) to help maintainers to understand your submitted code.

* **Use a clear and descriptive title for the pull request**
* **Do not include issue numbers in the pull request title** but fill in the metadata section at the top of the [required pull request template](https://github.com/AlexRogalskiy/object-mappers-playground/blob/develop/.github/PULL_REQUEST_TEMPLATE.md) making use of the [GitHub issue keywords](https://help.github.com/articles/closing-issues-using-keywords) to link to specific [enhancement suggestions](info.md#enhancement-suggestions) or [bug reports](info.md#bug-reports).
* **Include screenshots and animated GIFs** which show you following the described steps and clearly demonstrate the change.
* **Make sure to follow the** [**Java**](info.md#java-code-style) **and** [**Git commit message**](info.md#git-commit-messages) **style guides**.
* **Remain focused in scope and avoid to include unrelated commits**.
* **Features and improvements should always be accompanied with tests and documentation**. If the pull request improves the performance consider to include a benchmark test, optimally including a chart.
* **Lint and test before submitting the pull request**.
* **Make sure to create the pull request from a** [**topic branch**](https://git-scm.com/book/en/v2/Git-Branching-Branching-Workflows).

**All pull requests must be send against the `develop` branch** - Please read the [branch organization](info.md#branch-organization) section below for details about the branching model.

### _Documentations_

IceCore Hashids has two main sets of documentation: the docs and guides, which helps users to learn about the project, and the API, which serves as a reference.

You can help improve the docs and guides by making them more coherent, consistent or readable, adding missing information, correcting factual errors, fixing typos, bringing them up to date when there are differences to the latest version. This can be done by submitting a [enhancement suggestion](info.md#enhancement-suggestions) and then opening a [pull request](info.md#pull-requests) for it.

## _Branch Organization_

The IceCore Hashids uses the [gitflow](http://nvie.com/posts/a-successful-git-branching-model) branching model. The repository consists of two core branches with an infinite development lifecycle:

* `master` - The source code of `HEAD` always reflects a tagged release version.
* `develop` - The default branch where the source code of `HEAD` always reflects a state with the latest development state.

**All** [**pull requests**](info.md#pull-requests) **for the limited development lifecycle** _**story**_**/**_**topic**_ **branches must be send against the `develop` branch**.

## _How else can I help?_

### _Improve Issues_

Some issues are created with missing information, not reproducible, or plain invalid. You can help to make it easier for maintainer to understand and resolve them faster. since handling issues takes a lot of time that could rather spend on writing code.

### _Give Feedback On Issues and Pull Requests_

We're always looking for more opinions on discussions in issues and pull request reviews which is a good opportunity to influence the future direction of IceCore Hashids.

The [question](https://github.com/AlexRogalskiy/object-mappers-playground/labels/question) issue label is a good place to find ongoing discussions and questions.

## _Styleguides_

Every major open source project has its own style guide, a set of standards and conventions for the writing and design of code, documentations and Git commit messages. It is much easier to understand a large codebase when all the code in it is in a consistent style.

A style guide establishes and enforces style to improve the intelligibility and communication within the project community. It ensures consistency and enforces best practice in usage and language composition.

### _Java Code Style_

IceCore Hasids adheres to the \[Nullables Studio Java Style Guide\]\[styleguide-java-github\].

\[!\[\]\[styleguide-java-badge\]\]\[styleguide-java-github\]

### _Git Commit Messages_

A well-crafted Git commit message is the best way to communicate _context_ about a change to the maintainers. The code will tell what changed, but only the commit message can properly tell why. Re-establishing the context of a piece of code is wasteful. We can't avoid it completely, so our efforts should go to reducing it as much as possible.

IceCore Hasids adheres to the \[Nullables Studio Git Style Guide\]\[styleguide-git-github\].

\[!\[\]\[styleguide-git-badge\]\]\[styleguide-git-github\]

The style guide assumes that you are familiar with the [gitflow](http://nvie.com/posts/a-successful-git-branching-model) branching model.

## _MCVE_

A Minimal, Complete, and Verifiable Example.

When [reporting a bug](info.md#bug-reports), sometimes even when [suggestig a enhancement](info.md#enhancement-suggestions), the issue can be processed faster if you provide code for reproduction. That code should be…

* …Minimal – Use as little code as possible that still produces the same behavior
* …Complete – Provide all parts needed to reproduce the behavior
* …Verifiable – Test the code you're about to provide to make sure it reproduces the behavior

A MCVE is a common practice like on [Stack Overflow](https://stackoverflow.com/help/mcve) and sometimes it is also called [SSCCE](http://sscce.org), a _Short, Self Contained, Correct \(Compilable\), Example_.

The recommended way for GitHub based projects is to create it as [Gist](https://gist.github.com) or new repository, but of course you can [attach it to issues and pull requests as files](https://help.github.com/articles/file-attachments-on-issues-and-pull-requests), use any free code paste- or file hosting service or paste the code in [Markdown code blocks](https://help.github.com/articles/basic-writing-and-formatting-syntax) into the issue.

### _Minimal_

The more code there is to go through, the less likely developers can understand your enhancement or find the bug. Streamline your example in one of two ways:

* **Restart from scratch**. Create new code, adding in only what is needed to demonstrate the behavior and is also useful if you can't post the original code publicly for legal or ethical reasons.
* **Divide and conquer**. When you have a small amount of code, but the source of the bug is entirely unclear, start removing code a bit at a time until the problem disappears – then add the last part back and document this behavior to help developers to trace- and debug faster.

#### _Minimal and readable_

Minimal does not mean terse – don't sacrifice communication to brevity. Use consistent naming and indentation following the [styleguide](info.md#styleguides), and include comments if needed to explain portions of the code.

### _Complete_

Make sure all resources and code necessary to reproduce the behavior is included. The problem might not be in the part you suspect it is, but another part entirely.

### _Verifiable_

To entirely understand your enhancement or bug report, developers will need to verify that it _exists_:

* **Follow the contribution guidelines regarding the description and details**. Without information developers won't be able to understand and reproduce the behavior.
* **Eliminate any issues that aren't relevant**. Ensure that there are no compile-time errors.
* **Make sure that the example actually reproduces the problem**. Sometimes the bug gets fixed inadvertently or unconsciously while composing the example or does not occur when running on fresh machine environment.

## _Versioning_

IceCore Hashids follows the \[Arctic Versioning Specification\]\[arcver\] \(ArcVer\) which is a lightweight and fully compatible derivative of [Semantic Versioning](http://semver.org) \(SemVer\). We release patch versions for bugfixes, minor versions for enhancements like new features and improvements, and major versions for any backwards incompatible changes. Deprecation warnings are introduced for breaking changes in a minor version so that users learn about the upcoming changes and migrate their code in advance.

Every significant change is documented in the [changelog](https://github.com/AlexRogalskiy/object-mappers-playground/blob/develop/CHANGELOG.md).

## _Credits_

Thanks for the inspirations and attributions to GitHub's [Open Source Guides](https://opensource.guide) and various contribution guides of large open source projects like [Atom](https://github.com/atom/atom/blob/master/CONTRIBUTING.md), [React](https://facebook.github.io/react/contributing/how-to-contribute.html) and [Ruby on Rails](http://guides.rubyonrails.org/contributing_to_ruby_on_rails.html).

