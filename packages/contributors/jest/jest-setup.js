/*
 * Copyright (C) 2021 The SensibleMetrics team (http://sensiblemetrics.io/)
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
import * as log from "loglevel"
import fetchMock from "jest-fetch-mock";

// rewire global.fetch to call 'fetchMock'
fetchMock.enableMocks();

if (process.env.LOGLEVEL) {
  log.setLevel(process.env.LOGLEVEL)
  //log.setLevel(process.env.LOGLEVEL as log.LogLevelDesc)
} else {
  log.disableAll();
}

global.__NODE_ENV__ = 'test'
global.fetch = fetchMock
// global.fetch = () => {
//   console.log('>>> fetch is mocked >>>')
// }
