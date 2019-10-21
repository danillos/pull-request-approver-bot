defmodule GithubApprover.Entities.Issue do
  def create(issue_url) do
    [_, project, id] = Regex.run(~r/https:\/\/api.github.com\/repos\/+(.*\/.*)+\/issues\/+([0-9]*)/, issue_url)

    issue = %{ 
      "project" => project,
      "id"      => id
    }

    pull_request = Github.pull_request(issue)

    issue = Map.put(issue, "user", pull_request["user"])
    issue = Map.put(issue, "title", pull_request["title"])
    issue = Map.put(issue, "is_draft", pull_request["draft"])
    issue = Map.put(issue, "body", pull_request["body"])

    issue
  end
end