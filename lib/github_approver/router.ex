defmodule GithubApprover.Router do
  use Plug.Router

  plug Plug.Logger
  plug Plug.Parsers, parsers: [:urlencoded, :json],
                     json_decoder: Poison

  plug :match                   
  plug :dispatch

  post "/webhook" do
    GithubApprover.UseCases.UpdatePullRequest.call(conn.params)
    send_resp(conn, 200, "ok")
  end

  match _ do
    send_resp(conn, 404, "oops")
  end
end
