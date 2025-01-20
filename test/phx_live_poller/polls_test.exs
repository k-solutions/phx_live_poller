defmodule PhxLivePoller.PoolsTest do
  use ExUnit.Case

  alias PhxLivePoller.Polls
  alias PhxLivePoller.Polls.Poll

  setup do
    on_exit(:clean_ets, fn ->
      :ets.delete_all_objects(:polls_tab)
      :ets.delete_all_objects(:votes_tab)
    end)

    Polls.start_link([])
    %{}
  end

  test "create_poll creates a new poll" do
    assert {:ok, poll} = Polls.create_poll("Is Elixir awesome?")
    assert [{_, "Is Elixir awesome?", 0, 0}] = :ets.lookup(:polls_tab, poll.id)
  end

  test "create_poll prevents duplicate polls" do
    assert {:ok, _} = Polls.create_poll("Is Elixir awesome?")
    assert {:error, "Poll already exists."} = Polls.create_poll("Is Elixir awesome?")
  end

  test "list_polls returns all active polls" do
    {:ok, %Poll{id: poll_id}} = Polls.create_poll("Is Elixir awesome?")
    polls = Polls.list_polls()

    assert %{
             ^poll_id => %Poll{
               id: ^poll_id,
               question: "Is Elixir awesome?",
               results: %{yes: 0, no: 0}
             }
           } = polls
  end

  test "vote increments poll results and tracks user vote" do
    {:ok, %Poll{id: poll_id}} = Polls.create_poll("Is Elixir awesome?")

    assert :ok = Polls.vote("user1", poll_id, :yes)
    assert [{_, "Is Elixir awesome?", 1, 0}] = :ets.lookup(:polls_tab, poll_id)
    assert [{"user1", [^poll_id]}] = :ets.lookup(:votes_tab, "user1")
  end
end
