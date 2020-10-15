defmodule ChatDB.ConfigTest do
  @moduledoc false

  use ExUnit.Case, async: true

  alias ChatDB.Config

  describe ".read/0" do
    test "it returns valid defaults" do
      assert Config.read() == %Config{
               chat_db_path: 'priv/db/Messages/chat.db',
               chat_db_opts: [],
               contact_cache_dir: "",
               contacts_json: "",
               exported_jcards_filename: "priv/contacts-ical-jcards.json",
               exported_vcards_filename: "priv/contacts.vcf",
               photo_cache_dir: ""
             }
    end
  end
end
