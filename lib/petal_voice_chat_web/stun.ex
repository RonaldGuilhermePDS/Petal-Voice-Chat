defmodule PetalVoiceChatWeb.Stun do
  @moduledoc """
    A module to stablish media connection between peers for VoIP
  """
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, [])
  end

  @impl true
  @doc """
  Starts the Erlang STUN server at port 3478.
  """
  def init(_) do
    :stun_listener.add_listener({127, 0, 0, 1}, 3478, :udp, [{:use_turn, true}])

    {:ok, []}
  end
end
