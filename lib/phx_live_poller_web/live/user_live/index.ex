defmodule PhxLivePollerWeb.UserLive.Index do
  use PhxLivePollerWeb, :live_view

  alias PhxLivePoller.Accounts
  # alias PhxLivePoller.Accounts.User
  
  def mount(_params, %{"current_user_email" => user_email}, socket) do
    {:ok, user} = Accounts.get_user(user_email)
    {:ok, assign(socket, user: user, error: nil)}
  end

  def mount(_params, _session, socket) do
    {:ok, assign(socket, user: nil, error: nil)}
  end

  def handle_event("set_user", %{"username" => username, "email" => email}, socket) do
    case Accounts.register_user(username, email) do
      {:ok, user} ->
        {:noreply, assign(socket, user: user, error: nil)}

      {:error, error} ->
        {:noreply, assign(socket, error: error)}
    end
  end

  def render(assigns) do
    ~H"""
    <div>
      <%= if @user do %>
        <p>Welcome, <%= @user.name %>!</p>
      <% else %>
        <form phx-submit="set_user">
          <input name="username" placeholder="Enter Name" />
          <input name="email" placeholder="Enter Email" />
          <button type="submit">Register</button>
        </form>
        <%= if @error do %>
          <p style="color: red;"><%= @error %></p>
        <% end %>
      <% end %>
    </div>
    """
  end
end
