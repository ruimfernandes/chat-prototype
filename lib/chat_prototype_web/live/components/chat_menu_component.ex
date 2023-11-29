defmodule ChatPrototypeWeb.ChatMenuComponent do
  use ChatPrototypeWeb, :html

  @spec render_chat_menu(Socket.assigns()) :: Phoenix.LiveView.Rendered.t()
  def render_chat_menu(assigns) do
    ~H"""
    <div class="flex flex-col gap-8 bg-zinc-800 max-w-s p-2 py-10">
      <%= for room <- @active_rooms do %>
        <.button
          class="menu-button"
          id={"menu-#{room.uuid}"}
          phx-click="select_room"
          phx-hook="SelectRoom"
          phx-value-id={room.uuid}
        >
          <%= room.name %> <%= show_unread_messages_count(assigns, room.unread_messages_count) %>
        </.button>
      <% end %>
    </div>
    """
  end

  @spec show_unread_messages_count(Socket.assigns(), number()) :: Phoenix.LiveView.Rendered.t()
  defp show_unread_messages_count(_assigns, 0), do: ""

  defp show_unread_messages_count(assigns, amount) do
    ~H"""
    - <%= amount %>
    """
  end
end
