defmodule Mix.Tasks.ChatDb.ImportDb do
  @moduledoc """
  Use `pgloader` to import chat db.

  ## Usage

      ```shell
      mix chat_db.import_db --path ~/Library/Messages/chat.db --table chitter_dev
      ```
  """
  @shortdoc "Use `pgloader` to import chat db."

  use Mix.Task

  alias ChatDb.Config

  @tmp_file_path "pgloader_tmp_script"

  @opts [
    strict: [
      path: :string,
      table: :string
    ]
  ]

  @impl Mix.Task
  def run(args) do
    args
    |> opts!()
    |> execute()
  end

  def opts!(args) do
    case OptionParser.parse!(args, @opts) do
      {opts, []} -> opts
    end
  end

  defp template(opts) do
    path = Keyword.get(opts, :path, Config.default_chat_db_path())
    table = Keyword.fetch!(opts, :table)

    """
    LOAD database
    FROM sqlite://#{Path.expand(path)}
    INTO postgresql:///#{table}

    WITH include drop, create tables, create indexes, reset sequences

    SET work_mem to '16MB', maintenance_work_mem to '512 MB';
    """
  end

  defp execute(opts) do
    :ok = File.write!(@tmp_file_path, template(opts))

    case System.cmd("pgloader", [@tmp_file_path]) do
      {_, _} -> :ok
    end

    :ok = File.rm!(@tmp_file_path)
  end
end
