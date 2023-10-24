defmodule ChatPrototypeWeb.ChatLive do
  use ChatPrototypeWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       messages: [%{user: "Chatbot", text: "Welcome to my chat!"}],
       form: to_form(%{user_input: "", text_input: ""})
     )}
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

    <.simple_form for={@form} phx-submit="send_message">
      <b> Write something! </b>
      <p>User name: <.input field={@form[:user]} value={@form.params.user_input} /></p>
      <p>Your message: <.input field={@form[:text]} value={@form.params.text_input} /></p>
      <.button>Send message</.button>
    </.simple_form>
    """
  end

  def handle_event("more", _params, socket) do
    {:noreply,
     assign(socket,
       messages:
         Enum.concat(socket.assigns.messages, [%{user: "Chatbot", text: "What do you need?"}])
     )}
  end

  def handle_event("send_message", %{"user" => user, "text" => text}, socket) do
    {:noreply,
     assign(socket,
       messages: Enum.concat(socket.assigns.messages, [%{user: user, text: text}])
     )}
  end
end
