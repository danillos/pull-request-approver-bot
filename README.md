# GithubApprover

Automatically add labels in Pull Requests when is needed to review or when is approved

## Installation

### Enviroment Variables

- GITHUB_ACCESS_TOKEN 
- MIX_ENV
- PORT

### Running

```
MIX_ENV=prod mix compile

and

MIX_ENV=prod PORT=80 mix run --no-halt
or
MIX_ENV=prod PORT=80 elixir --detached -S mix run --no-halt
```
