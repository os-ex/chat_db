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

      assert message == [
               handle_id: 834,
               handle_identifier: "+15856223649",
               handle_uncanonicalized_id: nil,
               id: 218_407,
               guid: "7C8D54B8-1486-4976-A093-FDD256D28177",
               text: "xoxox",
               subject: nil,
               cache_roomnames: nil,
               is_read: 0,
               is_sent: 1,
               is_from_me: 1,
               has_attachments: 0,
               utc_datetime: "2020-09-29 08:48:48",
               utc_datetime_read: "2000-12-31 19:00:00",
               utc_datetime_played: "2000-12-31 19:00:00",
               utc_datetime_delivered: "2020-09-29 08:49:09"
             ]
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

      last_row = Enum.at(rows, 0)

      assert last_row == [
               id: 1232,
               last_message_at: nil,
               last_message_text: nil,
               messages_count: 0
             ]
    end
  end

  describe ".messages_since/1" do
    test "it returns valid result" do
      max_row = 218_408
      rowid = max_row - 1
      assert {:ok, rows} = Messaging.messages_since(%{rowid: rowid})
      assert length(rows) == 1
      last_row = Enum.at(rows, 0)

      assert last_row == [
               handle_id: 895,
               handle_identifier: "242733",
               handle_uncanonicalized_id: "242733",
               id: 218_408,
               guid: "1B76371E-66DE-C595-90D8-CCB92AF4789E",
               text:
                 "From: Chase Online\nReminder: We'll never call you to ask for this code\nEnter online at prompt, expires in 30 min.\nOne-Time Code:49390280",
               subject: nil,
               cache_roomnames: nil,
               is_read: 1,
               is_sent: 0,
               is_from_me: 0,
               has_attachments: 0,
               utc_datetime: "2020-09-27 12:57:20",
               utc_datetime_read: "2020-09-27 14:41:17",
               utc_datetime_played: "2000-12-31 19:00:00",
               utc_datetime_delivered: "2000-12-31 19:00:00"
             ]
    end
  end

  describe ".attachments_since/1" do
    test "it returns valid result" do
      max_row = 218_400
      # max_row = 9628
      rowid = max_row - 1
      assert {:ok, rows} = Messaging.attachments_since(%{rowid: rowid})
      assert length(rows) == 1
      last_row = Enum.at(rows, 0)

      assert last_row == [
               attachment_id: 9628,
               message_id: 218_400,
               filename:
                 "~/Library/Messages/Attachments/22/02/C319B468-B190-4A0A-9AAA-B4865D54566A/188DB60C-318E-4672-83E4-DBBD76899573.pluginPayloadAttachment",
               mime_type: nil,
               total_bytes: 4286
             ]
    end
  end
end
