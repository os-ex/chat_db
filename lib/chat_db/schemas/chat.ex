defmodule ChatDb.Schemas.Chat do
  @moduledoc """
  Schema for `ChatDb.Schemas.Chat`.
  """

  use PropSchema
  import Ecto.Changeset

  alias DarkMatter.DateTimes

  alias ChatDb.Ecto.BooleanInt
  alias ChatDb.Ecto.UnixDatetime

  alias ChatDb.Schemas.Handle
  alias ChatDb.Schemas.Message

  @typedoc """
  Struct type for `ChatDb.Schemas.Chat`.
  """
  @type t() :: %__MODULE__{
          __meta__: Ecto.Schema.Metadata.t(),
          id: primary_key :: pos_integer() | nil,
          guid: String.t() | nil,
          style: integer() | nil,
          state: integer() | nil,
          account_id: String.t() | nil,
          properties: binary() | nil,
          chat_identifier: String.t() | nil,
          service_name: String.t() | nil,
          room_name: String.t() | nil,
          account_login: String.t() | nil,
          is_archived: integer() | nil,
          last_addressed_handle: String.t() | nil,
          display_name: String.t() | nil,
          group_id: String.t() | nil,
          is_filtered: integer() | nil,
          successful_query: integer() | nil,
          handles: [Handle.t()] | Ecto.Association.NotLoaded.t(),
          messages: [Message.t()] | Ecto.Association.NotLoaded.t()
        }

  # @primary_key {:guid, :string, []}
  @primary_key {:rowid, :integer, []}
  # @derive {Phoenix.Param, key: :rowid}
  prop_schema "chat" do
    prop_field(:id, :integer, source: :rowid, required: true)
    prop_field(:guid, :string, required: true)
    prop_field(:account_id, :string, required: true)
    prop_field(:account_login, :string, required: true)
    prop_field(:chat_identifier, :string, required: true)
    prop_field(:display_name, :string, required: true)
    prop_field(:group_id, :string, required: true)
    prop_field(:is_archived, BooleanInt, required: true)
    prop_field(:is_filtered, BooleanInt, required: true)
    prop_field(:last_addressed_handle, :string, required: true)
    prop_field(:properties, :binary, required: true)
    prop_field(:room_name, :string, required: true)
    prop_field(:service_name, :string, required: true)
    prop_field(:state, :integer, required: true)
    prop_field(:style, :integer, required: true)
    prop_field(:successful_query, BooleanInt, required: true)

    # New
    prop_field(:last_read_message_timestamp, :integer)

    prop_field(:is_online, :boolean, virtual: true, default: false)
    prop_field(:avatars, {:array, :string}, virtual: true, default: [])
    prop_field(:identifiers, :string, virtual: true)
    prop_field(:unread_count, :integer, default: 0, virtual: true)
    prop_field(:last_message_at, :utc_datetime_usec, default: DateTimes.now!(), virtual: true)

    prop_many_to_many(:handles, Handle, join_through: "chat_handle_join")
    prop_many_to_many(:messages, Message, join_through: "chat_message_join")
  end

  @doc """
  Generator options.
  """
  @spec __dark_opts__() :: Keyword.t()
  def __dark_opts__ do
    [
      preloads: [
        get_by_identifier: [],
        list: [],
        list_by_facet: []
      ]
    ]
  end

  @doc """
  Changeset based on `struct` and `params`.
  """
  @spec changeset(t() | Ecto.Changeset.t(), map()) :: Ecto.Changeset.t()
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [
      :account_id,
      :account_login,
      :chat_identifier,
      :display_name,
      :group_id,
      :guid,
      :is_archived,
      :is_filtered,
      :last_addressed_handle,
      :properties,
      :room_name,
      :service_name,
      :state,
      :style,
      :successful_query
    ])
    |> validate_required([
      :account_id,
      :account_login,
      :chat_identifier,
      :display_name,
      :group_id,
      :guid,
      :is_archived,
      :is_filtered,
      :last_addressed_handle,
      :properties,
      :room_name,
      :service_name,
      :state,
      :style,
      :successful_query
    ])
    |> unique_constraint(:guid)
  end

  def populate(%__MODULE__{} = struct) do
    %{
      struct
      | is_online: true,
        avatars: [],
        identifiers: nil,
        unread_count: 1,
        last_message_at: DateTimes.now!()
    }
  end
end
