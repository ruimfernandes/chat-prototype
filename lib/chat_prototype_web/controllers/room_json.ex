defmodule ChatPrototypeWeb.RoomJSON do
  @spec index(%{:rooms => list()}) :: %{data: list()}
  @doc """
  Renders a list of rooms.
  """
  def index(%{rooms: rooms}) do
    %{data: rooms}
  end

  @spec show(%{:room => map()}) :: %{data: map()}
  @doc """
  Renders a single room.
  """
  def show(%{room: room}) do
    %{data: room}
  end
end
