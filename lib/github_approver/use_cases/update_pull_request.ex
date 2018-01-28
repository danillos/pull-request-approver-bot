defmodule GithubApprover.UseCases.UpdatePullRequest do

  def call(%{ "pull_request" => pull_request } = params) do
    :timer.sleep(400)

    issue = GithubApprover.Entities.Issue.create(pull_request["issue_url"])

    case params do
       %{"action" => "review_requested"       } -> GithubApprover.Services.UpdateIssueLabels.call(issue)
       %{"action" => "review_request_removed" } -> GithubApprover.Services.UpdateIssueLabels.call(issue)
       %{"action" => _, "review" => _         } -> GithubApprover.Services.UpdateIssueLabels.call(issue)
       _                                        -> IO.write "Event not implemented #{params["action"]}"
    end
  end

  def call(params) do
    IO.write "Event not implemented #{params["action"]}"
  end
end
