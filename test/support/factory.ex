defmodule Support.Factory do
  @moduledoc false

  use ExMachina.Ecto

  alias Support.Randoms

  alias ChatDB.Schemas.Attachment
  alias ChatDB.Schemas.Chat
  alias ChatDB.Schemas.Handle
  alias ChatDB.Schemas.Message

  def chat_factory do
    build(:random_chat)
  end

  def attachment_factory do
    build(:random_attachment)
  end

  def handle_factory do
    build(:random_handle)
  end

  def message_factory do
    build(:random_message)
  end

  def random_chat_factory do
    %Chat{
      account_id: Randoms.random(:account_id, :string),
      account_login: Randoms.random(:account_login, :string),
      chat_identifier: Randoms.random(:chat_identifier, :string),
      display_name: Randoms.random(:display_name, :string),
      group_id: Randoms.random(:group_id, :string),
      guid: Randoms.random(:guid, :string),
      is_archived: Randoms.random(:boolean_int),
      is_filtered: Randoms.random(:boolean_int),
      last_addressed_handle: Randoms.random(:last_addressed_handle, :string),
      properties: Randoms.random(:properties, :binary),
      room_name: Randoms.random(:room_name, :string),
      service_name: Randoms.random(:service_name, :string),
      state: Randoms.random(:state, :integer),
      style: Randoms.random(:style, :integer),
      successful_query: Randoms.random(:boolean_int)
    }
  end

  def random_attachment_factory do
    %Attachment{
      created_date: Randoms.random(:created_date, :utc_datetime_usec),
      filename: Randoms.random(:filename, :string),
      guid: Randoms.random(:guid, :string),
      is_outgoing: Randoms.random(:is_outgoing, :integer),
      mime_type: Randoms.random(:mime_type, :string),
      start_date: Randoms.random(:start_date, :utc_datetime_usec),
      total_bytes: Randoms.random(:total_bytes, :integer),
      transfer_name: Randoms.random(:transfer_name, :string),
      transfer_state: Randoms.random(:transfer_state, :integer),
      user_info: Randoms.random(:user_info, :binary),
      uti: Randoms.random(:uti, :string)
    }
  end

  def random_handle_factory do
    %Handle{
      country: Randoms.random(:country, :string),
      id: Randoms.random(:id, :string),
      service: Randoms.random(:service, :string),
      uncanonicalized_id: Randoms.random(:uncanonicalized_id, :string)
    }
  end

  def random_message_factory do
    %Message{
      rowid: Randoms.random(:primary_key),
      is_from_me: Randoms.random(:is_from_me, :boolean_int),
      is_audio_message: Randoms.random(:is_audio_message, :boolean_int),
      service: Randoms.random(:service, :string),
      subject: Randoms.random(:subject, :string),
      is_delayed: Randoms.random(:is_delayed, :boolean_int),
      guid: Randoms.random(:guid, :string),
      group_title: Randoms.random(:group_title, :string),
      has_dd_results: Randoms.random(:has_dd_results, :integer),
      account: Randoms.random(:account, :string),
      date_read: Randoms.random(:date_read, :integer),
      is_sent: Randoms.random(:is_sent, :boolean_int),
      country: Randoms.random(:country, :string),
      item_type: Randoms.random(:item_type, :integer),
      is_delivered: Randoms.random(:is_delivered, :boolean_int),
      type: Randoms.random(:type, :integer),
      is_auto_reply: Randoms.random(:is_auto_reply, :boolean_int),
      service_center: Randoms.random(:service_center, :string),
      is_expirable: Randoms.random(:is_expirable, :boolean_int),
      is_played: Randoms.random(:is_played, :boolean_int),
      date_delivered: Randoms.random(:date_delivered, :integer),
      was_deduplicated: Randoms.random(:was_deduplicated, :integer),
      was_data_detected: Randoms.random(:was_data_detected, :integer),
      error: Randoms.random(:error, :integer),
      date_played: Randoms.random(:date_played, :integer),
      was_downgraded: Randoms.random(:was_downgraded, :integer),
      message_source: Randoms.random(:message_source, :integer),
      account_guid: Randoms.random(:account_guid, :string),
      replace: Randoms.random(:replace, :integer),
      is_service_message: Randoms.random(:is_service_message, :boolean_int),
      cache_roomnames: Randoms.random(:cache_roomnames, :string),
      expire_state: Randoms.random(:expire_state, :integer),
      share_status: Randoms.random(:share_status, :integer),
      group_action_type: Randoms.random(:group_action_type, :integer),
      cache_has_attachments: Randoms.random(:cache_has_attachments, :integer),
      is_read: Randoms.random(:is_read, :boolean_int),
      other_handle: Randoms.random(:other_handle, :integer),
      is_emote: Randoms.random(:is_emote, :boolean_int),
      attributedbody: Randoms.random(:attributedbody, :binary),
      message_action_type: Randoms.random(:message_action_type, :integer),
      is_forward: Randoms.random(:is_forward, :boolean_int),
      is_finished: Randoms.random(:is_finished, :boolean_int),
      date: Randoms.random(:integer),
      is_empty: Randoms.random(:is_empty, :boolean_int),
      is_prepared: Randoms.random(:is_prepared, :boolean_int),
      text: Randoms.random(:text, :string),
      is_system_message: Randoms.random(:is_system_message, :boolean_int),
      version: Randoms.random(:version, :integer),
      share_direction: Randoms.random(:share_direction, :integer),
      is_archive: Randoms.random(:is_archive, :boolean_int)
    }
  end
end
