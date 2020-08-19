# Git configuration

The user config can contain a Git credential. The only element supported is a Git access token. The format is the following:

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

* Open https://source.datanerd.us/Demotron/V3-Deployer in your browser, and login with your Git username/password
* Go to `Settings` under your profile (top right corner)
* Go to `Developer Settings`
* Select `Personal access tokens`
* Click `Generate new token`
* In the `note` field enter the name to look up the token. 
* Select `repo` for the scope and give `Full control of private repositories`
* Click `Generate token` (near the bottom of the page)
* On the next screen, copy the value of the generated token. This is your only chance to get that value, and save it in a safe place. This value typically goes in the user config file for your git `username`

## Usage

The V3 repositories can be cloned by the Deployer using a Git access token. This is the recommended way for using the Deployer with docker.
Typically a deploy config would have an element `source_repository` looking like this:
```json
  "source_repository": "-b master git@github.com:newrelic/demo-nodetron.git",
```

The field `[credential:git:username]` is used at runtime by the Deployer to pull the Git access token value from the user config file with a json path query `/credentials/git/username`.

More documentation and screenshot are available from  Git at https://docs.github.com/en/github/authenticating-to-github/creating-a-personal-access-token
