defmodule ChatDbEx.UpdateHookServer do
  @moduledoc """
  GenServer for managing the sqlite `chat.db` connection.
  """

  use GenServer

  alias Sqlitex.Server

  alias ChatDbEx.Config
  alias ChatDbEx.Listener

  @type state() :: %{config: Config.t()}

  @spec start_link(Keyword.t()) :: {:ok, pid()} | {:error, any()} | :ignore
  def start_link(opts \\ []) when is_list(opts) do
    GenServer.start_link(__MODULE__, cast_state(opts), name: __MODULE__)
  end

  @impl true
  @spec init(state()) :: {:ok, state()}
  def init(%{config: %Config{}} = state) do
    schedule_hooks(state)
    {:ok, state}
  end

  @impl true
  def handle_info(:schedule_hooks, state) do
    register_hooks(state)
    {:noreply, state}
  end

  @impl true
  def handle_info({action, table, rowid}, state) do
    Listener.handle({action, table, rowid})
    {:noreply, state}
  end

  @spec cast_state(Keyword.t()) :: state()
  def cast_state(opts) when is_list(opts) do
    case Keyword.get(opts, :config) do
      %Config{} = config -> %{config: config}
      _ -> %{config: Config.read()}
    end
  end

  defp schedule_hooks(%{config: %Config{chat_db_hook_interval_ms: chat_db_hook_interval_ms}}) do
    Process.send_after(self(), :schedule_hooks, chat_db_hook_interval_ms)
  end

  defp register_hooks(%{config: %Config{chat_db_module: chat_db_module}}) do
    Server.set_update_hook(chat_db_module, self())
  end
end
