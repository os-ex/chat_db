defmodule ChatDB.Schemas.Message do
  @moduledoc """
  Schema for `ChatDB.Schemas.Message`.
  """

  use PropSchema
  import Ecto.Changeset

  alias ChatDB.Schemas.Attachment
  alias ChatDB.Schemas.Chat
  alias ChatDB.Schemas.Handle

  alias ChatDB.Ecto.BooleanInt
  # alias DarkEcto.Types.BooleanInt
  # alias DarkEcto.Types.CFAbsoluteTime

  @typedoc """
  Struct type for `ChatDB.Schemas.Message`.
  """
  @type t() :: %__MODULE__{
          __meta__: Ecto.Schema.Metadata.t(),
          id: primary_key :: pos_integer() | nil,
          handle_id: foreign_key :: pos_integer() | nil,
          guid: String.t() | nil,
          text: String.t() | nil,
          replace: integer() | nil,
          service_center: String.t() | nil,
          subject: String.t() | nil,
          country: String.t() | nil,
          attributedbody: String.t() | nil,
          version: integer() | nil,
          type: integer() | nil,
          service: String.t() | nil,
          account: String.t() | nil,
          account_guid: String.t() | nil,
          error: integer() | nil,
          date: integer() | nil,
          date_read: integer() | nil,
          date_delivered: integer() | nil,
          is_delivered: integer() | nil,
          is_finished: integer() | nil,
          is_emote: integer() | nil,
          is_from_me: integer() | nil,
          is_empty: integer() | nil,
          is_delayed: integer() | nil,
          is_auto_reply: integer() | nil,
          is_prepared: integer() | nil,
          is_read: integer() | nil,
          is_system_message: integer() | nil,
          is_sent: integer() | nil,
          has_dd_results: integer() | nil,
          is_service_message: integer() | nil,
          is_forward: integer() | nil,
          was_downgraded: integer() | nil,
          is_archive: integer() | nil,
          cache_has_attachments: integer() | nil,
          cache_roomnames: String.t() | nil,
          was_data_detected: integer() | nil,
          was_deduplicated: integer() | nil,
          is_audio_message: integer() | nil,
          is_played: integer() | nil,
          date_played: integer() | nil,
          item_type: integer() | nil,
          other_handle: integer() | nil,
          group_title: String.t() | nil,
          group_action_type: integer() | nil,
          share_status: integer() | nil,
          share_direction: integer() | nil,
          is_expirable: integer() | nil,
          expire_state: integer() | nil,
          message_action_type: integer() | nil,
          message_source: integer() | nil,
          handle: Handle.t() | Ecto.Association.NotLoaded.t() | nil,
          chats: [Chat.t()] | Ecto.Association.NotLoaded.t(),
          attachments: [Attachment.t()] | Ecto.Association.NotLoaded.t()
        }

  # @primary_key false
  @primary_key {:rowid, :integer, []}
  # @derive {Phoenix.Param, key: :rowid}
  prop_schema "message" do
    prop_field(:id, :integer, source: :rowid, required: true)
    # prop_field(:id, :integer, primary_key: true, source: :rowid, required: true)
    prop_field(:is_from_me, BooleanInt, required: true)
    prop_field(:is_audio_message, BooleanInt, required: true)
    prop_field(:service, :string, required: true)
    prop_field(:subject, :string, required: true)
    prop_field(:is_delayed, BooleanInt, required: true)
    prop_field(:guid, :string, required: true)
    prop_field(:group_title, :string, required: true)
    prop_field(:has_dd_results, :integer, required: true)
    prop_field(:account, :string, required: true)
    prop_field(:date_read, :integer, required: true)
    prop_field(:is_sent, BooleanInt, required: true)
    prop_field(:country, :string, required: true)
    prop_field(:item_type, :integer, required: true)
    prop_field(:is_delivered, BooleanInt, required: true)
    prop_field(:type, :integer, required: true)
    prop_field(:is_auto_reply, BooleanInt, required: true)
    prop_field(:service_center, :string, required: true)
    prop_field(:is_expirable, BooleanInt, required: true)
    prop_field(:is_played, BooleanInt, required: true)
    prop_field(:date_delivered, :integer, required: true)
    prop_field(:was_deduplicated, :integer, required: true)
    prop_field(:was_data_detected, :integer, required: true)
    prop_field(:error, :integer, required: true)
    prop_field(:date_played, :integer, required: true)
    prop_field(:was_downgraded, :integer, required: true)
    prop_field(:message_source, :integer, required: true)
    prop_field(:account_guid, :string, required: true)
    prop_field(:replace, :integer, required: true)
    prop_field(:is_service_message, BooleanInt, required: true)
    prop_field(:cache_roomnames, :string, required: true)
    prop_field(:expire_state, :integer, required: true)
    prop_field(:share_status, :integer, required: true)
    prop_field(:group_action_type, :integer, required: true)
    prop_field(:cache_has_attachments, :integer, required: true)
    prop_field(:is_read, BooleanInt, required: true)
    prop_field(:other_handle, :integer, required: true)
    prop_field(:is_emote, BooleanInt, required: true)
    prop_field(:attributedbody, :binary, required: true, load_in_query: false)
    prop_field(:message_action_type, :integer, required: true)
    prop_field(:is_forward, BooleanInt, required: true)
    prop_field(:is_finished, BooleanInt, required: true)
    prop_field(:date, :integer, required: true)
    prop_field(:is_empty, BooleanInt, required: true)
    prop_field(:is_prepared, BooleanInt, required: true)
    prop_field(:text, :string, required: true)
    prop_field(:is_system_message, BooleanInt, required: true)
    prop_field(:version, :integer, required: true)
    prop_field(:share_direction, :integer, required: true)
    prop_field(:is_archive, BooleanInt, required: true)
    prop_field(:message_text, :string, virtual: true, default: "", required: true)
    prop_field(:attachments?, :boolean, virtual: true, default: false, required: true)

    prop_belongs_to(:handle, Handle, required: true)

    prop_many_to_many(:chats, Chat, join_through: "chat_message_join")
    prop_many_to_many(:attachments, Attachment, join_through: "message_attachment_join")
  end

  @doc """
  Changeset based on `struct` and `params`.
  """
  @spec changeset(t() | Ecto.Changeset.t(), map()) :: Ecto.Changeset.t()
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [
      :is_from_me,
      :is_audio_message,
      :service,
      :subject,
      :is_delayed,
      :guid,
      :group_title,
      :has_dd_results,
      :account,
      :date_read,
      :is_sent,
      :country,
      :item_type,
      :is_delivered,
      :type,
      :is_auto_reply,
      :service_center,
      :is_expirable,
      :is_played,
      :date_delivered,
      :was_deduplicated,
      :was_data_detected,
      :error,
      :date_played,
      :was_downgraded,
      :message_source,
      :account_guid,
      :replace,
      :is_service_message,
      :cache_roomnames,
      :expire_state,
      :share_status,
      :group_action_type,
      :cache_has_attachments,
      :is_read,
      :other_handle,
      :is_emote,
      :attributedbody,
      :message_action_type,
      :is_forward,
      :is_finished,
      :date,
      :is_empty,
      :is_prepared,
      :text,
      :is_system_message,
      :version,
      :share_direction,
      :is_archive,
      :handle_id,
      :date
    ])
    |> cast_assoc(:handle)
    |> validate_required([
      :is_from_me,
      :is_audio_message,
      :service,
      :subject,
      :is_delayed,
      :guid,
      :group_title,
      :has_dd_results,
      :account,
      :date_read,
      :is_sent,
      :country,
      :item_type,
      :is_delivered,
      :type,
      :is_auto_reply,
      :service_center,
      :is_expirable,
      :is_played,
      :date_delivered,
      :was_deduplicated,
      :was_data_detected,
      :error,
      :date_played,
      :was_downgraded,
      :message_source,
      :account_guid,
      :replace,
      :is_service_message,
      :cache_roomnames,
      :expire_state,
      :share_status,
      :group_action_type,
      :cache_has_attachments,
      :is_read,
      :other_handle,
      :is_emote,
      :attributedbody,
      :message_action_type,
      :is_forward,
      :is_finished,
      :date,
      :is_empty,
      :is_prepared,
      :text,
      :is_system_message,
      :version,
      :share_direction,
      :is_archive
    ])
    |> unique_constraint(:guid)
  end

  @doc """
  Return if a given message has attachments.
  """
  @spec attachments?(t()) :: boolean()
  def attachments?(%__MODULE__{cache_has_attachments: 1}), do: true
  def attachments?(%__MODULE__{text: "￼\ufffc"}), do: true
  def attachments?(%__MODULE__{}), do: false

  @doc """
  Text to be included in the message body.
  """
  @spec message_text(t()) :: String.t()
  def message_text(%__MODULE__{text: text} = struct) do
    if is_binary(text) and not attachments?(struct) do
      text
    else
      ""
    end
  end

  def populate(%__MODULE__{} = struct) do
    %{
      struct
      | message_text: message_text(struct),
        attachments?: attachments?(struct)
    }
  end
end
