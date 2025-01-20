defmodule PhxLivePollerWeb.PollVoteComponent do
  use PhxLivePollerWeb, :live_component

  alias PhxLivePoller.Polls

  @impl true
  def mount(socket) do
    {:ok, assign(socket, poll: nil, error: nil)}
  end

  @impl true
  def update(%{poll_id: poll_id, user: user}, socket) do
    {:ok, poll} = poll_id |> String.to_integer() |> Polls.get_poll()
    {:ok, assign(socket, poll: poll, user: user)}
  end

  @impl true
  def handle_event("vote", %{"choice" => choice}, socket) do
    case Polls.vote(socket.assigns.user, socket.assigns.poll.id, String.to_atom(choice)) do
      :ok ->
        send(self(), {:cast_poll, socket.assigns.poll.id})
        {:noreply, socket}

      {:error, reason} ->
        {:noreply, assign(socket, error: reason)}
    end
  end

  # TODO: On Vote error we need to transform Vote Button to back to List
  def render(assigns) do
    ~H"""
    <div class="p-6 max-w-lg mx-auto bg-white rounded-xl shadow-md space-y-4">
      <h1 class="text-xl font-bold text-gray-800">{@poll.question}</h1>
      <form phx-submit="vote" phx-target={@myself} class="space-y-4">
        <%= if @error do %>
          <div class="bg-red-100 text-red-700 p-2 rounded">
            <p>{@error}</p>
          </div>
        <% end %>
        <%= for {choice, count} <- @poll.results do %>
          <div class="flex items-center space-x-2">
            <label class="text-gray-700">
              <input type="radio" name="choice" value={Atom.to_string(choice)} />
              {Atom.to_string(choice)} ({count})
            </label>
          </div>
        <% end %>
        <button
          type="submit"
          class="w-full py-2 px-4 bg-blue-600 text-white rounded hover:bg-blue-700"
        >
          Vote
        </button>
      </form>
    </div>
    """
  end
end
