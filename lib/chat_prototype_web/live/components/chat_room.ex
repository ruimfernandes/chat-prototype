defmodule ChatPrototypeWeb.ChatRoomLive do
  use ChatPrototypeWeb, :live_component

  def mount(socket) do
    {:ok,
     assign(socket,
       messages: [%{user: "Chatbot", text: "UserX joinned the room!"}]
     )}
  end

  def render(assigns) do
    ~H"""
    <div>
      <p class="text-2xl">Room name here!</p>
      <div class="mt-10">
        <%= for message <- @messages do %>
          <b><%= message.user %></b> - <%= message.text %>
        <% end %>
      </div>
    </div>
    """
  end
end
