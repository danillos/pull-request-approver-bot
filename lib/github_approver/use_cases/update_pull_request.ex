defmodule GithubApprover.UseCases.UpdatePullRequest do
  
  def call(%{ "pull_request" => pull_request } = params) do
    :timer.sleep(params["trigger_delay"] || Application.get_env(:github_approver, :trigger_delay))

    min_required_reviews = min_required_reviews(params)

    issue = GithubApprover.Entities.Issue.create(pull_request["issue_url"])

    case params do
       %{"action" => "review_requested"}        -> GithubApprover.Services.UpdateIssueLabels.call(issue, min_required_reviews)
       %{"action" => "dismissed" }              -> GithubApprover.Services.UpdateIssueLabels.call(issue, min_required_reviews)
       %{"action" => "review_request_removed" } -> GithubApprover.Services.UpdateIssueLabels.call(issue, min_required_reviews)
       %{"action" => _, "review" => _}          -> GithubApprover.Services.UpdateIssueLabels.call(issue, min_required_reviews)
       _                                        -> IO.write "Event not implemented #{params["action"]}"
    end
  end

  def call(params) do
    IO.write "Event not implemented #{params["action"]}"
  end

  defp min_required_reviews(params) do
    min_required_reviews = params["min_required_reviews"] || Application.get_env(:github_approver, :min_required_reviews)

    if is_bitstring(min_required_reviews) do
      String.to_integer(min_required_reviews)
    else
      min_required_reviews
    end
  end
end
