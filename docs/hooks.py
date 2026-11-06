import shutil


def copy_generated_files(*args, **kwargs):
    shutil.copy("README.md", "docs/README.md")
    shutil.copy("CONTRIBUTING.md", "docs/CONTRIBUTING.md")

if __name__ == "__main__":
    copy_generated_files()
