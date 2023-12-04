defmodule ChatPrototype.Server.Room do
  use GenServer, restart: :temporary

  @spec start_link(String.t()) ::
          {:ok, pid()} | :ignore | {:error, {:already_started, pid()} | term()}
  def start_link(name) do
    GenServer.start_link(ChatPrototype.Server.Room, name, name: via_tuple(name))
  end

  @spec add_message(String.t(), map()) :: :ok
  def add_message(name, new_message) do
    GenServer.cast(via_tuple(name), {:add_message, new_message})
  end

  @spec get_messages(String.t()) :: list()
  def get_messages(name) do
    GenServer.call(via_tuple(name), :get_messages)
  end

  @spec get_room_details(String.t()) :: map()
  def get_room_details(name) do
    GenServer.call(via_tuple(name), :get_room_details)
  end

  @spec via_tuple(String.t()) :: {:via, Registry, {ChatPrototype.ProcessRegistry, String.t()}}
  defp via_tuple(name) do
    ChatPrototype.ProcessRegistry.via_tuple({__MODULE__, name})
  end

  @impl GenServer
  def init(name) do
    room = %{
      uuid: UUID.uuid4(),
      name: name
    }

    ChatPrototypeWeb.Endpoint.subscribe(room.uuid)
    {:ok, {room, []}}
  end

  @impl GenServer
  def handle_cast({:add_message, new_message}, {room, messages} = _state) do
    new_messages_list = Enum.concat(messages, [new_message])
    {:noreply, {room, new_messages_list}}
  end

  @impl GenServer
  def handle_call(:get_messages, _from, {_room, messages} = state) do
    {
      :reply,
      messages,
      state
    }
  end

  @impl GenServer
  def handle_call(:get_room_details, _from, {room, _messages} = state) do
    {
      :reply,
      room,
      state
    }
  end

  @impl GenServer
  def handle_info(%{event: "new-message", payload: message}, {room, messages} = _state) do
    new_messages_list = Enum.concat(messages, [message])
    {:noreply, {room, new_messages_list}}
  end

  @impl GenServer
  def handle_info(
        %{event: "presence_diff", payload: %{joins: user_joining, leaves: user_leaving}},
        {room, messages} = _state
      ) do
    join_message =
      user_joining
      |> Map.keys()
      |> Enum.map(fn username ->
        %{uuid: UUID.uuid4(), user: username, text: "#{username} joinned the chat."}
      end)

    leave_message =
      user_leaving
      |> Map.keys()
      |> Enum.map(fn username ->
        %{uuid: UUID.uuid4(), user: username, text: "#{username} left the chat."}
      end)

    new_message = Enum.concat(join_message, leave_message)

    new_messages_list = Enum.concat(messages, new_message)
    {:noreply, {room, new_messages_list}}
  end
end
