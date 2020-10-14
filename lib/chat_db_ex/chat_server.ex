defmodule ChatDbEx.ChatServer do
  @moduledoc """
  GenServer for managing the sqlite `chat.db` connection.
  """

  use GenServer

  alias ChatDbEx.Config

  @update_interval 1_000

  alias ChatDbEx.Listener

  def start_link(opts \\ []) when is_list(opts) do
    config = Keyword.get(opts, :config, Config.read())
    state = %{config: config}
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  @impl true
  def init(%{config: %Config{} = _config} = state) do
    Process.send_after(self(), :register_update_hook, @update_interval)
    {:ok, state}
  end

  @impl true
  def handle_info(:register_update_hook, state) do
    Sqlitex.Server.set_update_hook(IMessageChatDB, self())
    {:noreply, state}
  end

  @impl true
  def handle_info({action, table, rowid}, state) do
    Listener.handle(:update_hook, {action, table, rowid})
    {:noreply, state}
  end

  # === INBOX ===
  def register_update_hook() do
    :ok
  end
end
