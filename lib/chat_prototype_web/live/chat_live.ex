defmodule ChatPrototypeWeb.ChatLive do
  use ChatPrototypeWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, assign(socket, messages: [%{user: "Chatbot", text: "Welcome to my chat!"}])}
  end

  def render(assigns) do
    ~H"""
    Main chat room
    <%= for message <- @messages do %>
      <div>
        <b><%= message.user %></b> - <%= message.text %>
      </div>
    <% end %>

    <.button phx-click="more">Tell me more</.button>
    """
  end

  def handle_event("more", _params, socket) do
    {:noreply,
     assign(socket,
       messages:
         Enum.concat(socket.assigns.messages, [%{user: "Chatbot", text: "What do you need?"}])
     )}
  end
end
