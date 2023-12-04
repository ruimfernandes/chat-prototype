defmodule ChatPrototype.Server do
  alias ChatPrototype.Server.Room

  @spec start_link() :: :ignore | {:error, any()} | {:ok, pid()}
  def start_link() do
    DynamicSupervisor.start_link(name: __MODULE__, strategy: :one_for_one)
  end

  @spec child_spec(any()) :: %{
          id: ChatPrototype.Server,
          start: {ChatPrototype.Server, :start_link, []},
          type: :supervisor
        }
  def child_spec(_arg) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, []},
      type: :supervisor
    }
  end

  @spec start_room(String.t()) :: %{name: String.t(), pid: binary()}
  def start_room(name) do
    case start_child(name) do
      {:ok, pid} -> %{name: name, pid: pid_to_string(pid)}
      {:error, {:already_started, pid}} -> %{name: name, pid: pid_to_string(pid)}
    end
  end

  @spec list_rooms() :: list()
  def list_rooms() do
    __MODULE__
    |> DynamicSupervisor.which_children()
    |> Enum.map(fn {_, pid, _, _} ->
      {_, name} = ChatPrototype.ProcessRegistry |> Registry.keys(pid) |> List.first()

      Room.get_room_details(name)
    end)
  end

  @spec start_child(String.t()) :: :ignore | {:error, any()} | {:ok, pid()} | {:ok, pid(), any()}
  defp start_child(name) do
    DynamicSupervisor.start_child(__MODULE__, {ChatPrototype.Server.Room, name})
  end

  @spec pid_to_string(pid()) :: String.t()
  defp pid_to_string(pid) do
    pid
    |> :erlang.pid_to_list()
    |> List.delete_at(0)
    |> List.delete_at(-1)
    |> to_string()
  end
end
