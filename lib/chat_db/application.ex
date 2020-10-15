defmodule ChatDB.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  import Supervisor.Spec

  alias ChatDB.Config

  @impl true
  @spec start(any(), any()) :: {:ok, pid()} | {:error, any()}
  def start(_type, _args) do
    config = Config.read()

    children =
      [
        # Starts a worker by calling: ChatDB.Worker.start_link(arg)
        # {ChatDB.Worker, arg}
      ] ++ chat_db_spec(config)

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ChatDB.Supervisor]
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
      #   id: ChatDB.ConnServer,
      #   name: ChatDB.ConnServer,
      #   # start: {ChatDB.ConnServer, :start_link, [[sqlite: ChatDB.DB, config: config]]}
      #   start: {ChatDB.ConnServer, :start_link, [[config: config]]}
      # },
      # %{
      #   id: Sqlitex.Server,
      #   name: ChatDB.DB,
      #   name: IMessageChatDB,
      #   start: {Sqlitex.Server, :start_link, [chat_db_path]}
      # }

      worker(Sqlitex.Server, [to_charlist(config.chat_db_path), [name: ChatDB.IMessageChatDB]]),
      {ChatDB.Server.UpdateHooks, [config: config]}
    ]
  end
end
