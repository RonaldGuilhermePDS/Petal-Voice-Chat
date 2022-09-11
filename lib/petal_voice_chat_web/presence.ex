defmodule PetalVoiceChatWeb.Presence do
  use Phoenix.Presence,
    otp_app: PetalVoiceChat,
    pubsub_server: PetalVoiceChat.PubSub
end
