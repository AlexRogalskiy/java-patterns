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
import path from "path"
import puppeteer from "puppeteer"

/**
 * Create a screenshot from an HTML file and save it as image.
 * @param filePath Path of an HTML file
 * @param fileName Name of the output image
 */
export const createScreenshot = async (filePath: string, fileName: string) => {
  try {
    const htmlFilePath = path.join('file:', filePath)
    const browser = await puppeteer.launch()
    const page = await browser.newPage()
    await page.setViewport({
      height: 10,
      width: 1000,
    })

    await page.goto(htmlFilePath)

    await page.screenshot({
      path: `${process.env.IMAGE_DIR}/${fileName}.png`,
      omitBackground: true,
      fullPage: true,
    })

    await browser.close()
  } catch (error) {
    console.error(error)
    throw Error('Could not create screenshot for a preview')
  }
}
