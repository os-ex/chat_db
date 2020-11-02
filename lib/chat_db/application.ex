defmodule ChatDb.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  import Supervisor.Spec

  alias ChatDb.Config

  @impl true
  @spec start(any(), any()) :: {:ok, pid()} | {:error, any()}
  def start(_type, _args) do
    config = Config.read()

    children =
      [
        # Starts a worker by calling: ChatDb.Worker.start_link(arg)
        # {ChatDb.Worker, arg}
      ] ++ chat_db_spec(config)

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ChatDb.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @spec chat_db_spec(Config.t()) :: [Supervisor.Spec.t()] | no_return()
  defp chat_db_spec(%Config{} = config) do
    unless Config.valid_chat_db?(config) do
      raise RuntimeError, """
      #{IO.ANSI.reset()}

      #{IO.ANSI.green()}
      #{inspect(__MODULE__)}
          #{IO.ANSI.blue()}
          Missing `chat.db` SQLite database file
          #{IO.ANSI.reset()}#{IO.ANSI.red()}
          :chat_db_path#{IO.ANSI.reset()} does not contain a valid SQLite file.

      #{IO.ANSI.white()}
      Config:

      #{IO.ANSI.reset()}
      #{inspect(config, pretty: true)}
      """
    end

    [
      # %{
      #   id: ChatDb.ConnServer,
      #   name: ChatDb.ConnServer,
      #   # start: {ChatDb.ConnServer, :start_link, [[sqlite: ChatDb.DB, config: config]]}
      #   start: {ChatDb.ConnServer, :start_link, [[config: config]]}
      # },
      # %{
      #   id: Sqlitex.Server,
      #   name: ChatDb.DB,
      #   name: IMessageChatDb,
      #   start: {Sqlitex.Server, :start_link, [chat_db_path]}
      # }

      worker(Sqlitex.Server, [to_charlist(config.chat_db_path), [name: ChatDb.IMessageChatDb]]),
      {ChatDb.Server.UpdateHooks, [config: config]}
    ]
  end
end
