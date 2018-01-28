defmodule GithubApprover.Services.ReviewStatus do
  @app_labels Application.get_env(:github_approver, :labels)

  def call(issue, min_required_reviews) do
    reviews = current_reviews(issue)

    total_approved          = count_value_in_list(reviews, "APPROVED")
    total_changes_requested = count_value_in_list(reviews, "CHANGES_REQUESTED")
    total_pending           = count_value_in_list(reviews, "PENDING")

    IO.inspect "approved: #{total_approved}"
    IO.inspect "changes: #{total_changes_requested}"
    IO.inspect "requested: #{total_pending}"

    cond do
      in_progress?(issue)                    -> "in_progress"
      total_changes_requested > 0            -> "changes_requested"
      total_pending > 0                      -> "pending"
      total_approved >= min_required_reviews -> "approved"
      total_approved != 0                    -> "pending"
      true                                   -> nil
    end
  end

  defp current_reviews(issue) do
    requested_reviewers = Github.requested_reviewers_for_issue(issue)["users"]
    |> Enum.map(fn(r) -> r["login"] end)

    last_reviews = Github.last_reviews_by_user_for_issue(issue)
    |> Enum.filter(fn(x) -> !Enum.member?(requested_reviewers, x["user"]["login"]) end)
    |> Enum.map(fn(x) -> x["state"] end)

    requested_reviewers
    |> Enum.map(fn(_r) -> "PENDING" end)
    |> Enum.concat(last_reviews)
  end

  defp in_progress?(issue) do
    Github.label_exist?(issue, @app_labels["in_progress"])
  end

  defp count_value_in_list(list, value) do
    count_words = fn({k, v}, acc) ->
      Map.put(acc, k, Enum.count(v))
    end

    result = list
    |> Enum.group_by(fn(w) -> w end)
    |> Enum.reduce(%{}, count_words)

    if result[value] == nil do
      0
    else
      result[value]
    end
  end
end
