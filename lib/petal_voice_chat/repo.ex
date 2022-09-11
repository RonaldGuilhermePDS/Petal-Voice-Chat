defmodule PetalVoiceChat.Repo do
  use Ecto.Repo,
    otp_app: :petal_voice_chat,
    adapter: Ecto.Adapters.Postgres
end
