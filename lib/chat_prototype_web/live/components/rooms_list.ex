defmodule ChatPrototypeWeb.RoomsListLive do
  use ChatPrototypeWeb, :live_component

  def mount(socket) do
    {:ok,
     assign(socket,
       rooms: [
         %{id: "room-1", name: "Football"},
         %{id: "room-2", name: "Music"},
         %{id: "room-3", name: "Random"}
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
          <.button phx-click="join_room" phx-value-id={room.id} phx-target={@myself}>Join</.button>
        <% end %>
      </div>
    </div>
    """
  end

  def handle_event("join_room", %{"id" => room_id}, socket) do
    {:noreply,
     assign(socket,
       active_rooms: Enum.concat(socket.assigns.active_rooms, [room_id])
     )}
  end
end
