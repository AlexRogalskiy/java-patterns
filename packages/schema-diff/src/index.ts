import {createReadStream, promises as fs} from "fs";
import path from "path";
import {createHash} from "crypto";
import {spawn} from "child_process";

const schemaV1Path = path.join(process.cwd(), `${process.env.SOURCE_DIR1}`)
const schemaV2Path = path.join(process.cwd(), `${process.env.SOURCE_DIR2}`)

const baseV1Name = path.basename(schemaV1Path)
const baseV2Name = path.basename(schemaV2Path)

/** Represents the git status of a file */
enum FileStatus {
  Deleted = "deleted",
  Modified = "modified",
  Added = "added",
  Renamed = "renamed",
  Unknown = "unknown",
}

type DeltaFileMap = { [filePath: string]: FileStatus }

/**
 * Converts git status short codes to their `FileStatus` equivalent.
 * @param change Single character shorthand git file state
 */
const GitChangeToFileStatus = (change: string) => {
  switch (change) {
    case "M":
      return FileStatus.Modified
    case "A":
      return FileStatus.Added
    case "D":
      return FileStatus.Deleted
    case "R":
      return FileStatus.Renamed
    default:
      return FileStatus.Unknown
  }
}

interface BranchState {
  commitsAhead: number
  commitsBehind: number
}

/**
 * Gives status information on the current branch as compared to origin/master
 */
const getBranchDrift = (): Promise<BranchState> =>
  new Promise((resolve, reject) => {
    let output = ""
    const delta = spawn("git", [
      "rev-list",
      "--left-right",
      "--count",
      "origin/master...HEAD",
    ])

    delta.stdout.on("data", (data) => {
      output += data
    })

    delta.on("close", (code) => {
      if (code !== 0) {
        reject("Failed to get branch drift")
      } else {
        const commitChanges = output.match(/(\d+)\s+(\d+)/)
        if (!commitChanges) {
          reject("Something was wrong with the branch drift output")
        }

        let [, commitsBehind, commitsAhead] = Array.from(
          commitChanges!
        ).map((x) => Number(x))
        resolve({
          commitsAhead,
          commitsBehind,
        })
      }
    })
  })

/**
 * Uses git to generate a delta map of files that have changed since master
 */
const getChangedFiles = (): Promise<DeltaFileMap> =>
  new Promise((resolve, reject) => {
    let changedBlob = ""
    const changed = spawn("git", ["diff", "--name-status", "--relative", "origin/master"])
    changed.stdout.on("data", (data) => {
      changedBlob += data
    })

    changed.on("close", (code) => {
      if (code !== 0) {
        reject("Failed to find changed files via git")
      } else {
        resolve(
          changedBlob
            .split("\n")
            .map((status) => {
              const match = status.match(/([A-Z])\s+(.+)/)
              if (match) {
                const [, status, filePath] = match
                return {
                  [path.resolve(filePath)]: GitChangeToFileStatus(status),
                }
              }
              return {} as any
            })
            .reduce((a, b) => ({...a, ...b}), {})
        )
      }
    })
  })

/**
 * Determines if a given path is a directory
 * @param filepath
 */
const isDirectory = async (filepath: string): Promise<boolean> =>
  (await fs.lstat(filepath)).isDirectory()

/**
 * Asynchronously generates an md5 of a file
 * @param filePath The full path to a file (include its name)
 */
const hashFile = (filePath: string): Promise<string> =>
  new Promise((resolve, reject) => {
    const stream = createReadStream(filePath)
    const hash = createHash("md5")

    stream.on("data", (data: string) => hash.update(data, "utf8"))
    stream.on("end", () => {
      resolve(hash.digest("hex"))
    })
    stream.on("error", (error) => {
      reject(error)
    })
  })

type FSNode = File | Directory
type FileMap = { [path: string]: File }

class File {
  name: string
  path: string
  fullPath: string
  relativePath: string
  hash: string

  private constructor(fullPath: string, hash: string) {
    this.name = path.basename(fullPath)
    this.path = path.dirname(fullPath)
    this.fullPath = fullPath
    this.relativePath = path.relative(process.cwd(), fullPath)
    this.hash = hash
  }

  static async create(fullPath: string) {
    return new File(fullPath, await hashFile(fullPath))
  }
}

class Directory {
  name: string
  path: string
  fullPath: string
  nodes: Array<File | Directory>
  fileMap: { [path: string]: File }

  private constructor(fullPath: string, nodes: FSNode[], fileMap: FileMap) {
    this.name = path.basename(fullPath)
    this.path = path.dirname(fullPath)
    this.fullPath = fullPath
    this.nodes = nodes
    this.fileMap = fileMap
  }

  static async create(fullPath: string, _deltaFileMap: DeltaFileMap = {}) {
    const [children, childMap] = await this.getChildren(fullPath)
    return new Directory(fullPath, children, childMap)
  }

  private static async getChildren(fullPath): Promise<[FSNode[], FileMap]> {
    const nodes: FSNode[] = []
    const fileNames = await fs.readdir(fullPath)
    let fileMap: FileMap = {}

    for (let fileName of fileNames) {
      const currentPath = path.join(fullPath, fileName)
      if (await isDirectory(currentPath)) {
        let dir = await Directory.create(currentPath)
        nodes.push(dir)
        fileMap = {...fileMap, ...dir.fileMap}
      } else {
        let file = await File.create(currentPath)
        nodes.push(file)
        fileMap[file.fullPath] = file
      }
    }
    return [nodes, fileMap]
  }

  /**
   * Calls a callback for every file of this directory and its sub directories
   */
  public walk(callback: (File) => void) {
    for (let child of this.nodes) {
      if (child instanceof Directory) {
        child.walk(callback)
      } else {
        callback(child)
      }
    }
  }

