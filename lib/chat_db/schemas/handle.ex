defmodule ChatDb.Schemas.Handle do
  @moduledoc """
  Schema for `ChatDb.Schemas.Handle`.
  """

  use PropSchema
  import Ecto.Changeset

  alias ChatDb.Schemas.Chat

  alias ChatDb.Contacts

  @typedoc """
  Struct type for `ChatDb.Schemas.Handle`.
  """
  @type t() :: %__MODULE__{
          __meta__: Ecto.Schema.Metadata.t(),
          id: primary_key :: pos_integer() | nil,
          country: String.t() | nil,
          service: String.t() | nil,
          uncanonicalized_id: String.t() | nil,
          chats: [Chat.t()] | Ecto.Association.NotLoaded.t()
        }

  @primary_key {:rowid, :integer, []}
  # @derive {Phoenix.Param, key: :rowid}
  prop_schema "handle" do
    prop_field(:id, :integer, source: :rowid, required: true)
    prop_field(:handle_uuid, :string, source: :id, required: true)
    prop_field(:country, :string, required: true)
    prop_field(:service, :string, required: true)
    prop_field(:uncanonicalized_id, :string, required: true)

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
    # contacts = Contacts.list_contact_cards()
    nil
  end

  def image_url(%__MODULE__{} = struct) do
    # contacts = Contacts.list_contact_cards()
    ""
  end

  def image_url(handles) do
    ""
  end
end
