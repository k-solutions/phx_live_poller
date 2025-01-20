# PhxLivePoller

To start your Phoenix server:

  * Run `mix setup` to install and setup dependencies
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

# Design 

We have just Application supervisor and we start all LiveView processes under it, as well as a Account GenSrever ment to hold logged users (as of lack of time the login functionality is not implemented and therefore this GenServer is not currently used)
I also was not able to set tests for the LiveView and it's components.
All Polls are stored in 2 named ETS tabales:
 - polls_tab for holding polls with it's votings
 NOTE: polls are stored info is tored as tuple to be able to use :ets.update_counter opperation on it
 - vote_tab is holding a list of users and a list of poll_ids they have been voted on    

Currently all Users are kept only in Phoenix.Presence only I was also not able to integrate UserList live component into the current UI. 

# Requrments
The application should allow users to create new polls, vote in polls, and see real-time updates of the poll results.
The solution should not use any external dependencies, such as a database or disk storage, and should instead store all needed data in application memory. 
You are free to use any Elixir/Erlang library and any open-source CSS framework for the design.

## Functional Requirements

  *  All code should be shared via private Github repository.
  *  The solution should be built with Phoenix LiveView.
  *  Users should be able to create account by inserting their username.
  *  Users should be able to create new polls.
  *  Users should be able to vote in existing polls.
  *  Users should be able to see real-time updates of the poll results.
  *  User can only vote once in a single poll.
  *  Performance: users actions should not be blocking each other. User 1 actions should not be blocked by user 2 actions.
  *  You are free to use any Elixir/Erlang library and any open-source CSS framework for the UI.
  *  The application should not use any external dependencies, such as a database or disk storage. All needed data should be stored in application memory.
  *  The application should start with mix phx.server so it can be started locally.
  *  The application should be well-structured, and the code should be readable.


Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix
