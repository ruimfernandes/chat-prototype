defmodule ChatPrototype.Server do
  def start_link() do
    DynamicSupervisor.start_link(name: __MODULE__, strategy: :one_for_one)
  end

  def child_spec(_arg) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, []},
      type: :supervisor
    }
  end

  def start_room(room_name) do
    case start_child(room_name) do
      {:ok, pid} -> %{name: room_name, pid: pid_to_string(pid)}
      {:error, {:already_started, pid}} -> %{name: room_name, pid: pid_to_string(pid)}
    end
  end

  def list_rooms() do
    __MODULE__
    |> DynamicSupervisor.which_children()
    |> Enum.map(fn {_, pid, _, _} ->
      {_, name} = ChatPrototype.ProcessRegistry |> Registry.keys(pid) |> List.first()
      %{pid: pid_to_string(pid), name: name}
    end)
  end

  defp start_child(room_name) do
    DynamicSupervisor.start_child(__MODULE__, {ChatPrototype.Server.Room, room_name})
  end

  defp pid_to_string(pid) do
    pid
    |> :erlang.pid_to_list()
    |> List.delete_at(0)
    |> List.delete_at(-1)
    |> to_string()
  end
end
