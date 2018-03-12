defmodule Github do
  use Tesla

  plug Tesla.Middleware.BaseUrl, "https://api.github.com"
  plug Tesla.Middleware.Headers, %{"Authorization" => "token #{access_token()}"}
  plug Tesla.Middleware.JSON

  adapter Tesla.Adapter.Hackney

  def issue(issue) do
    get("/repos/#{issue["project"]}/issues/#{issue["id"]}").body
  end

  def labels_for_issue(issue) do
    get("/repos/#{issue["project"]}/issues/#{issue["id"]}/labels").body
  end

  def label_exist?(issue, label) do
    Enum.member?(label_names(issue), label)
  end

  def add_label_to_issue(issue, label) do
    if !Github.label_exist?(issue, label) do
      post("/repos/#{issue["project"]}/issues/#{issue["id"]}/labels", [label])
    end
  end

  def remove_label_from_issue(issue, label) do
    if Github.label_exist?(issue, label) do
      label = URI.encode(label)
      delete("/repos/#{issue["project"]}/issues/#{issue["id"]}/labels/#{label}")
    end
  end

  def issue_info(issue) do
    get("/repos/#{issue["project"]}/issues/#{issue["id"]}").body
  end

  def reviews_for_issue(issue) do
    get("/repos/#{issue["project"]}/pulls/#{issue["id"]}/reviews").body
  end

  def has_review_comments?(issue) do
    total = last_reviews_by_user_for_issue(issue)
    |> Enum.filter(fn(x) -> (x["state"] == "COMMENTED") end)
    |> Enum.count

    IO.inspect total
    
    total > 0
  end

  def last_reviews_by_user_for_issue(issue) do
    reviews_for_issue(issue)
    |> Enum.filter(fn(review) -> valid_review?(review, issue) end)
    |> Enum.group_by(fn(review) -> review["user"]["login"] end)
    |> Enum.map(fn {_k, reviews} -> last_review(reviews) end)
  end

  def requested_reviewers_for_issue(issue) do
    get("/repos/#{issue["project"]}/pulls/#{issue["id"]}/requested_reviewers").body
  end

  def access_token do
  	Application.get_env(:github_approver, :github_access_token)
  end

  defp last_review(reviews) do
    Enum.sort_by(reviews, fn(review) -> Timex.parse(review["submitted_at"], "{ISO:Extended}") end) |>  List.last
  end

  defp valid_review?(review, issue) do
    regular_review?(review) || valid_review_comment?(review, issue)
  end

  defp valid_review_comment?(review, issue) do
    empty_body = review["body"] == ""
    owner_comment = review["user"]["login"] == issue["user"]["login"]

    !regular_review?(review) && !empty_body && !owner_comment
  end

  defp regular_review?(review) do
    review["state"] != "COMMENTED"
  end

  defp label_names(issue) do
    labels_for_issue(issue)
    |> Enum.map(fn(x) -> x["name"] end)
  end
end
