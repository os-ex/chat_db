defmodule ChatDbEx.Listener do
  @moduledoc """
  SQLite connector for the iMessage chatdb.
  """

  alias Phoenix.PubSub

  alias ChatDbEx

  @actions [:insert, :update, :delete]
  @topic "user:*"

  @type action() :: :insert | :update | :delete
  @type table() :: iolist()
  @type rowid() :: iolist()

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
  @spec handle(:update_hook, {action(), table(), rowid()}) :: :ok | :ignore
  def handle(:update_hook, {:insert, 'chat', rowid}) when is_list(rowid) do
    chat = ChatDB.get_chat_by_rowid(rowid)
    broadcast({:new_chat, chat})
  end

  def handle(:update_hook, {:insert, 'message', rowid}) when is_list(rowid) do
    message = ChatDB.get_message_by_rowid(rowid)
    broadcast({:new_message, message})
  end

  def handle(:update_hook, {action, table, rowid})
      when action in @actions and is_list(table) and is_list(rowid) do
    :ignore
  end

  defp broadcast({event, payload}) when is_atom(event) and is_map(payload) do
    :ok = PubSub.broadcast(__MODULE__, @topic, {event, payload})
    :ok
  end
end
