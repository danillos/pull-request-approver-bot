defmodule GithubApprover.UseCases.UpdatePullRequest do

  def call(%{ "pull_request" => pull_request, "min_required_reviews" => min_required_reviews } = params) do
    :timer.sleep(400)

    min_required_reviews = String.to_integer(min_required_reviews)
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
end
