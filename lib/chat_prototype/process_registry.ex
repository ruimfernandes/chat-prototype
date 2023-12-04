defmodule ChatPrototype.ProcessRegistry do
  @spec start_link() :: {:error, any()} | {:ok, pid()}
  def start_link do
    Registry.start_link(keys: :unique, name: __MODULE__)
  end

  @spec via_tuple(String.t() | {atom(), String.t()}) ::
          {:via, Registry, {ChatPrototype.ProcessRegistry, String.t()}}
  def via_tuple(key) do
    {:via, Registry, {__MODULE__, key}}
  end

  @spec child_spec(any()) :: %{
          :id => any(),
          :start => {atom(), atom(), list()},
          optional(:modules) => :dynamic | [atom()],
          optional(:restart) => :permanent | :temporary | :transient,
          optional(:shutdown) => :brutal_kill | :infinity | non_neg_integer(),
          optional(:significant) => boolean(),
          optional(:type) => :supervisor | :worker
        }
  def child_spec(_) do
    Supervisor.child_spec(
      Registry,
      id: __MODULE__,
      start: {__MODULE__, :start_link, []}
    )
  end
end
