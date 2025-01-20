defmodule PhxLivePollerWeb.UserListComponent do
  use PhxLivePollerWeb, :live_component

  alias PhxLivePoller.Users

  @impl true
  def mount(socket) do
    # Subscribe to user list updates
    Phoenix.PubSub.subscribe(PhxLivePoller.PubSub, "users:lobby")

    {:ok, assign(socket, :users, Users.list_users())}
  end

  @impl true
  def handle_info({:user_list_updated, users}, socket) do
    {:noreply, assign(socket, :users, users)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <h2>Online Users</h2>
      <ul>
        <%= for user <- @users do %>
          <li>{user.username} (online since: {user.online_at})</li>
        <% end %>
      </ul>
    </div>
    """
  end
end
