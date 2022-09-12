defmodule PetalVoiceChatWeb.Presence do
  @moduledoc """
  A module to set presence of user
  """
  use Phoenix.Presence,
    otp_app: PetalVoiceChat,
    pubsub_server: PetalVoiceChat.PubSub
end
