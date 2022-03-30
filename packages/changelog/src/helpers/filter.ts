/*
 * Copyright (C) 2022 The SensibleMetrics team (http://sensiblemetrics.io/)
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 *         http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
/**
 * Filters out "Revert" commits as well as the commits they revert, if found.
 */
function filterReverts(commits) {
  const revertCommits = commits.filter(commit => commit.revertsHashes.length);
  const commitHashes = commits.map(commit => commit.hash);

  let hashesToRemove: any[] = [];
  revertCommits.forEach(revertCommit => {
    const allFound = revertCommit.revertsHashes.every(hash => {
      return commitHashes.includes(hash);
    });

    if (allFound) {
      hashesToRemove = [
        ...hashesToRemove,
        ...revertCommit.revertsHashes,
        revertCommit.hash,
      ];
    }
  });

  return commits.filter(commit => !hashesToRemove.includes(commit.hash));
}

export function normalizeLog(commits) {
  commits = commits.filter(line => !line.subject.startsWith('Publish '));
  return filterReverts(commits);
}
