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
import * as https from "https"
import * as path from "path"

import {Contributor} from "./models/contributor"
import * as painter from "./helpers/painter"
import {createScreenshot} from "./helpers/screenshots"

/**
 * A library for fetching project contributors.
 *
 * @remarks
 * The `contributors` library defines the {@link Contributor} and {@link ContributorsConfig} interfaces,
 * which are used to build project contributors.
 *
 * @packageDocumentation
 */
/**
 * Parse link header
 * @param linkHeader Link header as string
 * @returns Object that contains the page numbers of `prev`, `next` and `last`.
 */
const parseLinkHeader = (linkHeader: string) => {
  const nextPagePattern = new RegExp(/\bpage=(\d)[^>]*>\srel="next"/)
  const lastPagePattern = new RegExp(/\bpage=(\d)[^>]*>\srel="last"/)
  const prevPagePattern = new RegExp(/\bpage=(\d)[^>]*>\srel="prev"/)

  const nextPage = nextPagePattern.exec(linkHeader) ?? ''
  const lastPage = lastPagePattern.exec(linkHeader) ?? ''
  const prevPage = prevPagePattern.exec(linkHeader) ?? ''

  return {nextPage, lastPage, prevPage}
}

/**
 * Get all contributors from GitHub API.
 */
const fetchContributors = (
  page: string
): Promise<{ contributorsOfPage: Contributor[]; nextPage: string }> => {
  return new Promise((resolve, reject) => {
    const requestOptions: https.RequestOptions = {
      method: 'GET',
      hostname: 'api.github.com',
      path: `/repos/AlexRogalskiy/java-patterns/contributors?page=${page}`,
      port: 443,
      headers: {
        link: 'next',
        accept: 'application/json',
        'User-Agent': 'Contributors script',
      },
    }

    const req = https.request(requestOptions, (res) => {
      const {nextPage, lastPage, prevPage} = parseLinkHeader(
        res.headers?.link?.toString() ?? ''
      )
      console.log(
        '> Material Icon Theme:',
        painter.yellow(
          `[${page}/${
            lastPage ? lastPage[1] : prevPage ? +prevPage[1] + 1 : 1
          }] Loading contributors from GitHub...`
        )
      )
      const result: Uint8Array[] = []
      res.on('data', (data: Buffer) => {
        result.push(data)
      })

      res.on('end', () => {
        try {
          const buffer = Buffer.concat(result)
          const bufferAsString = buffer.toString('utf8')
          const contributorsOfPage = JSON.parse(bufferAsString)
          resolve({contributorsOfPage, nextPage: nextPage?.[1]})
        } catch (error) {
          reject(error)
        }
      })
    })

    req.on('error', (error) => {
      console.error(error)
      reject(error)
    })

    req.end()
  })
}

const createContributorsList = (contributors: Contributor[]) => {
  const list = contributors
    .map((c) => {
      return `<li title="${c.login}"><img src="${c.avatar_url}" alt="${c.login}"/></li>`
    })
    .join('\n')

  const htmlDoctype = '<!DOCTYPE html>'
  const styling = '<link rel="stylesheet" href="contributors.css">'
  const generatedHtml = `${htmlDoctype}${styling}<ul>${list}</ul>`

  const outputPath = path.join(__dirname, '..', 'assets', 'contributors.html')
  fs.writeFileSync(outputPath, generatedHtml)
  return outputPath
}

const init = async () => {
  const contributorsList: Contributor[] = []
  let page = '1'

  // iterate over the pages of GitHub API
  while (page !== undefined) {
    const result = await fetchContributors(page)
    contributorsList.push(...result.contributorsOfPage)
    page = result.nextPage
  }

  if (contributorsList.length > 0) {
    console.log(
      '> Material Icon Theme:',
      painter.green('Successfully fetched all contributors from GitHub!')
    )
  } else {
    console.log(
      '> Material Icon Theme:',
      painter.red('Error: Could not fetch contributors from GitHub!')
    )
    throw Error()
  }
  const outputPath = createContributorsList(contributorsList)

  // create the image
  console.log('> Material Icon Theme:', painter.yellow('Creating image...'))
  const fileName = 'contributors'
  createScreenshot(outputPath, fileName)
    .then(() => {
      console.log(
        '> Material Icon Theme:',
        painter.green(`Successfully created ${fileName} image!`)
      )
    })
    .catch(() => {
      throw Error(painter.red(`Error while creating ${fileName} image`))
    })
}

init()
