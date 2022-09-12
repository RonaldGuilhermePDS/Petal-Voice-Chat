defmodule PetalVoiceChat.RoomContext.Room do
  @moduledoc """
    A module to create room context
  """
  use Ecto.Schema
  import Ecto.Changeset

  schema "rooms" do
    field :title, :string
    field :slug, :string

    timestamps()
  end

  def changeset(room, attrs) do
    room
    |> cast(attrs, [:title, :slug])
    |> validate_required([:title, :slug])
    |> format_slug()
    |> unique_constraint(:slug)
  end

  defp format_slug(%Ecto.Changeset{changes: %{slug: _}} = changeset) do
    changeset
    |> update_change(:slug, fn slug ->
      slug
      |> String.downcase()
      |> String.replace(" ", "-")
    end)
  end

  defp format_slug(changeset), do: changeset
end
