/**
 * Configurations for lint-staged.
 *
 * @see https://github.com/okonet/lint-staged#configuration
 */
module.exports = {
  "*.{css,html,js,json,yaml,yml}": "prettier --check",
  "*.md": ["remark --no-stdout", "prettier --check"],
  "*.{ts,tsx}": [
    "import-conductor --staged -p @myorg",
    "git add"
  ]
};
