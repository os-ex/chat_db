defmodule ChatDbEx.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  import Supervisor.Spec

  alias ChatDbEx.Config

  @impl true
  def start(_type, _args) do
    config = Config.read()

    children =
      [
        # Starts a worker by calling: ChatDbEx.Worker.start_link(arg)
        # {ChatDbEx.Worker, arg}
      ] ++ chat_db_spec(config)

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ChatDbEx.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp chat_db_spec(%Config{chat_db_path: chat_db_path} = config) do
    unless File.exists?(chat_db_path) do
      raise RuntimeError, """
      `:chat_db_path` does not contain a valid SQLite file.
      """
    end

    [
      # %{
      #   id: ChatDbEx.ConnServer,
      #   name: ChatDbEx.ConnServer,
      #   # start: {ChatDbEx.ConnServer, :start_link, [[sqlite: ChatDbEx.DB, config: config]]}
      #   start: {ChatDbEx.ConnServer, :start_link, [[config: config]]}
      # },
      # %{
      #   id: Sqlitex.Server,
      #   name: ChatDbEx.DB,
      #   name: IMessageChatDB,
      #   start: {Sqlitex.Server, :start_link, [to_charlist(chat_db_path)]}
      # }

      {ChatDbEx.ConnServer, [config: config]},
      worker(Sqlitex.Server, [
        to_charlist(chat_db_path),
        [name: IMessageChatDB]
      ])
    ]
  end
end
