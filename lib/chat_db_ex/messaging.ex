defmodule ChatDbEx.Messaging do
  @moduledoc """
  Context for the SQLite repo calls.
  """

  alias ChatDbEx.SQLiteQueries

  def last_message do
    sql = SQLiteQueries.sql(:last_message)
    count(sql)
  end

  def last_message_at(%{rowid: rowid}) do
    sql = SQLiteQueries.sql(:last_message_at, %{rowid: rowid})
    query(sql)

    with {:ok, [[utc_datetime: utc_datetime]]} when is_binary(utc_datetime) <- query(sql) do
      # DateTime.from_iso8601(utc_datetime)
      {:ok, utc_datetime}
    end
  end

  def last_message_text(%{rowid: rowid}) do
    sql = SQLiteQueries.sql(:last_message_text, %{rowid: rowid})

    with {:ok, [[text: text]]} when is_binary(text) <- query(sql) do
      {:ok, text}
    end
  end

  def last_message(%{rowid: rowid}) do
    sql = SQLiteQueries.sql(:last_message, %{rowid: rowid})
    count(sql)
  end

  def chat_messages_count(%{rowid: rowid}) do
    sql = SQLiteQueries.sql(:chat_messages_count, %{rowid: rowid})
    count(sql)
  end

  def chats_since(%{rowid: rowid}) do
    sql = SQLiteQueries.sql(:chats_since, %{rowid: rowid})
    query(sql)
  end

  def messages_since(%{rowid: rowid}) do
    sql = SQLiteQueries.sql(:messages_since, %{rowid: rowid})
    query(sql)
  end

  def attachments_since(%{rowid: rowid}) do
    sql = SQLiteQueries.sql(:attachments_since, %{rowid: rowid})
    query(sql)
  end

  def query(sql) do
    Sqlitex.Server.query(ChatDbEx.IMessageChatDB, sql)
  end

  def count(sql) do
    with {:ok, [[count: count]]} when is_integer(count) <-
           Sqlitex.Server.query(ChatDbEx.IMessageChatDB, sql) do
      {:ok, count}
    end
  end
end
