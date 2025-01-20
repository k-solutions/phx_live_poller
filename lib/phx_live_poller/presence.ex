defmodule PhxLivePoller.Presence do
  use Phoenix.Presence, otp_app: :phx_live_poller, pubsub_server: PhxLivePoller.PubSub
end
