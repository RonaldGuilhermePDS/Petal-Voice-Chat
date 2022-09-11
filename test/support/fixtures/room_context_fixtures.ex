defmodule PetalVoiceChat.RoomContextFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `PetalVoiceChat.RoomContext` context.
  """

  @doc """
  Generate a room.
  """
  def room_fixture(attrs \\ %{}) do
    {:ok, room} =
      attrs
      |> Enum.into(%{
        slug: "some slug",
        title: "some title"
      })
      |> PetalVoiceChat.RoomContext.create_room()

    room
  end
end
