defmodule ChatDbEx.MessagingTest do
  @moduledoc false

  use ExUnit.Case, async: true

  alias ChatDbEx.Messaging

  describe ".last_message_at/0" do
    test "it returns valid result" do
      rowid = 1200
      assert Messaging.last_message_at(%{rowid: rowid}) == {:ok, "2020-09-15 09:20:29"}
    end
  end

  describe ".last_message_text/0" do
    test "it returns valid result" do
      rowid = 1200

      assert Messaging.last_message_text(%{rowid: rowid}) ==
               {:ok,
                "Michael, important notice about the USPS package 3A51A7 from 06/01/2020. Proceed to m9sxv.info/lbHkkj1mw"}
    end
  end

  describe ".last_message/0" do
    test "it returns valid result" do
      assert {:ok, [message]} = Messaging.last_message()
      assert_valid_message(message)
    end
  end

  describe ".chat_messages_count/0" do
    test "it returns valid result" do
      rowid = 1200
      assert Messaging.chat_messages_count(%{rowid: rowid}) == {:ok, 1}
    end
  end

  describe ".chats_since/1" do
    test "it returns valid result" do
      max_row = 1232
      rowid = max_row - 1
      assert {:ok, rows} = Messaging.chats_since(%{rowid: rowid})
      assert length(rows) == 1

      chat = Enum.at(rows, 0)
      assert_valid_chat(chat)
    end
  end

  describe ".messages_since/1" do
    test "it returns valid result" do
      max_row = 218_408
      rowid = max_row - 1
      assert {:ok, rows} = Messaging.messages_since(%{rowid: rowid})
      assert length(rows) == 1
      message = Enum.at(rows, 0)

      assert_valid_message(message)
    end
  end

  describe ".attachments_since/1" do
    test "it returns valid result" do
      max_row = 218_400
      # max_row = 9628
      rowid = max_row - 1
      assert {:ok, rows} = Messaging.attachments_since(%{rowid: rowid})
      assert length(rows) == 1
      attachment = Enum.at(rows, 0)
      assert_valid_attachment(attachment)
    end
  end

  defp is_boolean_int(val) do
    val in [0, 1]
  end

  defp is_utc_datetime(val) do
    is_binary(val)
  end

  defp is_guid(val) do
    is_binary(val)
  end

  defp assert_valid_chat(chat) do
    assert is_list(chat)
    assert is_integer(chat[:id])
    assert is_utc_datetime(chat[:last_message_at]) or is_nil(chat[:last_message_at])
    assert is_binary(chat[:last_message_text]) or is_nil(chat[:last_message_text])
    assert is_integer(chat[:messages_count])
  end

  defp assert_valid_message(message) do
    assert is_list(message)
    assert is_integer(message[:handle_id])
    assert is_binary(message[:handle_identifier])

    assert is_binary(message[:handle_uncanonicalized_id]) or
             is_nil(message[:handle_uncanonicalized_id])

    assert is_integer(message[:id])
    assert is_guid(message[:guid])
    assert is_binary(message[:text])
    assert is_binary(message[:subject]) or is_nil(message[:subject])
    assert is_binary(message[:cache_roomnames]) or is_nil(message[:cache_roomnames])
    assert is_boolean_int(message[:is_read])
    assert is_boolean_int(message[:is_sent])
    assert is_boolean_int(message[:is_from_me])
    assert is_boolean_int(message[:has_attachments])
    assert is_utc_datetime(message[:utc_datetime])
    assert is_utc_datetime(message[:utc_datetime_read])
    assert is_utc_datetime(message[:utc_datetime_played])
    assert is_utc_datetime(message[:utc_datetime_delivered])
  end

  defp assert_valid_attachment(attachment) do
    assert is_list(attachment)
    assert is_integer(attachment[:attachment_id])
    assert is_integer(attachment[:message_id])
    assert is_binary(attachment[:filename])
    assert is_binary(attachment[:mime_type]) or is_nil(attachment[:mime_type])
    assert is_integer(attachment[:total_bytes])
  end
end
