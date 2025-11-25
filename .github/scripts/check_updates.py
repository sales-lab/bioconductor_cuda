import os
import subprocess
import sys


def fatal(msg: str, rc: int = 1) -> None:
    print(f"❌ {msg}", file=sys.stderr)
    sys.exit(rc)


sha = os.getenv("GITHUB_SHA")
if not sha:
    fatal("GITHUB_SHA is not set.")

gh_output = os.getenv("GITHUB_OUTPUT")
if not gh_output:
    fatal("GITHUB_OUTPUT not defined.")

docker_cmd = [
    "docker",
    "container",
    "run",
    "--rm",
    "--entrypoint",
    "/bin/bash",
    f"temp-builder:{sha}",
    "-c",
    """\
    if ! apt-get update -q >/dev/null 2>&1; then
      echo 'apt-get update failed' >&2
      exit 1
    fi
    if ! apt-get -s upgrade | awk '/^Inst/{c++} END{print c+0}'; then
      echo 'apt-get upgrade failed' >&2
      exit 1
    fi
    """,
]

try:
    result = subprocess.run(
        docker_cmd,
        capture_output=True,
        text=True,
    )
except FileNotFoundError:
    fatal("Docker binary not found.")

if result.returncode != 0:
    fatal("Docker container reported an error.\n" + result.stderr)

raw = result.stdout.strip()
try:
    update_count = int(raw)
except ValueError:
    fatal(f"Unexpected output from container: {raw!r}")

print(f"Packages to upgrade: {update_count}")

needs_update = "true" if update_count > 0 else "false"
with open(gh_output, "a", encoding="utf-8") as f:
    f.write(f"needs_update={needs_update}\n")
