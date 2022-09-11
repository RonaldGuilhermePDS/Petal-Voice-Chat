defmodule PetalVoiceChatWeb.Room.ShowLive do
  @moduledoc """
  """

  use PetalVoiceChatWeb, :live_view

  alias PetalVoiceChat.RoomContext

  @impl true
  def render(assigns) do
    ~L"""
    <h1><%= @room.title %></h1>
    """
  end

  @impl true
  def mount(%{"slug" => slug}, _session, socket) do
    case RoomContext.get_room(slug) do
      nil ->
        {:ok,
          socket
          |> put_flash(:error, "That room does not exist.")
          |> push_redirect(to: Routes.room_new_path(socket, :new))
        }
      room ->
        {:ok,
          socket
          |> assign(:room, room)
        }
    end
  end
end
