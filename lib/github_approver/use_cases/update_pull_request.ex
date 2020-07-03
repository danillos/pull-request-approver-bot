defmodule GithubApprover.UseCases.UpdatePullRequest do

  def call(%{ "pull_request" => pull_request } = params) do
    trigger_delay = params["trigger_delay"] || Application.get_env(:github_approver, :trigger_delay)
    :timer.sleep(trigger_delay)

    min_required_reviews = min_required_reviews(params)

    issue = GithubApprover.Entities.Issue.create(pull_request["issue_url"])

    case params do
       %{ "action" => "opened"                 } -> run_when_pr_is_opened(issue, min_required_reviews)
       %{ "action" => "edited"                 } -> GithubApprover.Services.AutoAddLabels.call(issue)
       %{ "action" => "review_requested"       } -> GithubApprover.Services.UpdateReviewStatus.call(issue, min_required_reviews)
       %{ "action" => "dismissed"              } -> GithubApprover.Services.UpdateReviewStatus.call(issue, min_required_reviews)
       %{ "action" => "review_request_removed" } -> GithubApprover.Services.UpdateReviewStatus.call(issue, min_required_reviews)
       %{ "action" => "ready_for_review"       } -> GithubApprover.Services.ReadyForReview.call(issue)
       %{ "action" => "converted_to_draft"     } -> GithubApprover.Services.ConvertedToDraft.call(issue)
       %{ "action" => _, "review" => _         } -> GithubApprover.Services.UpdateReviewStatus.call(issue, min_required_reviews)
       _                                         -> IO.write "Event not implemented #{params["action"]}"
    end
  end

  def call(params) do
    IO.write "Event not implemented #{params["action"]}"
  end

  defp run_when_pr_is_opened(issue, min_required_reviews) do
    GithubApprover.Services.AutoAddLabels.call(issue)
    GithubApprover.Services.UpdateReviewStatus.call(issue, min_required_reviews)
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
