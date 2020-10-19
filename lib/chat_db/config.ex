defmodule ChatDB.Config do
  @moduledoc """
  Application config.
  """

  @type filepath() :: String.t()
  @type update_hook_mfa() :: {module(), fun :: atom()} | :noop

  # @priv_dir :code.priv_dir(:chat_db)

  # defstruct chat_db_path: Path.join(@priv_dir, 'db/Messages/chat.db'),
  # defstruct chat_db_path: '/home/sitch/sites/imessagex/db/Messages/chat.db',
  defstruct [
    # ChatDB
    # chat_db_path: "~/Library/Messages/chat.db",
    chat_db_path: "priv/db/Messages/chat.db",
    update_hook_mfa: :noop,
    update_hook_wait_ms: 1_000,

    # Contacts
    import_vcards_path: "priv/contacts.vcf",
    export_jcards_path: "priv/contacts-ical-jcards.json",
    export_contacts_json_path: "priv/chat-db-contacts.json"

    # contacts_json: "",
    # defstruct chat_db_path: '/Users/sitch/Library/Messages/chat.db',
    # contact_cache_dir: "",
    # photo_cache_dir: ""
  ]

  @type t() :: %__MODULE__{
          chat_db_path: filepath(),
          update_hook_mfa: update_hook_mfa(),
          update_hook_wait_ms: pos_integer(),
          import_vcards_path: filepath(),
          export_jcards_path: filepath(),
          export_contacts_json_path: filepath()
          # contact_cache_dir: String.t(),
          # chat_db_module: module(),
          # photo_cache_dir: String.t(),
        }

  @doc """
  Build a config from env.
  """
  @spec read() :: t()
  def read do
    __MODULE__ |> struct(read_env()) |> format()
  end

  defp format(%__MODULE__{} = struct) do
    %{struct | chat_db_path: Path.expand(struct.chat_db_path)}
  end

  @spec read_env() :: %{required(:atom) => any()}
  defp read_env do
    :chat_db_path_ex
    |> Application.get_all_env()
    # |> Enum.reject(fn {_k, v} -> v in [nil, ""] end)
    |> Enum.into(%{})
  end

  def valid_chat_db?(%__MODULE__{chat_db_path: chat_db_path}) do
    File.exists?(chat_db_path)
  end
end
