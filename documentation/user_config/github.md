# GitHub configuration

The user config can contain GitHub credentials if you need to reference a private repository. The only element supported is a GitHub access token:

```json
{
  "credentials": {
      "git": {
          "username": "my personal access token value"
      }
  }
}
```

## Setup a Git personal access token

To create a Git personal access token, follow the steps below:

* Open your GitHub repository in your browser, and login with your GitHub username/password
* Go to `Settings` under your profile (top right corner)
* Go to `Developer Settings`
* Select `Personal access tokens`
* Click `Generate new token`
* In the `note` field enter the name to look up the token.
* Select `repo` for the scope and give `Full control of private repositories`
* Click `Generate token` (near the bottom of the page)
* On the next screen, copy the value of the generated token. This is your only chance to get that value, and save it in a safe place. This value typically goes in the user config file for your GitHub `username`

## Usage

The deployer can clone private repositories using a GitHub access token. Typically, a deploy config has an element `source_repository`:

```json
  "source_repository": "-b main https://github.com/newrelic/demo-nodetron.git",
```

The field `[credential:git:username]` is used at runtime by the Deployer to pull the GitHub access token value from the user config file with a json path query `/credentials/git/username`.

More documentation and screenshots are available from [GitHub](https://docs.github.com/en/github/authenticating-to-github/creating-a-personal-access-token).