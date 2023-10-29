defmodule ChatPrototypeWeb.ChatRoomLive do
  use ChatPrototypeWeb, :live_component

  def mount(socket) do
    {:ok,
     assign(socket,
       name: "",
       messages: [],
       form: to_form(%{"text" => ""}),
       first_update: true
     ), temporary_assigns: [messages: []]}
  end

  def update(%{new_messages: new_messages}, socket) do
    {:ok, assign(socket, messages: new_messages)}
  end

  def update(assigns, socket) do
    {:ok, assign(socket, name: assigns.name)}
  end

  def render(assigns) do
    ~H"""
    <div class="flex flex-col border-2 bg-slate-300">
      <p class="text-2xl bg-slate-400"><%= @name %> room</p>
      <div class="flex flex-col grow justify-between">
        <div class="p-4" id="chat-messages" phx-update="append">
          <%= for message <- @messages do %>
            <div id={message.uuid}>
              <b><%= message.user %></b> - <%= message.text %>
            </div>
          <% end %>
        </div>

        <.simple_form for={@form} phx-submit="send_message">
          <div class="flex flex-row gap-2">
            <div class="grow">
              <.input field={@form["text"]} value={@form.params["text"]} />
            </div>
            <.button class="mt-2">Send</.button>
          </div>
        </.simple_form>
      </div>
    </div>
    """
  end
end
