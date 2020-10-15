defmodule ChatDB.Listener do
  @moduledoc """
  SQLite connector for the iMessage chatdb.
  """

  # alias Phoenix.PubSub

  alias ChatDB

  require Logger

  @actions [:insert, :update, :delete]
  @topic "user:*"

  @type action() :: :insert | :update | :delete
  @type table() :: iolist()
  @type rowid() :: any()

  @doc """
  Sets a PID to recieve notifications about table updates.
  Messages will come in the shape of:
  `{action, table, rowid}`
  * `action` -> `:insert | :update | :delete`
  * `table` -> charlist of the table name. Example: `'posts'`
  * `rowid` -> internal immutable rowid index of the row.
               This is *NOT* the `id` or `primary key` of the row.
  See the [official docs](https://www.sqlite.org/c3ref/update_hook.html).
  """
  @spec handle({action(), table(), rowid()}) :: :ok | :ignore
  def handle({:insert, 'chat', rowid}) do
    # chat = ChatDB.get_chat_by_rowid(rowid)
    chat = rowid
    broadcast({:new_chat, chat})
  end

  def handle({:insert, 'message', rowid}) do
    # message = ChatDB.get_message_by_rowid(rowid)
    message = rowid
    broadcast({:new_message, message})
  end

  def handle({action, table, rowid})
      when action in @actions and is_list(table) do
    broadcast({:unhandled, %{action: action, table: table, rowid: rowid}})
    :ignore
  end

  defp broadcast({event, payload}) when is_atom(event) and is_map(payload) do
    # :ok = PubSub.broadcast(__MODULE__, @topic, {event, payload})
    Logger.info("""
    #{IO.ANSI.cyan()}
    #{inspect(event, pretty: true)}

    #{inspect(payload, pretty: true)}
    """)

    :ok
  end
end
