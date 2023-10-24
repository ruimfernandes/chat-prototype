defmodule ChatPrototypeWeb.ChatLive do
  use ChatPrototypeWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       messages: [%{user: "Chatbot", text: "Welcome to my chat!"}],
       form: to_form(%{user_input: "", text_input: ""})
     )}
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
