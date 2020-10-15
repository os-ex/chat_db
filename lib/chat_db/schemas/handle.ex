defmodule ChatDB.Schemas.Handle do
  @moduledoc """
  Schema for `ChatDB.Schemas.Handle`.
  """

  use PropSchema
  import Ecto.Changeset

  alias ChatDB.Schemas.Chat

  alias ChatDB.Contacts

  @typedoc """
  Struct type for `ChatDB.Schemas.Handle`.
  """
  @type t() :: %__MODULE__{
          __meta__: Ecto.Schema.Metadata.t(),
          # id: primary_key :: String.t() | nil,
          country: String.t() | nil,
          service: String.t() | nil,
          uncanonicalized_id: String.t() | nil,
          # inserted_at: DateTime.t() | nil,
          # updated_at: DateTime.t() | nil,
          chats: [Chat.t()] | Ecto.Association.NotLoaded.t()
        }

  # @primary_key {:id, :string, autogenerate: false}
  @primary_key {:rowid, :integer, []}
  # @derive {Phoenix.Param, key: :rowid}
  prop_schema "handle" do
    prop_field(:id, :integer, source: :rowid, required: true)
    prop_field(:handle_uuid, :string, source: :id, required: true)
    prop_field(:country, :string, required: true)
    prop_field(:service, :string, required: true)
    prop_field(:uncanonicalized_id, :string, required: true)

    # timestamps(type: :utc_datetime_usec)

    prop_many_to_many(:chats, Chat, join_through: "chat_handle_join")
  end

  @doc """
  Changeset based on `struct` and `params`.
  """
  @spec changeset(t() | Ecto.Changeset.t(), map()) :: Ecto.Changeset.t()
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:country, :id, :service, :uncanonicalized_id])
    |> validate_required([:country, :id, :service])
  end

  def fullname(%__MODULE__{} = struct) do
    contacts = Contacts.list_contact_cards()
  end

  def image_url(%__MODULE__{} = struct) do
    # contacts = Contacts.list_contact_cards()
    ""
  end

  def image_url(handles) do
    ""
  end
end