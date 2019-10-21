defmodule GithubApprover.Services.ReadyForReview do
  @app_labels Application.get_env(:github_approver, :labels)
  
  def call(issue) do
    Github.add_label_to_issue(issue, @app_labels["pending"])
    Github.remove_label_from_issue(issue, @app_labels["in_progress"])
  end
end