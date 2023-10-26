defmodule ChatPrototypeWeb.WelcomeLive do
  use ChatPrototypeWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       stage: :rooms_list,
       user_name: get_random_name(),
       form: to_form(%{"user_name" => ""})
     )}
  end

  def render(assigns) do
    case assigns.stage do
      :welcome ->
        render_welcome_menu(assigns)

      :rooms_list ->
        ~H"""
        <div>
          <.live_component
            module={ChatPrototypeWeb.RoomsListLive}
            id="rooms_list"
            user_name={assigns.user_name}
          />
        </div>
        """
    end
  end

  def render_welcome_menu(assigns) do
    ~H"""
    <div>
      <p class="text-2xl">Welcome to chat</p>

      <.simple_form class="mt-40" for={@form} phx-submit="sign_in">
        <b> Please set your username </b>
        <p>User name: <.input field={@form["user_name"]} value={@form.params["user_name"]} /></p>
        <.button>Sign in</.button>
      </.simple_form>
    </div>
    """
  end

  def handle_event("sign_in", %{"user_name" => user_name}, socket) do
    {:noreply,
     assign(socket,
       stage: :rooms_list,
       user_name: user_name
     )}
  end

  def handle_info(%{event: "new-message", payload: message, topic: room_id}, socket) do
    send_update(ChatPrototypeWeb.ChatRoomLive, id: room_id, new_messages: [message])

    {:noreply, socket}
  end

  def handle_info(%{event: "presence_diff", payload: %{joins: joins, leaves: leaves}, topic: room_id}, socket) do
    join_message = joins |> Map.keys() |> Enum.map(fn username -> %{uuid: UUID.uuid4(), user: username, text: "#{username} joinned the chat."} end)

    leave_message = leaves |> Map.keys() |> Enum.map(fn username -> %{uuid: UUID.uuid4(), user: username, text: "#{username} left the chat."} end)

    send_update(ChatPrototypeWeb.ChatRoomLive, id: room_id, new_messages: Enum.concat(join_message, leave_message))

    {:noreply, socket}
  end

  def get_random_name() do
    names_list = [
      "Maria",
      "Alice",
      "Leonor",
      "Matilde",
      "Benedita",
      "Carolina",
      "Beatriz",
      "Margarida",
      "Francisca",
      "Camila",
      "Francisco",
      "Afonso",
      "João",
      "Tomás",
      "Duarte",
      "Lourenço",
      "Santiago",
      "Martim",
      "Miguel",
      "Gabriel"
    ]

    random_index = :rand.uniform(20) - 1

    Enum.at(names_list, random_index)
  end
end
