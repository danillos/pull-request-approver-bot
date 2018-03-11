defmodule GithubApprover.Entities.Issue do
  def create(issue_url) do
    [_, project, id] = Regex.run(~r/https:\/\/api.github.com\/repos\/+(.*\/.*)+\/issues\/+([0-9]*)/, issue_url)

    issue = %{ 
      "project" => project,
      "id"      => id
    }

    issue_info = Github.issue_info(issue)
    
    Map.put(issue, "user", issue_info["user"])
  end
end
