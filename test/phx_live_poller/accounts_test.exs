defmodule PhxLivePoller.AccountsTest do
  #  # use PhxLivePoller.DataCase
  #  use ExUnit.Case 
  #
  #  doctest PhxLivePoller.Accounts
  use ExUnit.Case, async: true

  alias PhxLivePoller.Accounts
  alias PhxLivePoller.Accounts.{User, UserError}

  setup do
    # Start the Accounts GenServer
    Accounts.start_link([])
    %{}
  end

  describe "registering a new user" do
    test "returns an error if email is invalid" do
      assert Accounts.register_user("Charlie", "invalid-email") ==
               {:error, "Bad user email value: invalid-email"}
    end

    test "returns an error if email is already taken" do
      Accounts.register_user("Alice", "alice@example.com")

      assert Accounts.register_user("Bob", "alice@example.com") ==
               {:error, "User: alice@example.com already exists"}
    end
  end

  describe "checking if a user exists" do
    test "returns false if user does not exist" do
      refute Accounts.user_exists?("unknown@example.com")
    end

    test "returns true if user exists" do
      Accounts.register_user("Alice", "alice@example.com")
      assert Accounts.user_exists?("alice@example.com")
    end
  end

  describe "listing users" do
    test "returns a list of users if they exist" do
      Accounts.register_user("Alice", "alice@example.com")
      Accounts.register_user("Bob", "bob@example.com")

      users = Accounts.list_users()

      assert length(users) == 2
      assert Enum.any?(users, fn user -> user.email == "alice@example.com" end)
      assert Enum.any?(users, fn user -> user.email == "bob@example.com" end)
    end
  end
end
