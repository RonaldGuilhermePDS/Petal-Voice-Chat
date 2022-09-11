defmodule PetalVoiceChatWeb.Room.ShowLive do
  @moduledoc """
    A LiveView for creating and joining chat rooms.
  """

  use PetalVoiceChatWeb, :live_view

  alias PetalVoiceChat.RoomContext
  alias PetalVoiceChat.ConnectedUser

  alias PetalVoiceChatWeb.Presence
  alias Phoenix.Socket.Broadcast

  @impl true
  def render(assigns) do
    ~L"""
    <h1><%= @room.title %></h1>
    <h3>Connected Users:</h3>
    <ul>
      <%= for uuid <- @connected_users do %>
        <li><%= uuid %></li>
      <% end %>
    </ul>

    <video id="local-video" playsinline autoplay muted width="600"></video>
    <button class="button" phx-hook="JoinCall">Join Call</button>
    """
  end

  @impl true
  def mount(%{"slug" => slug}, _session, socket) do
    user = create_connected_user()
    Phoenix.PubSub.subscribe(PetalVoiceChat.PubSub, "room:" <> slug)
    {:ok, _} = Presence.track(self(), "room:" <> slug, user.uuid, %{})

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
          |> assign(:user, user)
          |> assign(:slug, slug)
          |> assign(:connected_users, [])
        }
    end
  end

  @impl true
  def handle_info(%Broadcast{event: "presence_diff"}, socket) do
    {:noreply,
      socket
      |> assign(:connected_users, list_present(socket))}
  end

  defp list_present(socket) do
    Presence.list("room:" <> socket.assigns.slug)
    |> Enum.map(fn {k, _} -> k end)
  end

  defp create_connected_user do
    %ConnectedUser{uuid: UUID.uuid4()}
  end
end
