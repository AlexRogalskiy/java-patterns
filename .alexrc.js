exports.allow = [
  // We frequently refer to form props by their name "disabled".
  // Ideally we would alex-ignore only the valid uses (PRs accepted).
  "invalid",

  // Unfortunately "watchman" is a library name that we depend on.
  "watchman-watchwoman",

  // ignore rehab rule, Detox is an e2e testing library
  "rehab"
];

// Use a "maybe" level of profanity instead of the default "unlikely".
exports.profanitySureness = 1;
