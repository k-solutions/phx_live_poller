defmodule PhxLivePoller.Accounts.User do
  @moduledoc """
  Represents a user with a name and email. Includes validation for email format.

  ## Examples

      iex> PhxLivePoller.Accounts.User.new("Alice", "alice@example.com")
      {:ok, %PhxLivePoller.Accounts.User{name: "Alice", email: "alice@example.com"}}

      iex> PhxLivePoller.Accounts.User.new("Bob", "invalid-email")
      {:error, "Bad user email value: invalid-email"}

  """
  alias PhxLivePoller.Accounts.UserError

  @enforce_keys [:name, :email]
  defstruct [:name, :email]

  @type t() :: %__MODULE__{
          name: String.t(),
          email: String.t()
        }

  @email_regex Regex.compile!("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$")

  @doc """
  Creates a new user struct with the given name and email.
  """
  @spec new(String.t(), String.t()) :: {:ok, t()} | {:error, String.t()}
  def new(name, email) when name == "" or email == "",
    do: {:error, %UserError{reason: :empty_data} |> UserError.message()}

  def new(name, email) do
    if valid_email?(email) do
      {:ok, %__MODULE__{name: name, email: email}}
    else
      {:error, %UserError{reason: :bad_email, status: email} |> UserError.message()}
    end
  end

  # Validates the email format.
  @spec valid_email?(String.t()) :: boolean()
  defp valid_email?(email), do: Regex.match?(@email_regex, email)
end
