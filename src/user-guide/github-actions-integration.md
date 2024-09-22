# Integrating Treadmill with GitHub Actions

By integrating Treadmill into your GitHub Actions workflows you can
automatically test your code on real hardware while retaing the convenience of
GitHub Action's reusable actions snippets, declarative configuration, and
integration with GitHub repositories. This guide describes how to

- wire up your repository such that it can automatically launch Treadmill jobs
  for some Actions CI workflow,
- attach a GitHub actions runner on the Treadmill host to your repository, and
- define a Workflow that launches a set of Treadmill jobs to test different
  parts of your code on a set of different hardware boards.

## Just-in-time GitHub Actions Runners

GitHub Actions jobs usually execute on _hosted runners_ provided by
GitHub. These runners can be selected by using the appropriate
[`runs-on`](https://docs.github.com/en/actions/writing-workflows/workflow-syntax-for-github-actions#jobsjob_idruns-on)
selector, for instance by specifying a label such as `ubuntu-latest`. However,
these runners do not have access to hardware targets.

In contrast, a Treadmill job provides access to an ephemeral
[host](../introduction/terminology.md#host) environment, running a user-supplied
[image](../introduction/terminology.md#image), which itself has access to a
hardware target. This host can be used for interactive sessions or, when
supplied with an appropriate image, automatically execute some software on
startup.

We can use this abstraction that Treadmill provides to run a [GitHub Actions
self-hosted
runner](https://docs.github.com/en/actions/hosting-your-own-runners/managing-self-hosted-runners/about-self-hosted-runners). This
software provides the ability to execute regular GitHub actions workflows on a
user-supplied compute resource instead of a GitHub-provided hosted
runner. However, typically these runners execute workflows on this machine
without strong isolation (without a container or VM) and are long-lived: once
registered, they are able to run multiple workflows up to the point they are
deregistered. We must ensure that workflows cannot accidentally or maliciously
influence future workflow runs, and run GitHub workflows on exactly the
Treadmill host they are supposed to execute on.

Treadmill's ephemeral job environments can alleviate the first concern:
Treadmill jobs always run from a clean, ephemeral image and thus provide a
reasonable degree of isolation between jobs. We can ensure the second property
using GitHub's concept of [_just-in-time
runners_](https://github.blog/changelog/2023-06-02-github-actions-just-in-time-self-hosted-runners/):
these Actions runners can be registered using a single-use token and are able to
execute exactly one job. This ensures that each GitHub actions workflow runs in
a fresh Treadmill job environment, and this job is only able to execute exactly
one workflow.

## Automatically Launching a Treadmill Job & GitHub Actions Runner

Treadmill does not have a native GitHub actions integration. Instead, we can use
a small Actions workflow job running on a GitHub hosted runner (called
`test-prepare`) to prepare a new Treadmill job and register it as a self-hosted
runner, to then launch actual test workloads (called `test-execute`) on this
runner in a second step.

We start by defining a workflow file in our repository that runs a job called
`treadmill-ci`, under `.github/workflows/treadmill-ci.yml`. This `test-prepare`
workflow will first compile the Treadmill CLI client and proceed to log into the
Treadmill testbed.

```yaml
name: treadmill-ci

# You can customize these triggers to your preference:
on:
  pull_request: # Run CI for PRs on any branch
  merge_group: # Run CI for the GitHub merge queue

jobs:
  test-prepare:
    # Run this first step on GitHub's hosted infrastructure
    runs-on: ubuntu-latest

    steps:
	  # Required to compile the Treadmill CLI client:
      - uses: actions-rust-lang/setup-rust-toolchain@v1

      # Fetch the source of the Treadmill CLI client. We do not yet provide
	  # pre-compiled binaries:
      - name: Checkout Treadmill repository
        uses: actions/checkout@v4
        with:
          repository: treadmill-tb/treadmill
          path: treadmill

      # This greatly speeds up future workflow runs:
      - name: Cache Treadmill CLI compilation artifacts
        id: cache-tml-cli
        uses: actions/cache@v4
        with:
          path: treadmill/target
          key: ${{ runner.os }}-tml-cli

      - name: Compile the Treadmill CLI binary
        run: |
          pushd treadmill
          cargo build --package tml-cli
          popd
          echo "$PWD/treadmill/target/debug" >> "$GITHUB_PATH"

      # Replace $YOUR_TREADMILL_USER with your desired credentials:
      - name: Login to the Treadmill Switchboard
        run:
          tml login $YOUR_TREADMILL_USER ${{ secrets.TREADMILL_LOGIN_PASSWORD }}
```

<div class="warning"> We plan to provide pre-compiled CLI binaries, a GitHub
workflow template, and the ability to use long-lived tokens instead of a
username-password login for workflows in the future.</div>

To allow the workflow to talk to the Treadmill switchboard, you should create a
dedicated user for launching CI workloads and save its password in a
[GitHub](https://docs.github.com/en/actions/security-for-github-actions/security-guides/using-secrets-in-github-actions).

### Registering a Just-in-time GitHub Actions Runner

Next, we need to create a registration token for the just-in-time GitHub actions
runner that will run on a Treadmill host. Unfortunately, GitHub does not provide
an easy way to do this from within a GitHub action. Notably, the GitHub API
token that is provided to GitHub Actions workflows by default *does not* have
the required capabilities to create new just-in-time GitHub Actions
runners. Instead, we have to first create a GitHub App with the required
permissions and use it's API token to register the runner.

To create a new GitHub App, navigate to your `Organization Settings` →
`Developer Settings` → `GitHub Apps`. Here, you are able to create a new
application like the following. You can leave most fields blank, as we're not
actually using any of the app's features apart from its API token: !["Register a
new GitHub App" form, with the "GitHub App name" set to "Treadmill GH Actions
CI", the description set to "This app is used solely to create GitHub tokens
with privileges to create ephemeral, just-in-time GitHub Actions runners." and
the "Homepage URL" field set to
"https://your-project.org"](./github-actions-integration/create-app.png
"Register a new GitHub App form")

Disable `Webhook` → `Active` and leave the `Webhook URL` and `Secret`
empty. Under `Permissions`, the app requires only the `Repository permissions` →
`Administration` to be set to `Access: Read and write`. Set `Where can this
GitHub App be installed` → `Only on this account`.

With the app created, you should be presented with its settings page. We do not
need to generate a client secret for the app. Instead, scroll down until you see
the `Private keys` section and click `Generate a private key`: !["Private keys"
section of the GitHub App settings, showing a large blue button labeled
"Generate a private key"](./github-actions-integration/generate-private-key.png
"Generate a private key GitHub App settings form") Your browser should download
a `.pem` file after a short while: ![Firefox Downloads menu showing a
`tock-treadmill-gh-actions-ci.2024-09-20.private-key.pem`
file](./github-actions-integration/private-key-download.png "GitHub App private
key download")

We need to make this private key accessible to the GitHub Actions workflow. For
this, navigate to your repository's `Settings` (not the organization settings) →
`Secrets and variables` → `Actions`. Create a new Actions variable called
`TREADMILL_GH_APP_CLIENT_ID` and set its contents to your application's client
ID (from its settings page). Create a new Actions secret called
`TREADMILL_GH_APP_PRIVATE_KEY` and copy the contents of the downloaded `.pem`
file into the secret: !["Actions secrets / New secret" form, with the "Name"
field set to `TREADMILL_GH_APP_PRIVATE_KEY` and the "Secret" field set to the
contents of the downloaded file, starting with `-----BEGIN RSA PRIVATE
KEY-----`](./github-actions-integration/app-private-key-secret.png "GitHub App
private key download")

Finally, we need to install this application into the target repository. For
this, navigate to your application settings (under `Organization Settings` →
`Developer Settings` → `GitHub Apps` → _your application name_ → `Edit`), select
`Install App`, and click `Install` next to your organization. You can choose to
only install the app for one repository as shown below: !["Install Tock
Treadmill GH Actions CI" screen, with "Only select repositories" selected, and
the `tock/tock` repository being selected as one of the repositories for which
the app should be installed](./github-actions-integration/install-app.png
"GitHub App installation")

With the app ready, we can extend the GitHub actions workflow to obtain an API
token that is able to create new just-in-time runners from within our workflow:

```yaml
      - name: Generate a token to register new just-in-time runners
        id: generate-token
        uses: actions/create-github-app-token@v1
        with:
          app-id: ${{ vars.TREADMILL_GH_APP_CLIENT_ID }}
          private-key: ${{ secrets.TREADMILL_GH_APP_PRIVATE_KEY }}
          owner: ${{ github.repository_owner }}
```

Finally, we can create a new just-in-time runner in a subsequent step:
```yaml
      - name: Create GitHub just-in-time runner
        id: gh-actions-jit-runner-config
        env:
          GH_TOKEN: ${{ steps.generate-token.outputs.token }}
        run: |
		  # Perform the API request to register the just-in-time runner.
          RUNNER_CONFIG_JSON="$(gh api \
            -H "Accept: application/vnd.github+json" \
            -H "X-GitHub-Api-Version: 2022-11-28" \
            /repos/$YOUR_ORG/$YOUR_REPO/actions/runners/generate-jitconfig \
            -f "name=treadmill-runner" \
            -F "runner_group_id=1" \
            -f "labels[]=treadmill-runner" \
            -f "work_folder=_work")"

		  # The above returns a JSON object containing a base64-encoded
		  # "jit config". We need to retain this value for starting the runner.
		  # Provide it to subsequent steps as an output:
		  echo "jitconfig=$(echo "$RUNNER_CONFIG_JSON" | jq -r '.encoded_jit_config')"
```

Next, we'll pass this value into the Treadmill job's parameters and start a job
that launches a GitHub actions runner on boot.

## Launching a Treadmill Job

To write
