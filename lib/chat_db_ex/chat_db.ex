defmodule ChatDbEx.ChatDB do
  @moduledoc """
  Context for the chat db.
  """

  alias ChatDbEx.Queries
  alias ChatDbEx.SQLiteAdapter

  @adapter SQLiteAdapter

  def get_chat_by_rowid(rowid) when is_binary(rowid) do
    {:get_chat_by_rowid, rowid}
    |> Queries.query()
    |> @adapter.execute()
  end

  def get_message_by_rowid(rowid) when is_binary(rowid) do
    {:get_message_by_rowid, rowid}
    |> Queries.query()
    |> @adapter.execute()
  end
end