  public hasFile(fullPath: string) {
    !!this.fileMap[fullPath]
  }

  public getFile(fullPath: string): File {
    return this.fileMap[fullPath]
  }

  public listFiles(): string[] {
    return Object.keys(this.fileMap)
  }
}

const isFromSchemaV1 = (filePath: string) => filePath.includes(baseV1Name)

/** Convert an absolute file path to a partial path that starts after `/v1/` or `/v2/` */
const fromSchemaRoot = (filePath: string) =>
  isFromSchemaV1(filePath)
    ? filePath.split(baseV1Name)[1]
    : filePath.split(baseV2Name)[1]

/** Updates a path from `/v1/` to `/v2/` or vice versa */
const switchSchemaPath = (filePath: string) =>
  isFromSchemaV1(filePath)
    ? filePath.replace(baseV1Name, baseV2Name)
    : filePath.replace(baseV2Name, baseV1Name)

/**
 * @param directory1
 * @param directory2
 * @param directoryMapper Used to establish a common path between files of the two directories
 */
const diffDirectories = (
    directory1: Directory,
    directory2: Directory,
    directoryMapper = (p) => p
  ): [string[], string[], string[]] => {
    const fileList1 = directory1.listFiles().map(directoryMapper)
    const fileList2 = directory2.listFiles().map(directoryMapper)

    const sharedFiles = fileList1.filter((x) => fileList2.includes(x))
    const filesUniqueTo1 = fileList1.filter((x) => !sharedFiles.includes(x))
    const filesUniqueTo2 = fileList2.filter((x) => !sharedFiles.includes(x))

    return [filesUniqueTo1, sharedFiles, filesUniqueTo2]
  }

// Main work
;(async () => {
  const branchState = await getBranchDrift()

  // Is there a better way to handle this?
  if (branchState.commitsBehind > 0) {
    console.warn("Branch is currently behind master, might not reflect accurate state\n")
  }

  const fileChanges = Object.entries(await getChangedFiles()).filter(
    ([file]) => file.includes(baseV1Name) || file.includes(baseV2Name)
  )

  // If no file updates, skip
  if (fileChanges.length === 0) {
    console.log(`No updates detected in [${baseV1Name}] or [${baseV2Name}], skipping...\n`)
    return
  }

  // Read files from the FS
  const schemaV1 = await Directory.create(schemaV1Path)
  const schemaV2 = await Directory.create(schemaV2Path)

  // Sort out which files are shared by v1 and v2
  const [
    filesUniqueToSchemaV1,
    filesInBothSchemas,
    // filesUniqueToSchemaV2,
  ] = diffDirectories(schemaV1, schemaV2, fromSchemaRoot)

  const unknownChanges = fileChanges
    .filter(([, status]) => status === FileStatus.Unknown)
    .map(([file]) => file)

  const modifiedFiles = fileChanges
    .filter(([, status]) => status === FileStatus.Modified)
    .map(([file]) => file)

  const addedFiles = fileChanges
    .filter(([, status]) => status === FileStatus.Added)
    .map(([file]) => file)

  // const deletedFiles = fileChanges
  //   .filter(([, status]) => status === FileStatus.Deleted)
  //   .map(([file]) => file)

  // const renamedFiles = fileChanges
  //   .filter(([, status]) => status === FileStatus.Renamed)
  //   .map(([file]) => file)

  if (unknownChanges.length > 0) {
    console.warn(
      "File changes detect with unknown git status, please verify the following and update the schema drift script\n" +
      unknownChanges.map((file) => `- ${file}\n`)
    )
  }

  // Scenarios
  //
  // For files that exist in both places

  // File A was modified in (v1|v2), should it also be modified in (v2|v1)?
  modifiedFiles
    .map((filePath) => [fromSchemaRoot(filePath), filePath])
    .filter(([file]) => filesInBothSchemas.includes(file))
    .forEach(([, filePath]) => {
      if (isFromSchemaV1(filePath)) {
        const schemaV1File = schemaV1.getFile(filePath)
        const schemaV2File = schemaV2.getFile(switchSchemaPath(filePath))

        // Both files are the same now, nothing to do here
        if (schemaV1File.hash === schemaV2File.hash) return

        console.warn(
          `${schemaV1File.relativePath} has been modified, should this update also happen in ${schemaV2File.relativePath}?`
        )
      } else {
        const schemaV2File = schemaV2.getFile(filePath)
        const schemaV1File = schemaV1.getFile(switchSchemaPath(filePath))

        // The files are the same, skip
        if (schemaV2File.hash === schemaV1File.hash) return

        console.warn(
          `${schemaV2File.relativePath} has been modified, should this update also happen in ${schemaV1File.relativePath}?`
        )
      }
    })

  // For files added during transition

  // File was added to v1, should it also exist in v2?
  addedFiles
    .map((filePath) => [fromSchemaRoot(filePath), filePath])
    .filter(([file]) => filesUniqueToSchemaV1.includes(file))
    .forEach(([, filePath]) => {
      const file = schemaV1.getFile(filePath)
      console.warn(
        `\n\n[${file.relativePath}] was added to v1, should it also be added to v2\n\n`
      )
    })

  // For updates in v1 that don't match to V2

  // An update was made to a file in v1, but it doesn't exist in V2. Double
  // check that there aren't updates required.
  modifiedFiles
    .map((filePath) => [fromSchemaRoot(filePath), filePath])
    .filter(([file]) => filesUniqueToSchemaV1.includes(file))
    .forEach(([, filePath]) => {
      const file = schemaV1.getFile(filePath)
      console.warn(
        `${file.relativePath} was modified in v1, but doesn't exist in v2. Ensure no v2 changes are required.`
      )
    })
})()
