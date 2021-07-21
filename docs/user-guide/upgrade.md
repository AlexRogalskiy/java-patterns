# Upgrading

- [Automated Upgrade](upgrade.md#automated-upgrade)
  - [Step 1: Open An Issue With The Upgrade Template.](upgrade.md#step-1-open-an-issue-with-the-upgrade-template)
  - [Step 2: Click `Submit new issue`](upgrade.md#step-2-click-submit-new-issue)
  - [Step 3: A Link to Pull Request Will Appear](upgrade.md#step-3-a-link-to-pull-request-will-appear)
  - [Step 4: Review & Merge PR](upgrade.md#step-4-review-and-merge-pr)
- [Manual Upgrade](upgrade.md#manual-upgrade)
  - [Easy Way (Recommended)](upgrade.md#easy-way-recommended)
  - [Advanced](upgrade.md#advanced)

There are two ways to upgrade. One is an automated way that assumes you have made no changes to the HTML of
your site. Alternatively, you may [upgrade manually](upgrade.md#manual-upgrade) and determine which changes to
accept or reject. For most people we recommend upgrading fastpages automatically.

## *Automated Upgrade*

- This method is appropriate for those who have not customized the HTML of their site.
- **If you are unsure, try the Automated approach and review which files are changed in the automated PR**
  to see if this appropriate for you.

### Step 1: Open An Issue With The Upgrade Template.

- Open a new issue in your repository, and push the "Get Started" button for the
  `[ObjectMappers] Automated Upgrade` Issue template, which looks like this:
  - **IF YOU DON'T SEE THIS**: you have an older version of fastpages and you **must**
    [**manually upgrade**](upgrade.md#manual-upgrade) **once** to get this new functionality.

### Step 2: Click `Submit new issue`

- Be careful not to change anything before clicking the button.

### Step 3: A Link to Pull Request Will Appear

- This issue will trigger GitHub to open a PR making changes to your repository for the upgrade to take
  place. A comment with the link to the PR will be made in the issue, and will look like this:

  It is possible that you might receive an error message instead of this command. You can follow the
  instructions in the comment to troubleshoot the issue. Common reasons for receiving an error are:

  - You are up to date, therefore no upgrade is possible. You will see an error that there is "nothing to
    commit".
  - You already have a PR from a previous upgrade open that you never merged.

### Step 4: Review and Merge PR

- Ensure that you read the instructions in the PR carefully. Furthermore, carefully review which files will
  be changed to determine if this interferes with any customizations you have mades to your site. When
  ready, select `Merge pull request`.
- If the PR is making undesired changes to files you can use the manual upgrade approach instead.

## *Manual Upgrade*

### Easy Way (Recommended)

Create a new repository with the current project by following the
[setup instructions](https://github.com/AlexRogalskiy/object-mappers-playground#setup-instructions) in the
README.

### Advanced

- This method is appropriate for those who made customizations to the HTML.
- You must proceed with caution, as new versions may not be compatible with your customizations.
- Be careful to not duplicate files, as files have been reorganized several times.
