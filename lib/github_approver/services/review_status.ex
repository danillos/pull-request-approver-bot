defmodule GithubApprover.Services.ReviewStatus do

  def call(issue) do
    reviews = reviews(issue)

    %{
      :approveds          => count_value_in_list(reviews, "APPROVED"), 
      :changes_requesteds => count_value_in_list(reviews, "CHANGES_REQUESTED"),
      :pendings           => count_value_in_list(reviews, "PENDING"),
      :comments           => count_value_in_list(reviews, "COMMENTED")
    }
  end

  defp reviews(issue) do
    requested_reviewers = Github.requested_reviewers_for_issue(issue)["users"]
    |> Enum.map(fn(r) -> r["login"] end)

    last_reviews = Github.last_reviews_by_user_for_issue(issue)
    |> Enum.filter(fn(x) -> !Enum.member?(requested_reviewers, x["user"]["login"]) end)
    |> Enum.map(fn(x) -> x["state"] end)

    requested_reviewers
    |> Enum.map(fn(_r) -> "PENDING" end)
    |> Enum.concat(last_reviews)
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
