defmodule GithubApprover.Entities.Issue do
  def create(issue_url) do
    [_, project, id] = Regex.run(~r/https:\/\/api.github.com\/repos\/+(.*\/.*)+\/issues\/+([0-9]*)/, issue_url)
    %{ 
      "project" => project,
      "id"      => id
    }
  end
end
