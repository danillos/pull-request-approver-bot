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

  def add_label_to_issue(issue, label) do
    post("/repos/#{issue["project"]}/issues/#{issue["id"]}/labels", [label])
  end

  def remove_label_from_issue(issue, label) do
    label = URI.encode(label)
    delete("/repos/#{issue["project"]}/issues/#{issue["id"]}/labels/#{label}")
  end

  def reviews_for_issue(issue) do
    get("/repos/#{issue["project"]}/pulls/#{issue["id"]}/reviews").body
  end

  def last_reviews_by_user_for_issue(issue) do
    reviews_for_issue(issue)
    |> Enum.group_by(fn(i) -> i["user"]["login"] end)
    |> Enum.map(fn {_k, v} -> Enum.sort_by(v, fn(d) -> Timex.parse(d, "{ISO:Extended}") end) |>  List.last  end)
  end

  def requested_reviewers_for_issue(issue) do
    get("/repos/#{issue["project"]}/pulls/#{issue["id"]}/requested_reviewers").body
  end

  def access_token do
  	Application.get_env(:github_approver, :github_access_token)
  end
end
