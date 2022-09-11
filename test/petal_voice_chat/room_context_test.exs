defmodule PetalVoiceChat.RoomContextTest do
  use PetalVoiceChat.DataCase

  alias PetalVoiceChat.RoomContext

  describe "rooms" do
    alias PetalVoiceChat.RoomContext.Room

    import PetalVoiceChat.RoomContextFixtures

    @invalid_attrs %{slug: nil, title: nil}

    test "list_rooms/0 returns all rooms" do
      room = room_fixture()
      assert RoomContext.list_rooms() == [room]
    end

    test "get_room!/1 returns the room with given id" do
      room = room_fixture()
      assert RoomContext.get_room!(room.id) == room
    end

    test "create_room/1 with valid data creates a room" do
      valid_attrs = %{slug: "some slug", title: "some title"}

      assert {:ok, %Room{} = room} = RoomContext.create_room(valid_attrs)
      assert room.slug == "some slug"
      assert room.title == "some title"
    end

    test "create_room/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = RoomContext.create_room(@invalid_attrs)
    end

    test "update_room/2 with valid data updates the room" do
      room = room_fixture()
      update_attrs = %{slug: "some updated slug", title: "some updated title"}

      assert {:ok, %Room{} = room} = RoomContext.update_room(room, update_attrs)
      assert room.slug == "some updated slug"
      assert room.title == "some updated title"
    end

    test "update_room/2 with invalid data returns error changeset" do
      room = room_fixture()
      assert {:error, %Ecto.Changeset{}} = RoomContext.update_room(room, @invalid_attrs)
      assert room == RoomContext.get_room!(room.id)
    end

    test "delete_room/1 deletes the room" do
      room = room_fixture()
      assert {:ok, %Room{}} = RoomContext.delete_room(room)
      assert_raise Ecto.NoResultsError, fn -> RoomContext.get_room!(room.id) end
    end

    test "change_room/1 returns a room changeset" do
      room = room_fixture()
      assert %Ecto.Changeset{} = RoomContext.change_room(room)
    end
  end
end
