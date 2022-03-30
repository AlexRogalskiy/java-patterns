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
class JsonsReporter {
  constructor(globalConfig, options) {
    this._globalConfig = globalConfig
    this._options = options
  }

  onRunComplete(contexts, results) {
    results.testResults.forEach((testResultItem) => {
      const testFilePath = testResultItem.testFilePath

      testResultItem.testResults.forEach((result) => {
        if (result.status !== 'failed') {
          return
        }

        result.failureMessages.forEach((failureMessages) => {
          const newLine = '%0A'
          const message = failureMessages.replace(/\n/g, newLine)
          const captureGroup = message.match(/:([0-9]+):([0-9]+)/)

          if (!captureGroup) {
            console.log('Unable to extract line number from call stack')
            return
          }

          const [, line, col] = captureGroup
          console.log(
            `::error file=${testFilePath},line=${line},col=${col}::${message}`,
          )
        })
      })
    })
  }
}

module.exports = JsonsReporter
