defmodule PhxLivePoller.Accounts do
  @moduledoc """
  Manages user account registration and data in memory using a GenServer.
  
  ## Examples
      iex> PhxLivePoller.Accounts.register_user("Alice", "alice@example.com")
      :ok

      iex> PhxLivePoller.Accounts.register_user("Bob", "bob@example.com")
      :ok

      iex> PhxLivePoller.Accounts.register_user("Alice", "alice@example.com")
      {:error, "User: alice@example.com already exists"}

      iex> PhxLivePoller.Accounts.register_user("Charlie", "invalid-email")
      {:error, "Bad user email value: invalid-email"}

      iex> PhxLivePoller.Accounts.user_exists?("alice@example.com")
      true

      iex> PhxLivePoller.Accounts.user_exists?("unknown@example.com")
      false

      iex> PhxLivePoller.Accounts.list_users()
      [%PhxLivePoller.Accounts.User{name: "Alice", email: "alice@example.com"}, %PhxLivePoller.Accounts.User{name: "Bob", email: "bob@example.com"}]
  """

  use GenServer
  alias PhxLivePoller.Accounts.{User, UserError}

  @type t() :: %{users: %{String.t() => User.t()}}
  @type name :: String.t()
  @type email :: String.t()
  @type error :: {:error, String.t()}

  @doc """
  Starts the GenServer for managing users.
  """
  @spec start_link(any()) :: {:ok, pid()} | {:error, any()}
  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{users: %{}}, name: __MODULE__)
  end

  @doc """
  Get a user with the given email from registered accounts.
  """
  @spec get_user(email()) :: {:ok, User.t()} | {:error, String.t()}
  def get_user(email) do
    GenServer.call(__MODULE__, {:get_user, email})
  end

  @doc """
  Registers a new user with the given name and email.
  """
  @spec register_user(name(), email()) :: {:ok, User.t()} | {:error, String.t()}
  def register_user(name, email) do
    GenServer.call(__MODULE__, {:register_user, name, email})
  end

  @doc """
  Checks if an email is already registered.
  """
  @spec user_exists?(email()) :: boolean()
  def user_exists?(email) do
    GenServer.call(__MODULE__, {:user_exists, email})
  end

  @doc """
  Lists all registered users.
  """
  @spec list_users() :: [User.t()]
  def list_users do
    GenServer.call(__MODULE__, :list_users)
  end

  @impl true
  def init(state) do
    {:ok, state}
  end

  @impl true
  def handle_call({:get_user, email}, _from, %{users: users} = state) do
    user = Map.get(users, email)
    if is_nil(user) do
      {:reply, {:error, %UserError{reason: :not_exists, status: email} |> UserError.message()}, state}
    else
      {:reply, {:ok, user}, %{state | users: users}}
    end
  end

  @impl true
  def handle_call({:register_user, name, email}, _from, %{users: users} = state) do
    if Map.has_key?(users, email) do
      {:reply, {:error, %UserError{reason: :exists, status: email} |> UserError.message()}, state}
    else
      case User.new(name, email) do
        {:ok, user} ->
          updated_users = Map.put(users, user.email, user) 
          {:reply, {:ok, user}, %{state | users: updated_users}}

        {:error, reason} ->
          {:reply, {:error, reason}, state}
      end
    end
  end

  @impl true
  def handle_call({:user_exists, email}, _from, %{users: users} = state) do
    exists = Map.has_key?(users, email)
    {:reply, exists, state}
  end

  @impl true
  def handle_call(:list_users, _from, %{users: users} = state) do
    {:reply, Map.values(users), state}
  end
end
