defmodule GithubApprover.Services.UpdateIssueLabels do
  @app_labels Application.get_env(:github_approver, :labels)

  def call(issue, min_required_reviews) do
  	review_status = GithubApprover.Services.ReviewStatus.call(issue, min_required_reviews)

  	case review_status do
       "pending"           -> change_to_pending(issue)
       "changes_requested" -> change_to_changes_requested(issue)
       "approved"          -> change_to_approved(issue)
       _ = status          -> IO.write "No action for status: #{status}"
    end
  end

  defp change_to_pending(issue) do
    Github.add_label_to_issue(issue, @app_labels["pending"])
    Github.remove_label_from_issue(issue, @app_labels["changes_requested"])
    Github.remove_label_from_issue(issue, @app_labels["approved"])
  end

  defp change_to_changes_requested(issue) do
    Github.add_label_to_issue(issue, @app_labels["changes_requested"])
    Github.remove_label_from_issue(issue, @app_labels["pending"])
    Github.remove_label_from_issue(issue, @app_labels["approved"])
  end

  defp change_to_approved(issue) do
    Github.add_label_to_issue(issue, @app_labels["approved"])
    Github.remove_label_from_issue(issue, @app_labels["pending"])
    Github.remove_label_from_issue(issue, @app_labels["changes_requested"])
  end
end
