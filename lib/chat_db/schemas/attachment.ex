defmodule ChatDB.Schemas.Attachment do
  @moduledoc """
  Schema for `ChatDB.Schemas.Attachment`.
  """

  use PropSchema
  import Ecto.Changeset

  alias ChatDB.Schemas.Message

  @typedoc """
  Struct type for `ChatDB.Schemas.Attachment`.
  """
  @type t() :: %__MODULE__{
          __meta__: Ecto.Schema.Metadata.t(),
          # id: primary_key :: pos_integer() | nil,
          guid: String.t() | nil,
          created_date: DateTime.t() | nil,
          start_date: DateTime.t() | nil,
          filename: String.t() | nil,
          uti: String.t() | nil,
          mime_type: String.t() | nil,
          transfer_state: integer() | nil,
          hide_attachment: integer() | nil,
          is_outgoing: integer() | nil,
          user_info: binary() | nil,
          attribution_info: binary() | nil,
          ck_server_change_token_blob: binary() | nil,
          sr_ck_server_change_token_blob: binary() | nil,
          transfer_name: String.t() | nil,
          total_bytes: integer() | nil,
          messages: [Message.t()] | Ecto.Association.NotLoaded.t()
        }

  @primary_key {:rowid, :integer, []}
  # @derive {Phoenix.Param, key: :rowid}
  prop_schema "attachment" do
    prop_field(:id, :integer, source: :rowid, required: true)
    # prop_field(:handle_uuid, :string, source: :id, required: true)
    prop_field(:created_date, :integer, required: true)
    prop_field(:filename, :string, required: true)
    prop_field(:guid, :string, required: true)
    prop_field(:hide_attachment, :integer, required: true)
    prop_field(:is_outgoing, :integer, required: true)
    prop_field(:mime_type, :string, required: true)
    prop_field(:start_date, :integer, required: true)
    prop_field(:total_bytes, :integer, required: true)
    prop_field(:transfer_name, :string, required: true)
    prop_field(:transfer_state, :integer, required: true)
    prop_field(:user_info, :binary, required: true, load_in_query: false)
    prop_field(:attribution_info, :binary, required: true, load_in_query: false)
    prop_field(:ck_server_change_token_blob, :binary, required: true, load_in_query: false)
    prop_field(:sr_ck_server_change_token_blob, :binary, required: true, load_in_query: false)
    prop_field(:uti, :string, required: true, load_in_query: false)

    prop_many_to_many(:messages, Message, join_through: "message_attachment_join")
  end

  @doc """
  Changeset based on `struct` and `params`.
  """
  @spec changeset(t() | Ecto.Changeset.t(), map()) :: Ecto.Changeset.t()
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [
      :created_date,
      :filename,
      :guid,
      :is_outgoing,
      :mime_type,
      :start_date,
      :total_bytes,
      :transfer_name,
      :transfer_state,
      :user_info,
      :uti
    ])
    |> validate_required([
      :created_date,
      :filename,
      :guid,
      :is_outgoing,
      :mime_type,
      :start_date,
      :total_bytes,
      :transfer_name,
      :transfer_state,
      :user_info,
      :uti
    ])
    |> unique_constraint(:guid)
  end
end
