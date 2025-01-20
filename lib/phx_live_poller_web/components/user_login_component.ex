defmodule PhxLivePollerWeb.UserLoginComponent do
  # PhxLivePollerWeb, :component
  use Phoenix.Component

  @impl true
  def login_form(assigns) do
    ~H"""
    <div>
      <h1>Login</h1>
      <form phx-submit="user_logged_in" id="new_user">
        <input
          type="text"
          name="username"
          placeholder="Enter your username"
          class="w-full py-2 px-4 border border-gray-300 rounded focus:ring-2 focus:ring-blue-500 focus:outline-none"
        />
        <button
          type="submit"
          class="w-full py-2 px-4 bg-blue-600 text-white rounded hover:bg-blue-700"
        >
          Login
        </button>
      </form>
    </div>
    """
  end
end
