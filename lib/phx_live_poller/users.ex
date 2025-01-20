defmodule PhxLivePoller.Users do
  alias PhxLivePoller.{Presence, Users, PubSub}

  @users_channel "users:lobby"

  @doc """
  Registers a user and tracks them using Phoenix Presence.
  """
  def register_user(pid, username) do
    metadata = %{online_at: DateTime.utc_now(), username: username}

    case Presence.track(pid, @users_channel, username, metadata) do
      {:error, error} ->
        {:error, error}

      {:ok, _} ->
        broadcast_users()
        :ok
    end
  end

  @doc """
  Returns the list of all tracked users.
  """
  def list_users do
    @users_channel
    |> Presence.list()
    |> Enum.map(fn {username, %{metas: [meta | _]}} ->
      %{username: username, online_at: meta.online_at}
    end)
  end

  def broadcast_users do
    Phoenix.PubSub.broadcast(PubSub, @users_channel, {:user_list_updated, list_users()})
  end
end
