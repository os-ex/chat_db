# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :chat_db,
  # chat_db_path: 'priv/db/Messages/chat.db',
  chat_db_path: '~/Library/Messages/chat.db',
  # import_vcards_path: "priv/contacts.vcf",
  # export_jcards_path: "priv/contacts-ical-jcards.json",
  # contacts_json: "",
  # contact_cache_dir: "",
  # chat_db_module: ChatDB.IMessageChatDB,
  # photo_cache_dir: "",
  # register_hook_delay_ms: 1000,
  # update_handler_mfa: :noop,
  chat_db_opts: []
