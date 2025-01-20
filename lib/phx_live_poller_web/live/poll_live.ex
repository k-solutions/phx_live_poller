defmodule PhxLivePollerWeb.PollLive do
  use PhxLivePollerWeb, :live_view

  alias PhxLivePoller.{Users, Polls}

  @impl true
  def mount(_params, session, socket) do
    if connected?(socket), do: Polls.subscribe()

    {:ok,
     assign(socket, user: session["current_user"], polls: Polls.list_polls(), current_poll: nil)}
  end

  @impl true
  def handle_event("user_logged_in", %{"username" => username}, socket) do
    # Ensure user is registered
    :ok = Users.register_user(self(), username)
    {:noreply, assign(socket, user: username)}
  end

  @impl true
  def handle_event("select_poll", %{"poll_id" => poll_id}, socket) do
    {:noreply, assign(socket, current_poll: String.to_integer(poll_id))}
  end

  @impl true
  def handle_info({:cast_poll, _poll_id}, socket) do
    {:noreply, assign(socket, current_poll: nil)}
  end

  @impl true
  def handle_info({:select_poll, poll_id}, socket) do
    {:noreply, assign(socket, current_poll: poll_id)}
  end

  @impl true
  def handle_info({:polls_updated, polls}, socket) do
    {:noreply, assign(socket, polls: polls, current_poll: nil)}
  end

  def render(assigns) do
    ~H"""
    <div id="poll-view" class="p-6 max-w-lg mx-auto bg-white rounded-xl shadow-md space-y-4">
      <%= if @user do %>
        <h1>Welcome, {@user}!</h1>
        <%= if @current_poll do %>
          <.live_component
            module={PhxLivePollerWeb.PollVoteComponent}
            id="poll-vote"
            poll_id={@current_poll}
            user={@user}
          />
        <% else %>
          <.live_component
            module={PhxLivePollerWeb.PollListComponent}
            id="poll-list"
            user={@user}
            polls={@polls}
          />
        <% end %>
      <% else %>
        <PhxLivePollerWeb.UserLoginComponent.login_form id="user-login" />
      <% end %>
    </div>
    """
  end
end
