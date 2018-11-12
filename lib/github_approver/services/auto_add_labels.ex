defmodule GithubApprover.Services.AutoAddLabels do
  def call(issue) do
    if issue_description_contains?(issue, "rake") do
      Github.add_label_to_issue(issue, "rake")
    else
      Github.remove_label_from_issue(issue, "rake")
    end
  end

  defp issue_description_contains?(issue, text) do
     String.contains?(issue["title"], text) || String.contains?(issue["body"], text)
  end
end
