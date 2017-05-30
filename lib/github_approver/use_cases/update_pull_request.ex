defmodule GithubApprover.UseCases.UpdatePullRequest do
  @required_approves Application.get_env(:github_approver, :required_approves)

  def call(%{ "pull_request" => pull_request } = params) do
    :timer.sleep(200)

    issue = create_issue(pull_request["issue_url"])

    case params do
       %{"action" => "review_requested" }       -> refresh_labels(issue)
       %{"action" => "review_request_removed" } -> refresh_labels(issue)
       %{"action" => _, "review" => _ }         -> refresh_labels(issue)
       _                                        -> IO.write "Event not implemented #{params["action"]}"
    end
  end

  def call(params) do
    IO.write "Event not implemented #{params["action"]}"
  end

  def refresh_labels(issue) do
    if !in_progress?(issue) do
      update_labels_for_issue(issue)
    end
  end

  def update_labels_for_issue(issue) do
    reviews = Github.reviews_for_issue(issue)
    states = Enum.map(reviews, fn(r) -> r["state"] end)

    total_approved = count_value_in_list(states, "APPROVED")
    total_changes_requested = count_value_in_list(states, "CHANGES_REQUESTED")
    total_pending = length(Github.requested_reviewers_for_issue(issue))

    IO.inspect total_approved
    IO.inspect total_changes_requested
    IO.inspect total_pending

    if total_pending > 0 && total_changes_requested == 0 do
      add_label(issue, "needs review")
      remove_label(issue, "changes requested")
      remove_label(issue, "approved")
    end

    if total_changes_requested > 0 do
      add_label(issue, "changes requested")
      remove_label(issue, "needs review")
      remove_label(issue, "approved")
    end

    if total_approved >= @required_approves && total_pending == 0 && total_changes_requested == 0 do
      add_label(issue, "approved")
      remove_label(issue, "needs review")
      remove_label(issue, "changes requested")
    end
  end

  defp create_issue(issue_url)  do
    [_, project, id] = Regex.run(~r/https:\/\/api.github.com\/repos\/+(.*\/.*)+\/issues\/+([0-9]*)/, issue_url)
    %{ 
      "project" => project,
      "id"      => id
    }
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

  defp label_names(issue) do
    labels = Github.labels_for_issue(issue)
    Enum.map(labels, fn(x) -> x["name"] end)
  end

  defp label_exist?(issue, label) do
    Enum.member?(label_names(issue), label)
  end

  defp in_progress?(issue) do
    label_exist?(issue, "in progress")
  end

  defp add_label(issue, label) do
    if !label_exist?(issue, label) do
      Github.add_label_to_issue(issue, label)
    end
  end

  defp remove_label(issue, label) do
     Github.remove_label_from_issue(issue, label)
  end
end
