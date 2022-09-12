defmodule PetalVoiceChatWeb.Room.NewLive do
  @moduledoc """
      A LiveView for creating chat rooms.
  """

  use PetalVoiceChatWeb, :live_view

  alias PetalVoiceChat.Repo
  alias PetalVoiceChat.RoomContext.Room

  @impl true
  def render(assigns) do
    Phoenix.View.render(PetalVoiceChatWeb.PageView, "new_live.html", assigns)
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
      socket
      |> put_changeset()
    }
  end

  @impl true
  def handle_event("validate", %{"room" => room_params}, socket) do
    {:noreply,
      socket
      |> put_changeset(room_params)
    }
  end

  def handle_event("save", _, %{assigns: %{changeset: changeset}} = socket) do
    case Repo.insert(changeset) do
      {:ok, room} ->
        {:noreply,
          socket
          |> push_redirect(to: Routes.room_show_path(socket, :show, room.slug))
        }
      {:error, changeset} ->
        {:noreply,
          socket
          |> assign(:changeset, changeset)
          |> put_flash(:error, "Could not save the room.")
        }
    end
  end

  defp put_changeset(socket, params \\ %{}) do
    socket
    |> assign(:changeset, Room.changeset(%Room{}, params))
  end
end
