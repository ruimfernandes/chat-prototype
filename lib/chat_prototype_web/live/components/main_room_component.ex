defmodule ChatPrototypeWeb.MainRoomComponent do
  use ChatPrototypeWeb, :html

  @spec render_main_room(Socket.assigns()) :: Phoenix.LiveView.Rendered.t()
  def render_main_room(assigns) do
    ~H"""
    <div class="bg-zinc-700 grow p-10 text-gray-100">
      <p class="text-4xl border-b-2">Welcome to this chat app!</p>
      <p class="text-xl mt-4">Feel free to join any of the rooms below</p>
      <div id="main-room" class="flex flex-col gap-4 mt-4">
        <%= for room <- @all_rooms do %>
          <%= if is_uuid_in_rooms_list?(@active_rooms, room.uuid) do %>
            <p><%= room.name %> (already joinned)</p>
          <% else %>
            <.button phx-click="join_room" id={"join-#{room.uuid}"} phx-value-id={room.uuid}>
              <%= room.name %>
            </.button>
          <% end %>
        <% end %>
      </div>
    </div>
    """
  end

  @spec is_uuid_in_rooms_list?(list(), String.t()) :: boolean()
  defp is_uuid_in_rooms_list?(list, uuid) do
    Enum.any?(list, fn room -> room.uuid == uuid end)
  end
end
