defmodule GithubApprover.Entities.Issue do
  def create(issue_url) do
    [_, project, id] = Regex.run(~r/https:\/\/api.github.com\/repos\/+(.*\/.*)+\/issues\/+([0-9]*)/, issue_url)

    issue = %{ 
      "project" => project,
      "id"      => id
    }

    issue_info = Github.issue_info(issue)
    issue = Map.put(issue, "user", issue_info["user"])
    issue = Map.put(issue, "title", issue_info["title"])
    Map.put(issue, "body", issue_info["body"])
  end
end
