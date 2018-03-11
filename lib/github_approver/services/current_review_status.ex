defmodule GithubApprover.Services.CurrentReviewStatus do
  @app_labels Application.get_env(:github_approver, :labels)

  def call(issue, min_required_reviews, review_status) do
    cond do
      in_progress?(issue)                               -> "in_progress"
      review_status[:changes_requesteds] > 0            -> "changes_requested"
      review_status[:pendings] > 0                      -> "pending"
      review_status[:approveds] >= min_required_reviews -> "approved"
      true                                              -> nil
    end
  end

  defp in_progress?(issue) do
    Github.label_exist?(issue, @app_labels["in_progress"])
  end
end
