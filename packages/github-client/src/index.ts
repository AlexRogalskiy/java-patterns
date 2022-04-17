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
import * as fs from "fs"

import * as Github from "@octokit/rest"
import _ from "underscore";

import {getAllOrgRepos, getFile, isUserInOrg} from "./helpers/utils"

const org = `${process.env.GITHUB_ORG}`
const repo = `${process.env.GITHUB_REPO}`
const repoCache = `${process.env.CACHE_DIR}/repos.json`

const gh = new Github.Octokit({headers: {"user-agent": "Org README checker"}})
gh.auth({
  type: "token",
  token: process.env.GITHUB_TOKEN,
}).then(_ => console.log(">>> GitHub client is authenticated! >>>"))

const log = (repo, message) => {
  console.log(`[${repo.name}] - ${message}`)
}

const main = async () => {
  let repoSets: any[]
  if (fs.existsSync(repoCache)) {
    repoSets = JSON.parse(fs.readFileSync(repoCache).toString())
  } else {
    repoSets = await getAllOrgRepos(gh, org)
    fs.writeFileSync(repoCache, JSON.stringify(repoSets))
  }

  const repos = repoSets["data"]
  const result = _.find(repos, r => r.name === repo)

  await doWork(result)
}

const doWork = async (repo) => {
  const readme = await getFile(gh, repo, "README.md")
  if (!readme) {
    log(repo, "Could not find a README")
    return
  }

  const pp = /__Point People:__ (.*)/g
  const pointMatches = readme.match(pp)

  // http://stackoverflow.com/questions/1500260/detect-urls-in-text-with-javascript
  const urlRegex = /(\b(https?|ftp|file):\/\/[-A-Z0-9+&@#\/%?=~_|!:,.;]*[-A-Z0-9+&@#\/%=~_|])/ig;

  if (!pointMatches || pointMatches.length === 0) {
    const contributors: any = await gh.rest.repos.getContributorsStats({
      owner: org,
      repo: repo.name
    })
    const authors = contributors.data.map(c => `@${c.author.login}`).join(", ")
    log(repo, `>>> repository contributors: ${authors} >>>`)
  } else {
    const ownerString = pointMatches[0] as string
    const urls = ownerString.match(urlRegex) || []
    const githubOwners = urls.filter(u => u.includes("github")).map(f => f.split("/").pop())
    const slackUrls = urls.filter(u => u.includes("slack")).map(f => f.split("/").pop())

    if (githubOwners.length === 0 && slackUrls.length === 0) {
      log(repo, "Has no owners")
    } else {

      const usersNotInOrg: any[] = []
      for (const owner of githubOwners) {
        const inOrg = await isUserInOrg(gh, org, owner)
        if (!inOrg) {
          usersNotInOrg.push(owner)
        }
      }
      if (usersNotInOrg.length) {
        log(repo, "Found someone not in the org: " + usersNotInOrg)
      }
    }
  }
}

main().then(_ => console.log(">>> GitHub client is finished! >>>"))

process.on("unhandledRejection", (reason: string, _: any) => {
  console.log("Error: ", reason)
})
