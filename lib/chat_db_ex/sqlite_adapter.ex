defmodule ChatDbEx.SQLiteAdapter do
  @moduledoc """
  SQLite adapter for the iMessage chatdb.
  """

  alias ChatDbEx.Config

  @spec connect(Config.t()) :: {:ok, Sqlitex.connection()} | {:error, any()}
  def connect(%Config{chat_db_path: chat_db_path, chat_db_opts: chat_db_opts}) do
    Sqlitex.open(chat_db_path, chat_db_opts)
  end

  @spec disconnect(Sqlitex.connection()) :: :ok
  def disconnect({:connection, _reference, _term} = conn) do
    Sqlitex.close(conn)
  end

  @spec query(Sqlitex.connection(), String.t(), Keyword.t()) ::
          {:ok, [Keyword.t()]} | {:error, term()}
  def query({:connection, _reference, _term} = conn, query, opts \\ [])
      when is_binary(query) do
    Sqlitex.query(conn, query, opts)
  end

  @spec execute(Config.t(), String.t(), Keyword.t()) :: any()
  def execute(%Config{chat_db_path: chat_db_path}, query, opts \\ []) when is_binary(query) do
    Sqlitex.with_db(chat_db_path, fn conn ->
      Sqlitex.query(conn, query, opts)
    end)
  end

  @spec register_update_hook(Sqlitex.connection(), pid(), Keyword.t()) :: :ok | {:error, any()}
  def register_update_hook({:connection, _reference, _term} = conn, pid, opts \\ [])
      when is_pid(pid) and is_list(opts) do
    Sqlitex.set_update_hook(conn, pid, opts)
  end
end
