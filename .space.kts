job("Warmup - WebStorm") {
  git {
    depth = UNLIMITED_DEPTH
    refSpec = "refs/*:refs/*"
  }

  startOn {
    schedule { cron("0 0 * * *") }

    gitPush {
      enabled = true

      branchFilter {
        +"refs/heads/main"
      }
    }
  }

  warmup(ide = Ide.WebStorm) {
    devfile = ".space/webstorm.devfile.yml"
    scriptLocation = ".space/dev-env-warmup.sh"
  }
}
