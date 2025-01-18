  defmodule PhxLivePoller.Polls.Poll do
    @moduledoc """
    Struct representing a poll.

    ## Fields
    - `:id` - The unique identifier of the poll.
    - `:question` - The question of the poll.
    - `:results` - A map with "Yes" and "No" counts.
    """
    @enforce_keys [:id, :question, :results]
    defstruct [:id, :question, :results]

    @type poll_tuple() :: {integer(), String.t(), non_neg_integer(), non_neg_integer()}

    @type t :: %__MODULE__{
            id: integer(),
            question: String.t(),
            results: %{String.t() => non_neg_integer()}
          }
    
    @spec new(String.t()) :: {:ok, Poll.t()} | {:error, String.t()}
    def new(question) when question != "" do
       id = :erlang.unique_integer([:monotonic, :positive])
       {:ok, %__MODULE__{id: id, question: question, results: %{yes: 0, no: 0}}}
    end  
  
    def new(_), do: {:error, "Question in the poll could not be empty!"}

    @spec to_tuple(Poll.t()) :: poll_tuple()
    def to_tuple(%__MODULE__{} = poll), do: {poll.id, poll.question, poll.results.yes, poll.results.no} 

    @spec from_tuple(poll_tuple()) :: Poll.t()
    def from_tuple({id, question, yes_result, no_result}) do 
      %__MODULE__{
        id: id, 
        question: question, 
        results: %{yes: yes_result, no: no_result}
      }
    end  
  end
