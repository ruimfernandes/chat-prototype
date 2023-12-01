defmodule ChatPrototype.Server.Room do
  use GenServer, restart: :temporary

  def start_link(name) do
    IO.inspect(name, label: "Started a process for")
    GenServer.start_link(ChatPrototype.Server.Room, name, name: via_tuple(name))
  end

  def add_message(room, new_message) do
    GenServer.cast(via_tuple(room), {:add_message, new_message})
  end

  def get_messages(room) do
    GenServer.call(via_tuple(room), :messages)
  end

  defp via_tuple(name) do
    ChatPrototype.ProcessRegistry.via_tuple({__MODULE__, name})
  end

  @impl GenServer
  def init(name) do
    ChatPrototypeWeb.Endpoint.subscribe(name)
    {:ok, {name, []}}
  end

  @impl GenServer
  def handle_cast({:add_message, new_message}, {name, messages} = _state) do
    new_messages_list = Enum.concat(messages, [new_message])
    {:noreply, {name, new_messages_list}}
  end

  @impl GenServer
  def handle_call(:messages, _from, {name, messages} = _state) do
    {
      :reply,
      messages,
      {name, messages}
    }
  end

  @impl GenServer
  def handle_info(%{event: "new-message", payload: message}, {name, messages} = _state) do
    new_messages_list = Enum.concat(messages, [message])
    {:noreply, {name, new_messages_list}}
  end

  @impl GenServer
  def handle_info(
        %{event: "presence_diff", payload: %{joins: user_joining, leaves: user_leaving}},
        {name, messages} = _state
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
    {:noreply, {name, new_messages_list}}
  end
end
