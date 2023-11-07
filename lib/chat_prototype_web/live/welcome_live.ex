defmodule ChatPrototypeWeb.WelcomeLive do
  use ChatPrototypeWeb, :live_view

  @impl true
  @spec mount(map(), map(), Socket.t()) :: {:ok, Socket.t()}
  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       stage: :rooms_list,
       user_name: get_random_name(),
       #  stage: :welcome,
       #  user_name: "",
       form: to_form(%{"user_name" => ""}),
       all_rooms: [
         %{uuid: "room-0", name: "Main Room"},
         %{uuid: "room-1", name: "Football"},
         %{uuid: "room-2", name: "Rugbi"},
         %{uuid: "room-3", name: "Surf"}
       ],
       selected_room: %{uuid: "room-0", name: "Main Room", unread_messages_count: 0},
       active_rooms: [%{uuid: "room-0", name: "Main Room", unread_messages_count: 0}]
     )}
  end

  @impl true
  @spec render(Socket.assigns()) :: Phoenix.LiveView.Rendered.t()
  def render(assigns) do
    case assigns.stage do
      :welcome ->
        render_welcome_menu(assigns)

      :rooms_list ->
        ~H"""
        <div class="flex flex-row bg-red-500">
          <div class="flex flex-col gap-8 bg-zinc-800 max-w-s p-2">
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
          <div class="bg-zinc-600 grow p-10">
            <%= if @selected_room.uuid == "room-0" do %>
              <.render_main_room assigns={assigns} />
            <% else %>
              <.live_component
                module={ChatPrototypeWeb.ChatRoomLive}
                id={@selected_room.uuid}
                name={@selected_room.name}
              />
            <% end %>
          </div>
        </div>
        """
    end
  end

  @impl true
  @spec handle_event(binary(), map(), Socket.t()) :: {:noreply, Socket.t()}
  def handle_event("sign_in", %{"user_name" => user_name}, socket) do
    {:noreply,
     assign(socket,
       stage: :rooms_list,
       user_name: user_name
     )}
  end

  def handle_event("join_room", %{"id" => room_uuid}, socket) do
    active_room =
      find_room_in_rooms_list(socket.assigns.all_rooms, room_uuid)
      |> Map.merge(%{unread_messages_count: 0})

    new_active_rooms_list = Enum.concat(socket.assigns.active_rooms, [active_room])

    subscribe_room(room_uuid, new_active_rooms_list, socket.assigns.user_name)

    {:noreply, assign(socket, active_rooms: new_active_rooms_list)}
  end

  def handle_event("select_room", %{"id" => room_id}, socket) do
    selected_room =
      find_room_in_rooms_list(socket.assigns.active_rooms, room_id)

    active_rooms =
      Enum.map(socket.assigns.active_rooms, fn room ->
        if room.uuid == room_id do
          %{room | unread_messages_count: 0}
        else
          room
        end
      end)

    # TODO: we need to pull the history and send update
    # room_messages = []

    {:noreply, assign(socket, active_rooms: active_rooms, selected_room: selected_room)}
  end

  def handle_event("send_message", %{"text" => text}, socket) do
    ChatPrototypeWeb.Endpoint.broadcast(socket.assigns.selected_room.uuid, "new-message", %{
      uuid: UUID.uuid4(),
      user: socket.assigns.user_name,
      text: text
    })

    {:noreply, socket}
  end

  @impl true
  @spec handle_info(
          %{
            :event => String.t(),
            :payload => map(),
            :topic => String.t()
          },
          Socket.t()
        ) :: {:noreply, Socket.t()}
  def handle_info(%{event: "new-message", payload: message, topic: room_id}, socket) do
    if socket.assigns.selected_room.uuid == room_id do
      send_update(ChatPrototypeWeb.ChatRoomLive, id: room_id, new_messages: [message])
      {:noreply, socket}
    else
      active_rooms =
        Enum.map(socket.assigns.active_rooms, fn room ->
          if room.uuid == room_id do
            unread_messages_count = room.unread_messages_count + 1
            %{room | unread_messages_count: unread_messages_count}
          else
            room
          end
        end)

      {:noreply, assign(socket, active_rooms: active_rooms)}
    end
  end

  def handle_info(
        %{event: "presence_diff", payload: %{joins: joins, leaves: leaves}, topic: room_id},
        socket
      ) do
    join_message =
      joins
      |> Map.keys()
      |> Enum.map(fn username ->
        %{uuid: UUID.uuid4(), user: username, text: "#{username} joinned the chat."}
      end)

    leave_message =
      leaves
      |> Map.keys()
      |> Enum.map(fn username ->
        %{uuid: UUID.uuid4(), user: username, text: "#{username} left the chat."}
      end)

    send_update(ChatPrototypeWeb.ChatRoomLive,
      id: room_id,
      new_messages: Enum.concat(join_message, leave_message)
    )

    {:noreply, socket}
  end

  @spec render_main_room(Socket.assigns()) :: Phoenix.LiveView.Rendered.t()
  defp render_main_room(%{assigns: assigns}) do
    ~H"""
    <div>
      <p class="text-4xl">Welcome to this chat app!</p>
      <p class="text-xl mt-4">Feel free to join any of the rooms below</p>
      <div id="main-room" class="flex flex-col gap-4 mt-4">
        <%= for room <- @all_rooms do %>
          <%= if is_uuid_in_rooms_list?(@active_rooms, room.uuid) do %>
            <p><%= room.name %> (already joinned)</p>
          <% else %>
            <.button phx-click="join_room" id={"join-#{room.uuid}"} phx-value-id={room.uuid}>
              <%= room.name %>
            </.button>
          <% end %>
        <% end %>
      </div>
    </div>
    """
  end

  @spec render_welcome_menu(Socket.assigns()) :: Phoenix.LiveView.Rendered.t()
  defp render_welcome_menu(assigns) do
    ~H"""
    <div>
      <p class="text-2xl">Welcome to chat</p>

      <.simple_form id="login_form" class="mt-40" for={@form} phx-submit="sign_in">
        <b>Please set your username</b>
        <p>User name: <.input field={@form["user_name"]} value={@form.params["user_name"]} /></p>
        <.button>Sign in</.button>
      </.simple_form>
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

  @spec get_random_name() :: String.t()
  defp get_random_name() do
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

  @spec subscribe_room(String.t(), list(), String.t()) :: any()
  defp subscribe_room(room_uuid, active_rooms, user_name) do
    if(is_uuid_in_rooms_list?(active_rooms, room_uuid)) do
      ChatPrototypeWeb.Endpoint.subscribe(room_uuid)
      ChatPrototypeWeb.Presence.track(self(), room_uuid, user_name, %{})
    end
  end

  @spec find_room_in_rooms_list(list(), String.t()) :: String.t() | nil
  defp find_room_in_rooms_list(list, uuid) do
    Enum.find(list, fn room -> room.uuid == uuid end)
  end

  @spec find_room_in_rooms_list(list(), String.t()) :: boolean()
  defp is_uuid_in_rooms_list?(list, uuid) do
    Enum.any?(list, fn room -> room.uuid == uuid end)
  end
end
