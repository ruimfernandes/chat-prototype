defmodule ChatPrototypeWeb.ChatRoomLive do
  use ChatPrototypeWeb, :live_component

  def mount(socket) do
    {:ok,
     assign(socket,
       messages: [%{user: "Chatbot", text: "UserX joinned the room!"}],
       form: to_form(%{text: ""}),
       first_update: true
     )}
  end

  def update(%{new_message: new_message}, socket) do
    IO.inspect(new_message, label: "Ggoooooooooooo")

    {:ok,
     assign(socket,
       messages: Enum.concat(socket.assigns.messages, [new_message])
     )}
  end

  def update(assigns, socket) do
    IO.inspect(socket)
    IO.inspect(assigns)
    subscribe_to_topic(socket.assigns.first_update, assigns.id)

    {:ok, assign(socket, id: assigns.id, first_update: false)}
  end

  def render(assigns) do
    ~H"""
    <div class="flex flex-col border-2 bg-slate-300">
      <p class="text-2xl bg-slate-400">Room name here!</p>
      <div class="flex flex-col grow justify-between">
        <div class="p-4">
          <%= for message <- @messages do %>
            <div>
              <b><%= message.user %></b> - <%= message.text %>
            </div>
          <% end %>
        </div>

        <.simple_form for={@form} phx-submit="send_message" phx-target={@myself}>
          <div class="flex flex-row gap-2">
            <div class="grow">
              <.input field={@form[:text]} value={@form.params.text} />
            </div>
            <.button class="mt-2">Send</.button>
          </div>
        </.simple_form>
      </div>
    </div>
    """
  end

  def handle_event("send_message", %{"text" => text}, socket) do
    ChatPrototypeWeb.Endpoint.broadcast(socket.assigns.id, "new-message", %{
      user: "NABO",
      text: text
    })

    {:noreply,
     assign(socket,
       messages: Enum.concat(socket.assigns.messages, [%{user: "NABO", text: text}])
     )}
  end

  def subscribe_to_topic(true, id) do
    ChatPrototypeWeb.Endpoint.subscribe(id)
  end

  def subscribe_to_topic(false, _id) do
    :ok
  end
end
