defmodule PhxLivePollerWeb.PollListComponent do
  use PhxLivePollerWeb, :live_component

  alias PhxLivePoller.Polls

  @impl true
  def mount(socket) do
    {:ok, assign(socket, new_poll: "")}
  end

  @impl true
  def handle_event("create_poll", %{"question" => question}, socket) do
    Polls.create_poll(question)
    {:noreply, assign(socket, new_poll: "")}
  end

  @impl true
  def handle_event("select_poll", %{"poll_id" => poll_id}, socket) do
    send(self(), {:select_poll, poll_id})
    {:noreply, socket}
  end

  # TODO: make sure the poll is not a link once it is voted by the user 
  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <form phx-submit="create_poll" phx-target={@myself}>
        <input
          type="text"
          name="question"
          placeholder="New poll question"
          value={@new_poll}
          class="w-full py-2 px-4 border border-gray-300 rounded focus:ring-2 focus:ring-blue-500 focus:outline-none"
        />
        <button
          type="submit"
          class="w-full py-2 px-4 bg-blue-600 text-white rounded hover:bg-blue-700"
        >
          Create Poll
        </button>
      </form>

      <h2>Polls listing!</h2>
      <ul>
        <%= for {id, poll} <- @polls do %>
          <li>
            <button phx-click="select_poll" phx-value-poll_id={id} phx-target={@myself}>
              {poll.question}
            </button>
            <span>Yes votes: {poll.results.yes}</span>
            <span>No votes: {poll.results.no}</span>
          </li>
        <% end %>
      </ul>
    </div>
    """
  end
end
