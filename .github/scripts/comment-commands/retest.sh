#!/usr/bin/env bash

#doc: provide help on how to trigger new CI build

# posting a new commit from this script does not trigger CI checks
# https://help.github.com/en/actions/reference/events-that-trigger-workflows#triggering-new-workflows-using-a-personal-access-token

set -eu

code='```'

pr_url="$(jq -r '.issue.pull_request.url' "${GITHUB_EVENT_PATH}")"
commenter="$(jq -r '.comment.user.login' "${GITHUB_EVENT_PATH}")"
assoc="$(jq -r '.comment.author_association' "${GITHUB_EVENT_PATH}")"

curl -LSs "${pr_url}" -o pull.tmp
source_repo="$(jq -r '.head.repo.ssh_url' pull.tmp)"
branch="$(jq -r '.head.ref' pull.tmp)"
pr_owner="$(jq -r '.head.user.login' pull.tmp)"
maintainer_can_modify="$(jq -r '.maintainer_can_modify' pull.tmp)"

# PR owner
# =>
# has local branch, can simply push
if [[ "${commenter}" == "${pr_owner}" ]]; then
  cat <<-EOF
To re-run CI checks, please follow these steps with the source branch checked out:
${code}
git commit --allow-empty -m 'trigger new CI check'
git push
${code}
EOF

# member AND modification allowed by PR author
# OR
# repo owner
# =>
# include steps to fetch branch
elif [[ "${maintainer_can_modify}" == "true" ]] && [[ "${assoc}" == "MEMBER" ]] || [[ "${assoc}" == "OWNER" ]]; then
  cat <<-EOF
To re-run CI checks, please follow these steps:
${code}
git fetch "${source_repo}" "${branch}"
git checkout FETCH_HEAD
git commit --allow-empty -m 'trigger new CI check'
git push "${source_repo}" HEAD:"${branch}"
${code}
EOF

# other folks
# =>
# ping author
else
  cat <<-EOF
@${pr_owner} please trigger new CI check by following these steps:
${code}
git commit --allow-empty -m 'trigger new CI check'
git push
${code}
EOF
fi
