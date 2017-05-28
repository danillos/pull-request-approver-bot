defmodule RouterTest do
	use ExUnit.Case, async: true
  use Plug.Test

  alias GithubApprover.UseCases.UpdatePullRequest

  import Mock

  @opts GithubApprover.Router.init([])

  test "returns hello world" do
    with_mock UpdatePullRequest, [call: fn(_params) -> true end] do
      conn = conn(:post, "/webhook")
      conn = GithubApprover.Router.call(conn, @opts)

      # Assert the response and status
      assert conn.state == :sent
      assert conn.status == 200
      assert conn.resp_body == "ok"
    end
  end
end
