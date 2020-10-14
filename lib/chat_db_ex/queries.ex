defmodule ChatDbEx.Queries do
  @moduledoc """
  iMessage chatdb queries.
  """

  # defp get_current_max_rowid() do
  #   # Check to see if we have one stored.
  #   case DB.get!(:state, "imsg_max_rowid") do
  #     nil ->
  #       # Haven't seen it before, use the max of ROWID.
  #       [[ROWID: rowid]] = query("SELECT MAX(message.ROWID) AS ROWID FROM message;")
  #       DB.set(:state, "imsg_max_rowid", rowid)
  #       rowid

  #     res ->
  #       res
  #   end
  # end

  def unix_datetime(name, as: as) do
    """
    datetime(
      #{name} / 1000000000 + strftime("%s", "2001-01-01"),
      "unixepoch",
      "localtime"
    ) AS #{as}
    """
  end

  def boolean_int(name, as: as) do
    "#{name} = 1 AS #{as}"
  end

  def sql(:last_message_at, _opts) do
    """
    SELECT
      # {unix_datetime("message.date", as: "utc_date")}
      datetime(message.date / 1000000000 + strftime(" % s", "2001 - 01 - 01"), "unixepoch", "localtime") AS date_utc
    FROM
      message
      JOIN
        chat_message_join
        ON chat_message_join.message_id = message.ROWID
    WHERE
      chat_message_join.chat_id = chat.ROWID
    ORDER BY
      date DESC LIMIT 1
    """
  end

  def sql(:last_message_text, _opts) do
    """
    SELECT
      text
    FROM
      message
      JOIN
        chat_message_join
        ON chat_message_join.message_id = message.ROWID
    WHERE
      chat_message_join.chat_id = chat.ROWID
    ORDER BY
      date DESC LIMIT 1
    """
  end

  def sql(:chat_messages_count, _opts) do
    """
    SELECT
      count(message.ROWID)
    FROM
      message
      JOIN
        chat_message_join
        ON chat_message_join.message_id = message.ROWID
    WHERE
      chat_message_join.chat_id = chat.ROWID
    """
  end

  def sql(:chats_since, %{rowid: rowid}) do
    """
    SELECT
      chat.ROWID AS id,
      (
        SELECT
          # {unix_datetime("message.date", as: "utc_date")}
          datetime(message.date / 1000000000 + strftime(" % s", "2001 - 01 - 01"), "unixepoch", "localtime") AS date_utc
        FROM
          message
          JOIN
            chat_message_join
            ON chat_message_join.message_id = message.ROWID
        WHERE
          chat_message_join.chat_id = chat.ROWID
        ORDER BY
          date DESC LIMIT 1
      )
      AS last_message_at,
      (
        SELECT
          text
        FROM
          message
          JOIN
            chat_message_join
            ON chat_message_join.message_id = message.ROWID
        WHERE
          chat_message_join.chat_id = chat.ROWID
        ORDER BY
          date DESC LIMIT 1
      )
      AS last_message_text,
      (
        SELECT
          count(message.ROWID)
        FROM
          message
          JOIN
            chat_message_join
            ON chat_message_join.message_id = message.ROWID
        WHERE
          chat_message_join.chat_id = chat.ROWID
      )
      AS messages_count,
    ORDER BY
      last_message_at DESC
    WHERE
      chat.ROWID > #{rowid}
    """
  end

  def sql(:messages_since, %{rowid: rowid}) do
    """
    SELECT
      handle.ROWID AS handle_id,
      handle.id AS handle_identifier,
      handle.person_centric_id AS person_centric_id,
      handle.uncanonicalized_id AS handle_uncanonicalized_id,
      message.ROWID AS id,
      message.guid AS guid,
      message.text AS text,
      message.subject AS subject,
      message.cache_roomnames AS cache_roomnames,
      message.is_read = 1 AS is_read,
      message.is_sent = 1 AS is_sent,
      message.is_from_me = 1 AS is_from_me,
      message.cache_has_attachments = 1 AS has_attachments,
      datetime(message.date / 1000000000 + strftime(" % s", "2001 - 01 - 01"), "unixepoch", "localtime") AS utc_date,
      datetime(message.date_read / 1000000000 + strftime(" % s", "2001 - 01 - 01"), "unixepoch", "localtime") AS utc_date_read,
      datetime(message.date_delivered / 1000000000 + strftime(" % s", "2001 - 01 - 01"), "unixepoch", "localtime") AS utc_date_delivered datetime(message.date_played / 1000000000 + strftime(" % s", "2001 - 01 - 01"), "unixepoch", "localtime") AS utc_date_played
    FROM
      message
      INNER JOIN
        handle
        ON message.handle_id = handle.ROWID
    WHERE
      message.ROWID > #{rowid}
    """
  end

  def sql(:attachments_since, %{rowid: rowid}) do
    """
    SELECT
      attachment.ROWID AS attachment_id,
      message_attachment_join.message_id AS message_id,
      attachment.filename,
      attachment.mime_type,
      attachment.total_bytes
    FROM
      attachment
      INNER JOIN
        message_attachment_join
        ON attachment.ROWID == message_attachment_join.attachment_id
    WHERE
      message_attachment_join.message_id >= #{rowid}
    """
  end

  def query(:list_messages) do
    ~s(
      SELECT * from message ORDER BY ROWID DESC LIMIT 1
    )
  end

  def query(:list_messages_with_assocs) do
    ~s{
      SELECT
        message.ROWID,
        text,
        is_from_me,
        handle.id AS handle_identifier,
        cache_has_attachments,
        datetime(
          message.date / 1000000000 + strftime("%s", "2001-01-01"),
          "unixepoch", "localtime"
        ) AS sent_at
    }
    # .includes(:attachments, chats: :handles)
    # .joins("LEFT JOIN handle on handle.ROWID = message.handle_id")
  end

  def query(:list_chats_with_assocs) do
    ~s{
      SELECT
        chat.ROWID,
        (
          SELECT datetime(
            message.date / 1000000000 + strftime("%s", "2001-01-01"),
            "unixepoch", "localtime"
          ) AS date_utc
          FROM message
          JOIN chat_message_join ON chat_message_join.message_id = message.ROWID
          WHERE chat_message_join.chat_id = chat.ROWID
          ORDER BY date DESC
          LIMIT 1
        ) AS last_msg_at,
        (
          SELECT text
          FROM message
          JOIN chat_message_join ON chat_message_join.message_id = message.ROWID
          WHERE chat_message_join.chat_id = chat.ROWID
          ORDER BY date DESC
          LIMIT 1
        ) AS last_text
    }
    # .includes(:handles)
  end

  # @path 'db/Messages/chat.db'

  # def import do
  #   # Sqlitex.with_db(@path, fn db ->
  #   #   Sqlitex.query(
  #   #     db,
  #   #     "INSERT INTO players (name, created_at, updated_at) VALUES (?1, ?2, ?3, ?4)",
  #   #     bind: ['Mikey', '2012-10-14 05:46:28.318107', '2013-09-06 22:29:36.610911']
  #   #   )
  #   # end)

  #   :list_messages
  #   |> query()
  #   |> with_connection()
  # end
end
