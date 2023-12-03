defmodule ChatPrototypeWeb.ChatRoomComponent do
  use ChatPrototypeWeb, :live_component

  @impl true
  @spec mount(Socket.t()) :: {:ok, Socket.t()}
  def mount(socket) do
    {:ok,
     assign(socket,
       name: "",
       messages: [],
       form: to_form(%{"text" => ""})
     ), temporary_assigns: [messages: []]}
  end

  @impl true
  @spec update(map(), Socket.t()) :: {:ok, Socket.t()}
  def update(%{new_messages: new_messages}, socket) do
    {:ok, assign(socket, messages: new_messages)}
  end

  def update(assigns, socket) do
    {:ok, assign(socket, name: assigns.name)}
  end

  @impl true
  @spec render(Socket.assigns()) :: Phoenix.LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <div class="flex flex-col grow p-10 bg-zinc-700 text-gray-100">
      <p class="text-4xl border-b-2"><%= @name %> room</p>
      <div class="flex flex-col grow justify-between">
        <div class="p-4" id="chat-messages" phx-update="append">
          <%= for message <- @messages do %>
            <div id={message.uuid}>
              <b><%= message.user %></b> - <%= message.text %>
            </div>
          <% end %>
        </div>

        <.simple_form id="chat_room" for={@form} phx-submit="send_message">
          <div class="flex flex-row gap-2">
            <div class="grow">
              <.input field={@form["text"]} />
            </div>
            <.button class="mt-2">Send</.button>
          </div>
        </.simple_form>
      </div>
    </div>
    """
  end
end
