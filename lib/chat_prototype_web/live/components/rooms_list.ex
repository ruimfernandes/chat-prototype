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
    <div class="flex flex flex-col">
      <p class="text-2xl text-center">Hey <%= @user_name %>! Join any room you want!</p>
      <div class="mt-10 flex flex-col gap-y-4 justify-start">
        <%= for room <- @rooms do %>
          <div class="h-10 flex items-center gap-12">
            <%= room.name %>
            <%= if !room.active? do %>
              <.button phx-click="join_room" phx-value-id={room.id} phx-target={@myself}>
                Join
              </.button>
            <% else %>
              (joinned)
            <% end %>
          </div>
        <% end %>
      </div>
      <div class="flex flex-row-reverse justify-start gap-x-8 absolute inset-x-0 bottom-0">
        <%= for active_room <- @active_rooms do %>
          <.live_component module={ChatPrototypeWeb.ChatRoomLive} id={active_room} user={@user_name} />
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
