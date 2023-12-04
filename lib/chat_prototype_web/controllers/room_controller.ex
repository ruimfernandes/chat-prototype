defmodule ChatPrototypeWeb.RoomController do
  use ChatPrototypeWeb, :controller

  alias ChatPrototype.Server

  action_fallback ChatPrototypeWeb.FallbackController

  @spec index(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def index(conn, _params) do
    rooms = Server.list_rooms()

    render(conn, :index, rooms: rooms)
  end

  @spec create(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def create(conn, %{"name" => name}) do
    room = Server.start_room(name)

    conn
    |> put_status(:created)
    |> render(:show, room: room)
  end
end
