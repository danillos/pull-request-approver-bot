defmodule ConvertedToDraftTest do
    use     ExUnit.Case, async: false
    alias   GithubApprover.Services.ConvertedToDraft
    doctest GithubApprover.Services.ConvertedToDraft

    @app_labels Application.get_env(:github_approver, :labels)

    import Mock

    setup_all do
      {:ok, issue: '123'}
    end

    # converted_to_draft
    test "the truth", state do
      with_mocks([
        {Github,[], [add_label_to_issue: fn(_issue, _label) -> nil end]},
        {Github,[], [remove_label_from_issue: fn(_issue, _label) -> nil end]},
      ]) do
        ConvertedToDraft.call(state[:issue])
        assert_called Github.add_label_to_issue(state[:issue], @app_labels["in_progress"])
        assert_called Github.remove_label_from_issue(state[:issue], @app_labels["pending"])
        assert_called Github.remove_label_from_issue(state[:issue], @app_labels["changes_requested"])
        assert_called Github.remove_label_from_issue(state[:issue], @app_labels["approved"])
      end
    end
end
