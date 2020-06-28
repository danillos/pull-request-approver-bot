defmodule GithubApprover.Services.ConvertedToDraft do
  @app_labels Application.get_env(:github_approver, :labels)

  def call(issue) do
    change_to_in_progress(issue, Github)
  end

  def change_to_in_progress(issue, github_client) do
    github_client.add_label_to_issue(issue, @app_labels["in_progress"])
    github_client.remove_label_from_issue(issue, @app_labels["pending"])
    github_client.remove_label_from_issue(issue, @app_labels["changes_requested"])
    github_client.remove_label_from_issue(issue, @app_labels["approved"])
  end
end