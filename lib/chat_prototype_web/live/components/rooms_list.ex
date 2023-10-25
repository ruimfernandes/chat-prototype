defmodule ChatPrototypeWeb.RoomsListLive do
  use ChatPrototypeWeb, :live_component

  def mount(socket) do
    {:ok,
     assign(socket,
       rooms: [
         %{id: "room-1", name: "Football", active?: false},
         %{id: "room-2", name: "Music", active?: false},
         %{id: "room-3", name: "Random", active?: false}
       ],
       active_rooms: []
     )}
  end

  def render(assigns) do
    ~H"""
    <div>
      <p class="text-2xl">Hey <%= @user_name %>! Join any room you want!</p>
      <div class="mt-10">
        <%= for room <- @rooms do %>
          <%= room.name %>
          <%= if !room.active? do %>
            <.button phx-click="join_room" phx-value-id={room.id} phx-target={@myself}>Join</.button>
          <% end %>
        <% end %>
      </div>
      <div class="mt-10">
        <%= for active_room <- @active_rooms do %>
          <.live_component module={ChatPrototypeWeb.ChatRoomLive} id={active_room} />
        <% end %>
      </div>
    </div>
    """
  end

  def handle_event("join_room", %{"id" => room_id}, socket) do
    rooms = update_room_status(socket.assigns.rooms, room_id, true)

    {:noreply,
     assign(socket,
       rooms: rooms,
       active_rooms: Enum.concat(socket.assigns.active_rooms, [room_id])
     )}
  end

  defp update_room_status(rooms_list, id, new_value) do
    Enum.map(rooms_list, fn
      %{id: ^id} = r -> Map.merge(r, %{active?: new_value})
      room -> room
    end)
  end
end
