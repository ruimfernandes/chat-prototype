defmodule ChatPrototypeWeb.RoomJSON do
  @doc """
  Renders a list of rooms.
  """
  def index(%{rooms: rooms}) do
    %{data: rooms}
  end

  @doc """
  Renders a single room.
  """
  def show(%{room: room}) do
    %{data: room}
  end
end
