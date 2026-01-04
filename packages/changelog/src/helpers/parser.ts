/*
 * Copyright (C) 2022 SensibleMetrics, Inc. (http://sensiblemetrics.io/)
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
import {execSync} from "child_process"

const REVERT_MESSAGE_COMMIT_PATTERN = /This reverts commit ([^.^ ]+)/
const AREA_PATTERN = /\[([^\]]+)\]/g

function getCommitMessage(hash) {
  return execSync(`git log --format=%B -n 1 ${hash}`).toString().trim()
}

function parseRevertCommit(message) {
  // EX: This reverts commit 6dff0875f5f361decdb95ad70a400195006c6bba.
  // EX: This reverts commit 6dff0875f5f361decdb95ad70a400195006c6bba (#123123).
  const fullMessageLines = message
    .trim()
    .split('\n')
    .filter(line => line.startsWith('This reverts commit'))
  return fullMessageLines.map(
    line => line.match(REVERT_MESSAGE_COMMIT_PATTERN)[1]
  )
}

function parseAreas(subject) {
  const areaChunk = subject.split(' ')[0] || ''
  const areas = areaChunk.match(AREA_PATTERN)
  if (!areas) {
    return ['UNCATEGORIZED']
  }

  return areas.map(area => area.substring(1, area.length - 1))
}

export function parseCommits(logLines) {
  const commits: any[] = []

  logLines.forEach(line => {
    let [subject, hash] = line.split(' &&& ')
    subject = subject.trim()

    const message = getCommitMessage(hash)
    const revertsHashes = parseRevertCommit(message)
    const areas = parseAreas(subject)

    commits.push({
      hash,
      areas,
      subject,
      message,
      revertsHashes,
    })
  })

  return commits
}
