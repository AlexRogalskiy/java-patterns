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
import sleep from "await-sleep"
import expect from "expect"

describe('Test Suite', () => {
  beforeAll(async () => {
    console.log('Waiting for 1 sec')

    await sleep(1000)

    console.log("Test Suite: >>> before all")
  })

  afterAll(async () => {
    console.log("Test Suite: >>> after all")
  })

  test.only('one of my .only test', () => {
    expect(1 + 1).toEqual(2)
  })
  test.only('other of my .only test', () => {
    expect(1 + 2).toEqual(3)
  })
  // Should fail, but isn't even run
  test('my only true test', () => {
    expect(1 + 1).toEqual(1)
  })
})
