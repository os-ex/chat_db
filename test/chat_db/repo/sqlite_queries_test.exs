defmodule ChatDB.Repo.SQLiteQueriesTest do
  @moduledoc false

  use ExUnit.Case, async: true

  alias ChatDB.Repo.SQLiteQueries
  alias DarkEcto.SQLFormatter

  describe ".sql/2 (:last_message_at)" do
    test "it returns valid sql" do
      assert_sql(SQLiteQueries.sql(:last_message_at, %{rowid: 1}), """
      SELECT datetime(message.date/1000000000 + strftime("%s",
          "2001-01-01"),
          "unixepoch",
          "localtime") AS utc_datetime
      FROM message
      JOIN chat_message_join
        ON chat_message_join.message_id = message.ROWID
      WHERE chat_message_join.chat_id = 1
      ORDER BY date DESC LIMIT 1
      """)
    end
  end

  describe ".sql/2 (:last_message_text)" do
    test "it returns valid sql" do
      assert_sql(SQLiteQueries.sql(:last_message_text, %{rowid: 1}), """
      SELECT text
      FROM message
      JOIN chat_message_join
        ON chat_message_join.message_id = message.ROWID
      WHERE chat_message_join.chat_id = 1
      ORDER BY date DESC LIMIT 1
      """)
    end
  end

  describe ".sql/2 (:chat_messages_count)" do
    test "it returns valid sql" do
      assert_sql(SQLiteQueries.sql(:chat_messages_count, %{rowid: 1}), """
      SELECT count(message.ROWID) AS count
      FROM message
      JOIN chat_message_join
        ON chat_message_join.message_id = message.ROWID
      WHERE chat_message_join.chat_id = 1
      """)
    end
  end

  describe ".sql/2 (:chats_since)" do
    test "it returns valid sql" do
      assert_sql(SQLiteQueries.sql(:chats_since, %{rowid: 1}), """
      SELECT chat.ROWID AS id,
        (SELECT datetime(message.date/1000000000 + strftime("%s",
          "2001-01-01"),
          "unixepoch",
          "localtime")
        FROM message
        JOIN chat_message_join
          ON chat_message_join.message_id = message.ROWID
        WHERE chat_message_join.chat_id = chat.ROWID
        ORDER BY date DESC LIMIT 1 ) AS last_message_at,
        (SELECT text
        FROM message
        JOIN chat_message_join
          ON chat_message_join.message_id = message.ROWID
        WHERE chat_message_join.chat_id = chat.ROWID
        ORDER BY date DESC LIMIT 1 ) AS last_message_text,
        (SELECT count(DISTINCT message.ROWID)
        FROM message
        JOIN chat_message_join
          ON chat_message_join.message_id = message.ROWID
        WHERE chat_message_join.chat_id = chat.ROWID ) AS messages_count
      FROM chat
      WHERE chat.ROWID > 1
      ORDER BY last_message_at DESC
      """)
    end
  end

  describe ".sql/2 (:messages_since)" do
    test "it returns valid sql" do
      assert_sql(SQLiteQueries.sql(:messages_since, %{rowid: 1}), """
      SELECT handle.ROWID AS handle_id,
          handle.id AS handle_identifier,
          handle.uncanonicalized_id AS handle_uncanonicalized_id,
          message.ROWID AS id,
          message.guid AS guid,
          message.text AS text,
          message.subject AS subject,
          message.cache_roomnames AS cache_roomnames,
          cast(message.is_read AS boolean) AS is_read,
          message.is_sent AS is_sent,
          message.is_from_me AS is_from_me,
          message.cache_has_attachments AS has_attachments,
          datetime(message.date/1000000000 + strftime("%s",
          "2001-01-01"),
          "unixepoch",
          "localtime") AS utc_datetime,
          datetime(message.date_read/1000000000 + strftime("%s",
          "2001-01-01"),
          "unixepoch",
          "localtime") AS utc_datetime_read,
          datetime(message.date_played/1000000000 + strftime("%s",
          "2001-01-01"),
          "unixepoch",
          "localtime") AS utc_datetime_played,
          datetime(message.date_delivered/1000000000 + strftime("%s",
          "2001-01-01"),
          "unixepoch",
          "localtime") AS utc_datetime_delivered
      FROM message
      INNER JOIN handle
        ON message.handle_id = handle.ROWID
      WHERE message.ROWID > 1
      """)
    end
  end

  describe ".sql/2 (:attachments_since)" do
    test "it returns valid sql" do
      assert_sql(SQLiteQueries.sql(:attachments_since, %{rowid: 1}), """
      SELECT attachment.ROWID AS attachment_id,
          message_attachment_join.message_id AS message_id,
          attachment.filename,
          attachment.mime_type,
          attachment.total_bytes
      FROM attachment
      INNER JOIN message_attachment_join
        ON attachment.ROWID == message_attachment_join.attachment_id
      WHERE message_attachment_join.message_id >= 1
      """)
    end
  end

  defp assert_sql(sql, expected) do
    formatted = SQLFormatter.format(sql)

    quotes = "\"\"\""
    assert formatted == expected

    assert formatted == expected,
      message: """
      #{IO.ANSI.cyan()}Expected:#{IO.ANSI.reset()}
      #{IO.ANSI.red()}
      #{quotes}
      #{String.trim(expected)}
      #{quotes}

      #{IO.ANSI.light_cyan()}Received:#{IO.ANSI.reset()}
      #{IO.ANSI.light_red()}
      #{quotes}
      #{String.trim(formatted)}
      #{quotes}
      """
  end
end
