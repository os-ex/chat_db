defmodule ChatDB.Config do
  @moduledoc """
  Application config.
  """

  # @priv_dir :code.priv_dir(:chat_db)

  # defstruct chat_db_path: Path.join(@priv_dir, 'db/Messages/chat.db'),
  # defstruct chat_db_path: '/home/sitch/sites/imessagex/db/Messages/chat.db',
  # defstruct chat_db_path: 'priv/db/Messages/chat.db',
  defstruct chat_db_path: '/Users/michaelsitchenko/Library/Messages/chat.db',
            # defstruct chat_db_path: '~/Library/Messages/chat.db',
            exported_vcards_filename: "priv/contacts.vcf",
            exported_jcards_filename: "priv/contacts-ical-jcards.json",
            contacts_json: "",
            contact_cache_dir: "",
            chat_db_module: ChatDB.IMessageChatDB,
            photo_cache_dir: "",
            register_hook_delay_ms: 1000,
            chat_db_opts: [],
            update_handler_mfa: :noop

  @type t() :: %__MODULE__{
          chat_db_path: iolist(),
          exported_vcards_filename: String.t(),
          exported_jcards_filename: String.t(),
          contacts_json: String.t(),
          contact_cache_dir: String.t(),
          chat_db_module: module(),
          photo_cache_dir: String.t(),
          register_hook_delay_ms: pos_integer(),
          chat_db_opts: Keyword.t(),
          update_handler_mfa: {module(), fun :: atom()} | :noop
        }

  @doc """
  Build a config from env.
  """
  @spec read :: t()
  def read do
    __MODULE__ |> struct(read_env()) |> format()
  end

  defp format(%__MODULE__{} = struct) do
    %{struct | chat_db_path: to_charlist(struct.chat_db_path)}
  end

  @spec read_env :: %{required(:atom) => any()}
  defp read_env do
    :chat_db_path_ex
    |> Application.get_all_env()
    |> Enum.into(%{})
  end

  def valid_chat_db?(%__MODULE__{chat_db_path: chat_db_path}) do
    File.exists?(chat_db_path)
  end
end
