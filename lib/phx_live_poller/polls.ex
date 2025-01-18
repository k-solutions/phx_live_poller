defmodule PhxLivePoller.Polls do
  @moduledoc """
  Provides functionality for managing polls and votes using ETS and Phoenix PubSub.

  Polls are stored in ETS as structs and support real-time updates through PubSub.

  ## Example Usage

      iex> PhxLivePoller.Polls.create_poll("Is Elixir awesome?")
      :ok

      iex> PhxLivePoller.Polls.list_polls()
      %{1 => %PhxLivePoller.Polls.Poll{id: 1, question: "Is Elixir awesome?", results: %{yes: 0, no: 0}}}

      iex> PhxLivePoller.Polls.vote("user1", 1, :yes)
      :ok
  """

  use GenServer

  alias __MODULE__.Poll

  # ETS table names
  @polls_tab :polls_tab
  @votes_tab :votes_tab
  @poll_not_found "Poll not found" 

  @type username() :: String.t()
  @type poll_id() :: integer()
  @type vote_result() :: {:ok, any()} | {:error, String.t()}

  @doc """
  Starts the Polls GenServer and initializes ETS tables.
  """
  @spec start_link(any()) :: GenServer.on_start()
  def start_link(_opts) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @doc """
  Creates a new poll with the given question.
  """
  @spec create_poll(String.t()) :: {:ok, Poll.t()}
  def create_poll(question) do
    GenServer.call(__MODULE__, {:create_poll, question})
  end

  @doc """
  Lists all active polls.

  ## Returns
    A map of poll IDs to `PhxLivePoller.Polls.Poll` structs.
  """
  @spec list_polls() :: %{poll_id() => Poll.t()}
  def list_polls do
    GenServer.call(__MODULE__, :list_polls)
  end

  @doc """
  Casts a vote for a poll.

  ## Parameters
    - `username`: The name of the user casting the vote.
    - `poll_id`: The ID of the poll to vote on.
    - `choice`: The vote choice, either :yes or :no.

  ## Returns
    - `:ok` if the vote was successful.
    - `{:error, reason}` if the vote failed.
  """
  @spec vote(username(), poll_id(), atom()) :: {:ok, any()} | {:error, String.t()}
  def vote(username, poll_id, choice) do
    GenServer.call(__MODULE__, {:vote, username, poll_id, choice})
  end

  @doc """
  Subscribes to poll updates via PubSub.

  ## Examples

      iex> PhxLivePoller.Polls.subscribe()
      :ok
  """
  @spec subscribe() :: :ok
  def subscribe do
    Phoenix.PubSub.subscribe(PhxLivePoller.PubSub, "polls")
  end

  @impl true
  def init(_state) do
    :ets.new(@polls_tab, [:named_table, :public, :set, {:keypos, 1}])
    :ets.new(@votes_tab, [:named_table, :public, :set, {:keypos, 1}])
    {:ok, []}
  end

  # TODO: Check if poll is not exists before creating it 
  @impl true
  def handle_call({:create_poll, question}, _from, _state) do
    case :ets.match(@polls_tab, {:"_", question, :"_", :"_"}) do
      [_] -> {:reply, {:error, "Poll already exists."}, []}
      []  ->  
        case Poll.new(question) do 
          {:ok, poll} ->
            poll_tpl = poll |> Poll.to_tuple() 
            @polls_tab |> :ets.insert(poll_tpl)
            broadcast()
            {:reply, {:ok, poll}, []}
          {:error, error} -> {:reply, {:error, error} ,[]}
        end
    end
  end

  @impl true
  def handle_call(:list_polls, _from, _state) do
    polls = :ets.tab2list(@polls_tab) 
    {:reply, Enum.into(polls, %{}, &from_tpl(&1)), []}
  end

  @impl true
  def handle_call({:vote, username, poll_id, :yes}, _from, _state) do
    process_vote(username, poll_id, :yes)
  end

  @impl true
  def handle_call({:vote, username, poll_id, :no}, _from, _state) do
    process_vote(username, poll_id, :no)
  end

  @impl true
  def handle_call({:vote, _username, _poll_id, invalid_choice}, _from, _state) do
    {:reply, {:error, "Invalid vote choice: #{inspect(invalid_choice)}. Must be :yes or :no."}, []}
  end

  defp process_vote(username, poll_id, choice) do
    case :ets.lookup(@votes_tab, username) do
      [{^username, voted_polls}] ->
        if voted_polls |> Enum.member?(poll_id) do 
          {:reply, {:error, "User has already voted in this poll"}, []}
        else
          with(    
            true <- :ets.update_counter(@polls_tab, poll_id, {get_pos(choice), 1}), 
            true <- :ets.update_element(@votes_tab, username, {2, [poll_id | voted_polls]})) do      
            broadcast()
            {:reply, :ok, []}
          else
            _  -> {:reply, {:error, @poll_not_found}, []}  
          end
        end     

      [] -> # first user vote  
        if :ets.update_counter(@polls_tab, poll_id, {get_pos(choice), 1}) do 
          :ets.insert(@votes_tab, {username, [poll_id]})
          broadcast()
          {:reply, :ok, []}
        else 
          {:reply, {:error, @poll_not_found}, []}
        end
    end
  rescue # NOTE: update_counter raises ArgumentError on key not found
    _ -> {:reply, {:error, @poll_not_found}, []}
  end

  defp get_pos(:yes), do: 3
  defp get_pos(_), do: 4

  defp from_tpl(poll_tpl) when is_tuple(poll_tpl) do
    poll = Poll.from_tuple(poll_tpl) 
    {poll.id, poll} 
  end

  defp broadcast do
    polls = :ets.tab2list(@polls_tab)
    Phoenix.PubSub.broadcast(
      PhxLivePoller.PubSub,
      "polls",
      {:polls_updated, Enum.into(polls, %{}, &from_tpl(&1))}
    )
  end
end
