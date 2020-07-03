defmodule UpdatePullRequestTest do
  use ExUnit.Case
  alias GithubApprover.UseCases.UpdatePullRequest

  doctest GithubApprover.UseCases.UpdatePullRequest

  # review_requested, review_request_removed, opened
  test "the truth" do
    sample = """
    {
      "action": "opened",
      "number": 1,
      "pull_request": {
        "id" : 1
      }
    }
    """
    sample = Poison.Parser.parse!(sample)
    # TODO: test failing, fix it later
    # UpdatePullRequest.call(sample)
  end
end
