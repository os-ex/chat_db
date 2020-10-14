defmodule ChatDbEx.Config do
  @moduledoc """
  Application config.
  """

  # @priv_dir :code.priv_dir(:chat_db_ex)

  # defstruct chat_db_path: Path.join(@priv_dir, 'db/Messages/chat.db'),
  # defstruct chat_db_path: 'priv/db/Messages/chat.db',

  defstruct chat_db_path: '/home/sitch/sites/imessagex/db/Messages/chat.db',
            exported_vcards_filename: "priv/contacts.vcf",
            exported_jcards_filename: "priv/contacts-ical-jcards.json",
            contacts_json: "",
            contact_cache_dir: "",
            photo_cache_dir: "",
            chat_db_opts: []

  @type t() :: %__MODULE__{
          chat_db_path: iolist(),
          exported_vcards_filename: String.t(),
          exported_jcards_filename: String.t(),
          contacts_json: String.t(),
          contact_cache_dir: String.t(),
          photo_cache_dir: String.t(),
          chat_db_opts: Keyword.t()
        }

  @doc """
  Build a config from env.
  """
  @spec read :: t()
  def read do
    struct(__MODULE__, read_env())
  end

  @spec read_env :: %{required(:atom) => any()}
  defp read_env do
    :chat_db_path_ex
    |> Application.get_all_env()
    |> Enum.into(%{})
  end
end
