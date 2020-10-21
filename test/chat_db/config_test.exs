defmodule ChatDB.ConfigTest do
  @moduledoc false

  use ExUnit.Case, async: true

  alias ChatDB.Config

  describe ".read/0" do
    test "it returns valid defaults" do
      assert Config.read() == %Config{
               chat_db_path: Path.expand("priv/db/Messages/chat.db"),
               #  chat_db_path: "~/Library/Messages/chat.db",
               update_hook_wait_ms: 1000,
               update_hook_mfa: :noop,

               #  chat_db_opts: [],
               #  contact_cache_dir: "",
               #  contacts_json: "",
               import_vcards_path: "priv/contacts.vcf",
               export_jcards_path: "priv/contacts-ical-jcards.json",
               export_contacts_json_path: "priv/chat-db-contacts.json"
               #  photo_cache_dir: ""
             }
    end
  end
end
