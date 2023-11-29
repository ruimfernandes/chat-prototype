defmodule ChatPrototypeWeb.ChatMenuComponent do
  use ChatPrototypeWeb, :html

  @spec render_chat_menu(Socket.assigns()) :: Phoenix.LiveView.Rendered.t()
  def render_chat_menu(assigns) do
    ~H"""
    <div class="flex flex-col gap-8 bg-zinc-800 max-w-s p-2 py-10">
      <%= for room <- @active_rooms do %>
        <div class="relative">
          <.button
            class="menu-button"
            id={"menu-#{room.uuid}"}
            phx-click="select_room"
            phx-hook="SelectRoom"
            phx-value-id={room.uuid}
          >
            <%= room.name %>
          </.button>

          <div class={"button-unread-message #{set_visibility(room.unread_messages_count)}"}>
            <%= room.unread_messages_count %>
          </div>
        </div>
      <% end %>
    </div>
    """
  end

  @spec set_visibility(number()) :: String.t()
  defp set_visibility(0), do: "invisible"
  defp set_visibility(_value), do: "visible"
end
