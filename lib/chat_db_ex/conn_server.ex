defmodule ChatDbEx.ConnServer do
  @moduledoc """
  SQLite connector for the iMessage chatdb.
  """

  use GenServer

  alias ChatDbEx.Config
  alias ChatDbEx.SQLiteAdapter

  @adapter SQLiteAdapter
  @update_interval 1_000

  def start_link(opts \\ []) when is_list(opts) do
    config = Keyword.get(opts, :config, Config.read())
    sqlite = Keyword.get(opts, :sqlite, Sqlitex.Server)
    state = %{db: nil, config: config, sqlite: sqlite}
    GenServer.start_link(__MODULE__, state, [name: __MODULE__] ++ opts)
  end

  @impl true
  def init(%{db: nil, config: %Config{} = config, sqlite: sqlite} = state)
      when is_atom(sqlite) do
    # Process.flag(:trap_exit, true)

    server_pid = sqlite
    # server_pid = IMessageChatDB
    notification_pid = __MODULE__
    opts = []

    # sqlite.set_update_hook(server_pid, notification_pid, opts)
    # Sqlitex.Server.set_update_hook(IMessageChatDB, self())
    # Sqlitex.Server.set_update_hook(IMessageChatDB, ChatDbEx.ConnServer)

    # IMessageChatDB
    with {:ok, db} <- @adapter.connect(config) do
      # Sqlitex.Server.set_update_hook(db, self())
      # sqlite.set_update_hook(IMessageChatDB, self())
      # sqlite.set_update_hook(db, self())
      # IMessageChatDB.set_update_hook(db, self())
      # Sqlitex.Server.set_update_hook(IMessageChatDB, self())
      # Sqlitex.Server.set_update_hook(IMessageChatDB, db)

      Process.send_after(self(), :get_updates, @update_interval)

      {:ok, %{state | db: db}}
    end

    # {:ok, state}
  end

  def handle_info(:get_updates, db) do
    # get_updates(db)
    # db = IMessageChatDB
    # Sqlitex.Server.set_update_hook(db, self())
    # Sqlitex.Server.set_update_hook(IMessageChatDB, self())
    Sqlitex.Server.set_update_hook(IMessageChatDB, self())

    # IO.inspect(db: db)
    # IO.inspect(db: db)
    # IO.inspect(db: db)
    # IO.inspect(db: db)
    IO.inspect("get_updates")
    {:noreply, :calendar.local_time()}
  end

  # === INBOX ===
  def get_updates() do
    # db = IMessageChatDB
    # Sqlitex.Server.set_update_hook(db, self())
    # Sqlitex.Server.set_update_hook(IMessageChatDB, self())

    :ok
  end

  # def handle_call({:update_hook, {action, table, rowid}}, _from, state) do
  #   IO.inspect({action, table, rowid})
  #   {:reply, {action, table, rowid}, state}
  # end

  # def handle_call({action, table, rowid}, _from, state) do
  #   IO.inspect({action, table, rowid})
  #   {:reply, {action, table, rowid}, state}
  # end

  def handle_info({action, table, rowid}, _something) do
    IO.inspect({action, table, rowid})
    # {:reply, {action, table, rowid}, state}
    {:noreply, nil}
  end

  # def handle_info(:update_hook, {action, table, rowid}) do
  #   IO.inspect({action, table, rowid})
  #   # {:reply, {action, table, rowid}, state}
  #   {:noreply, nil}
  # end

  @impl true
  def handle_call(:db, _from, state) do
    {:reply, state.db, state}
  end

  @impl true
  def handle_call({:execute, fun}, _from, state) when is_function(fun, 1) do
    {:reply, fun.(state.db), state}
  end

  @impl true
  def handle_cast({:register_listener, {pid, opts}}, state) do
    with :ok <- @adapter.register_update_hook(state.db, pid, opts) do
      {:noreply, state}
    end
  end

  @impl true
  def handle_info({:EXIT, _pid, :client_down}, state) do
    @adapter.disconnect(state.db)
    {:noreply, state}
  end
end
