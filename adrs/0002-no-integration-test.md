# 2. No integration test

Date: 2019-10-20

## Status

Accepted

## Context

VS Code has documented [how to test an extension][testing-extension] in integration with VS Code API.

> These tests will run inside a special instance of VS Code named the `Extension Development Host`, and have
> full access to the VS Code API.

But VS Code test runner is adapted to be used with [mocha][mocha] or [Jasmine][jasmine].

For unit tests, we want to use [Jest][jest]. But Jest and mocha have conflicting types, preventing TS to
build. A solution would have been to create a custom test runner for VS Code API, that would run integration
tests with Jest. But we didn't managed to create one that works.

That's partly because Jest doesn't have an official way to run tests programatically. We weren't able to make
VS Code test runner work with Jest `runCLI()` (async) method.

Also, integration tests were flacky when I tried to make them work. I don't want to waste time hacking my way
around the current solution which doesn't seem mature enough to me.

## Decision

We won't do integration tests. We'll rely on unit tests (e.g. state-based tests, collaboration tests and
contract tests).

## Consequences

We can use [Jest][jest] to write (unit) tests.

Tests will run fast. They will be easy to write and maintain.

We won't be able to automatically test the extension with the actual VS Code API.

[testing-extension]: https://code.visualstudio.com/api/working-with-extensions/testing-extension
[mocha]: https://mochajs.org/
[jasmine]: https://jasmine.github.io/
[jest]: https://jestjs.io/
