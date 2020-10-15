defmodule ExMachina.ExMachinaCustomEcto do
  @moduledoc """
  Module for building and inserting factories with Ecto

  This module works much like the regular `ExMachina` module, but adds a few
  nice things that make working with Ecto easier.

  * It uses `ExMachina.EctoStrategy`, which adds `insert/1`, `insert/2`,
    `insert_pair/2`, `insert_list/3`.
  * Adds a `params_for` function that is useful for working with changesets or
    sending params to API endpoints.

  More in-depth examples are in the [README](readme.html).
  """

  @string_structs [Decimal, Date, DateTime, NaiveDateTime, Money, Postgrex.INET, Geo.Point]
  @nil_structs [Ecto.Association.NotLoaded]

  # credo:disable-for-this-file

  defmacro __using__(opts) do
    verify_ecto_dep()

    if repo = Keyword.get(opts, :repo) do
      quote do
        use ExMachina
        use ExMachina.EctoStrategy, repo: unquote(repo)

        def params_for(factory_name, attrs \\ %{}) do
          ExMachina.ExMachinaCustomEcto.params_for(__MODULE__, factory_name, attrs)
        end

        def string_params_for(factory_name, attrs \\ %{}) do
          ExMachina.ExMachinaCustomEcto.string_params_for(__MODULE__, factory_name, attrs)
        end

        def params_with_assocs(factory_name, attrs \\ %{}) do
          ExMachina.ExMachinaCustomEcto.params_with_assocs(__MODULE__, factory_name, attrs)
        end

        def string_params_with_assocs(factory_name, attrs \\ %{}) do
          ExMachina.ExMachinaCustomEcto.string_params_with_assocs(__MODULE__, factory_name, attrs)
        end
      end
    else
      raise ArgumentError,
            """
            expected :repo to be given as an option. Example:
            use ExMachina.Ecto, repo: MyApp.Repo
            """
    end
  end

  defp verify_ecto_dep do
    unless Code.ensure_loaded?(Ecto) do
      raise "You tried to use ExMachina.Ecto, but the Ecto module is not loaded. " <>
              "Please add ecto to your dependencies."
    end
  end

  @doc """
  Builds a factory and inserts it into the database.
  The arguments are the same as `c:ExMachina.build/2`.
  """
  @callback insert(factory_name :: atom) :: any
  @callback insert(factory_name :: atom, attrs :: keyword | map()) :: any

  @doc """
  Builds two factories and inserts them into the database.
  The arguments are the same as `c:ExMachina.build_pair/2`.
  """
  @callback insert_pair(factory_name :: atom) :: list
  @callback insert_pair(factory_name :: atom, attrs :: keyword | map()) :: list

  @doc """
  Builds many factories and inserts them into the database.
  The arguments are the same as `c:ExMachina.build_list/3`.
  """
  @callback insert_list(number_of_records :: integer, factory_name :: atom) :: list
  @callback insert_list(
              number_of_records :: integer,
              factory_name :: atom,
              attrs :: keyword | map
            ) :: list

  @doc """
  Builds a factory and returns only its fields.

  This is only for use with Ecto models.

  Will return a map with the fields and virtual fields, but without the Ecto
  metadata, the primary key, or any `belongs_to` associations. This will
  recursively act on `has_one` associations and Ecto structs found in
  `has_many` associations.

  If you want `belongs_to` associations to be inserted, use
  `c:params_with_assocs/2`.

  If you want params with string keys use `c:string_params_for/2`.

  ## Example

      def user_factory do
        %MyApp.User{name: "John Doe", admin: false}
      end

      # Returns %{name: "John Doe", admin: true}
      params_for(:user, admin: true)

      # Returns %{name: "John Doe", admin: false}
      params_for(:user)
  """
  @callback params_for(factory_name :: atom) :: %{optional(atom) => any}
  @callback params_for(factory_name :: atom, attrs :: keyword | map()) :: %{optional(atom) => any}

  @doc false
  def params_for(module, factory_name, attrs \\ %{}) do
    factory_name
    |> module.build(attrs)
    |> recursively_strip(:params_for)
  end

  @doc """
  Similar to `c:params_for/2` but converts atom keys to strings in returned map.

  The result of this function can be safely used in controller tests for Phoenix
  web applications.

  ## Example

      def user_factory do
        %MyApp.User{name: "John Doe", admin: false}
      end

      # Returns %{"name" => "John Doe", "admin" => true}
      string_params_for(:user, admin: true)
  """
  @callback string_params_for(factory_name :: atom) :: %{optional(String.t()) => any}
  @callback string_params_for(factory_name :: atom, attrs :: keyword | map()) :: %{
              optional(String.t()) => any
            }

  @doc false
  def string_params_for(module, factory_name, attrs \\ %{}) do
    factory_name
    |> module.build(attrs)
    |> recursively_strip(:string_params_for)
    |> convert_atom_keys_to_strings()
  end

  @doc """
  Similar to `c:params_for/2` but inserts all `belongs_to` associations and
  sets the foreign keys.

  If you want params with string keys use `c:string_params_with_assocs/2`.

  ## Example

      def article_factory do
        %MyApp.Article{title: "An Awesome Article", author: build(:author)}
      end

      # Inserts an author and returns %{title: "An Awesome Article", author_id: 12}
      params_with_assocs(:article)
  """
  @callback params_with_assocs(factory_name :: atom) :: %{optional(atom) => any}
  @callback params_with_assocs(factory_name :: atom, attrs :: keyword | map()) :: %{
              optional(atom) => any
            }

  @doc false
  def params_with_assocs(module, factory_name, attrs \\ %{}) do
    factory_name
    |> module.build(attrs)
    |> insert_belongs_to_assocs(module)
    |> recursively_strip(:params_with_assocs)
  end

  @doc """
  Similar to `c:params_with_assocs/2` but converts atom keys to strings in
  returned map.

  The result of this function can be safely used in controller tests for Phoenix
  web applications.

  ## Example

      def article_factory do
        %MyApp.Article{title: "An Awesome Article", author: build(:author)}
      end

      # Inserts an author and returns %{"title" => "An Awesome Article", "author_id" => 12}
      string_params_with_assocs(:article)
  """
  @callback string_params_with_assocs(factory_name :: atom) :: %{optional(String.t()) => any}
  @callback string_params_with_assocs(factory_name :: atom, attrs :: keyword | map()) :: %{
              optional(String.t()) => any
            }

  @doc false
  def string_params_with_assocs(module, factory_name, attrs \\ %{}) do
    factory_name
    |> module.build(attrs)
    |> insert_belongs_to_assocs(module)
    |> recursively_strip(:string_params_with_assocs)
    |> convert_atom_keys_to_strings()
  end

  defp recursively_strip(list, method) when is_list(list) do
    list
    |> Enum.map(&recursively_strip(&1, method))
    |> Enum.reject(&is_nil/1)
  end

  defp recursively_strip(%{__struct__: module}, _method)
       when module in @nil_structs do
    nil
  end

  defp recursively_strip(%{__struct__: module} = record, method)
       when module in @string_structs and
              method in [
                :string_params_for,
                :string_params_with_assocs
              ] do
    record |> to_string()
  end

  defp recursively_strip(%{__struct__: module} = record, _method)
       when module in @string_structs do
    record
  end

  defp recursively_strip(%{__struct__: module} = record, method)
       when method in [
              :params_for,
              :params_with_assocs
            ] do
    if Map.has_key?(record, :__meta__) or Kernel.function_exported?(module, :__schema__, 1) do
      record
      |> set_persisted_belongs_to_ids
      |> handle_assocs(method)
      |> handle_embeds(method)
      |> drop_ecto_fields
      |> recursively_strip(method)
    else
      record
      |> Map.from_struct()
      |> recursively_strip(method)
    end
  end

  defp recursively_strip(%{__struct__: module} = record, method)
       when method in [
              :string_params_for,
              :string_params_with_assocs
            ] do
    if Map.has_key?(record, :__meta__) or Kernel.function_exported?(module, :__schema__, 1) do
      record
      |> set_persisted_belongs_to_ids
      |> handle_assocs(method)
      |> handle_embeds(method)
      |> drop_ecto_fields
      |> recursively_strip(method)
    else
      record
      |> Map.from_struct()
      |> recursively_strip(method)
    end
  end

  defp recursively_strip(record, method) when is_map(record) do
    for {k, v} <- record, v != nil, into: %{} do
      {k, recursively_strip(v, method)}
    end
    |> drop_fields_with_nil_values()
  end

  defp recursively_strip(record, _method), do: record

  defp handle_assocs(%{__struct__: struct} = record, method) do
    Enum.reduce(struct.__schema__(:associations), record, fn association_name, record ->
      case struct.__schema__(:association, association_name) do
        %{__struct__: Ecto.Association.BelongsTo} ->
          Map.delete(record, association_name)

        _ ->
          record
          |> Map.get(association_name)
          |> handle_assoc(record, association_name, method)
      end
    end)
  end

  defp handle_assoc(original_assoc, record, association_name, method) do
    case original_assoc do
      %{__meta__: %{__struct__: Ecto.Schema.Metadata, state: :built}} ->
        assoc = recursively_strip(original_assoc, method)
        Map.put(record, association_name, assoc)

      nil ->
        Map.put(record, association_name, nil)

      list when is_list(list) ->
        has_many_assoc = Enum.map(original_assoc, &recursively_strip(&1, method))
        Map.put(record, association_name, has_many_assoc)

      %{__struct__: Ecto.Association.NotLoaded} ->
        Map.delete(record, association_name)
    end
  end

  defp handle_embeds(%{__struct__: struct} = record, method) do
    Enum.reduce(struct.__schema__(:embeds), record, fn embed_name, record ->
      record
      |> Map.get(embed_name)
      |> handle_embed(record, embed_name, method)
    end)
  end

  defp handle_embed(original_embed, record, embed_name, method) do
    case original_embed do
      %{} ->
        embed = recursively_strip(original_embed, method)
        Map.put(record, embed_name, embed)

      list when is_list(list) ->
        embeds_many = Enum.map(original_embed, &recursively_strip(&1, method))
        Map.put(record, embed_name, embeds_many)

      nil ->
        Map.delete(record, embed_name)
    end
  end

  defp set_persisted_belongs_to_ids(%{__struct__: struct} = record) do
    Enum.reduce(struct.__schema__(:associations), record, fn association_name, record ->
      association = struct.__schema__(:association, association_name)

      case association do
        %{__struct__: Ecto.Association.BelongsTo} ->
          case Map.get(record, association_name) do
            belongs_to = %{__meta__: %{__struct__: Ecto.Schema.Metadata, state: :loaded}} ->
              set_belongs_to_primary_key(record, belongs_to, association)

            _ ->
              record
          end

        _ ->
          record
      end
    end)
  end

  defp set_belongs_to_primary_key(record, belongs_to, association) do
    primary_key = Map.get(belongs_to, association.related_key)
    Map.put(record, association.owner_key, primary_key)
  end

  defp insert_belongs_to_assocs(%{__struct__: struct} = record, module) do
    Enum.reduce(struct.__schema__(:associations), record, fn association_name, record ->
      case struct.__schema__(:association, association_name) do
        association = %{__struct__: Ecto.Association.BelongsTo} ->
          insert_built_belongs_to_assoc(module, association, record)

        _ ->
          record
      end
    end)
  end

  defp insert_built_belongs_to_assoc(module, association, record) do
    case Map.get(record, association.field) do
      built_relation = %{__meta__: %{state: :built}} ->
        relation = module.insert(built_relation)
        set_belongs_to_primary_key(record, relation, association)

      _ ->
        Map.delete(record, association.owner_key)
    end
  end

  @doc false
  def drop_ecto_fields(%{__struct__: struct} = record) do
    record
    |> Map.from_struct()
    |> Map.delete(:__meta__)
    |> drop_autogenerated_ids(struct)
  end

  def drop_ecto_fields(embedded_record), do: embedded_record

  defp drop_autogenerated_ids(map, struct) do
    case struct.__schema__(:autogenerate_id) do
      {name, _source, _type} -> Map.delete(map, name)
      {name, _type} -> Map.delete(map, name)
      nil -> map
    end
  end

  defp drop_fields_with_nil_values(map) do
    map
    |> Enum.reject(fn {_, value} -> value == nil end)
    |> Enum.into(%{})
  end

  defp convert_atom_keys_to_strings(values) when is_list(values) do
    Enum.map(values, &convert_atom_keys_to_strings/1)
  end

  defp convert_atom_keys_to_strings(%{__struct__: module} = record)
       when module in @string_structs do
    record |> to_string()
  end

  defp convert_atom_keys_to_strings(%{__struct__: _} = record) when is_map(record) do
    Map.from_struct(record) |> convert_atom_keys_to_strings()
  end

  defp convert_atom_keys_to_strings(record) when is_map(record) do
    Enum.reduce(record, Map.new(), fn {key, value}, acc ->
      Map.put(acc, to_string(key), convert_atom_keys_to_strings(value))
    end)
  end

  defp convert_atom_keys_to_strings(value), do: value
end

defmodule ChatDB.Randoms do
  @moduledoc """
  Generates randomized fields.
  """

  use ExMachina.ExMachinaCustomEcto, repo: IMessageX.Repo

  # credo:disable-for-this-file

  alias DarkMatter.Decimals

  alias Faker.Address, as: FakerAddress
  # alias Faker.Address.En, as: FakerAddressEn
  alias Faker.Date, as: FakerDate
  alias Faker.DateTime, as: FakerDateTime
  alias Faker.File, as: FakerFile
  # alias Faker.Internet, as: FakerInternet
  alias Faker.Internet.UserAgent, as: FakerUserAgent
  alias Faker.Lorem, as: FakerLorem
  alias Faker.Person.En, as: FakerPerson
  # alias Faker.Phone.EnUs, as: FakerPhone
  alias Faker.String, as: FakerString

  require Logger

  defdelegate pick(enum), to: Faker.Util
  defdelegate digit(), to: Faker.Util

  @doc """
  Choses a random entry from `enum`.
  """
  def random(:xml), do: "<xml></xml>"
  def random(:map), do: %{}
  def random(:array), do: []
  def random(:guid), do: Faker.UUID.v4()
  def random(:uuid), do: Faker.UUID.v4()
  def random(:stream_uuid), do: random(:uuid)
  def random(:primary_key), do: random(:pos_integer)
  def random(:binary), do: Faker.random_bytes(128)
  def random(:float), do: Faker.random_uniform()
  def random(:integer), do: Faker.random_between(-1_000_000, 1_000_000)
  def random(:pos_integer), do: Faker.random_between(1, 1_000_000)
  def random(:decimal), do: random_decimal()
  def random(:text), do: FakerLorem.paragraph()
  def random(:string), do: Faker.String.base64()
  def random(:boolean), do: pick([true, false])
  def random(:date), do: FakerDate.backward(100)
  def random(:datetime), do: FakerDateTime.backward(100)
  def random(:naive_datetime), do: random(:datetime)
  def random(:naive_datetime_usec), do: random(:datetime)
  def random(:utc_datetime), do: random(:datetime)
  def random(:utc_datetime_usec), do: random(:datetime)
  def random(:time), do: Time.utc_now()
  def random(:time_usec), do: random(:time)
  def random({:array, type}), do: [random(type)]

  # iOS
  # def random(:boolean_int), do: pick([0, 1])
  def random(:boolean_int), do: pick([true, false])

  # Common
  def random(:short_id), do: Faker.UUID.v4() |> String.replace("-", "")

  # Users
  def random(:first_name), do: FakerPerson.first_name()
  def random(:middle_name), do: FakerPerson.first_name()
  def random(:last_name), do: FakerPerson.last_name()
  def random(:full_name), do: FakerPerson.name()

  # Internet
  def random(:url), do: FakerInternet.url()
  def random(:email), do: FakerInternet.email()

  def random(:domain),
    do: FakerInternet.domain_word() <> "-#{pick(0..999)}-" <> FakerInternet.domain_name()

  def random(:username), do: FakerInternet.user_name() <> "#{pick(0..999)}"
  def random(:user_agent), do: FakerUserAgent.user_agent()
  def random(:avatar_url), do: FakerInternet.image_url()
  def random(:identicon_url), do: FakerInternet.image_url()
  def random(:ip_address), do: FakerInternet.ip_v4_address()
  def random(:ip_address_v4), do: FakerInternet.ip_v4_address()
  def random(:ip_address_v6), do: FakerInternet.ip_v6_address()
  def random(:mac_address), do: FakerInternet.mac_address()
  def random(:filename), do: FakerFile.file_name()
  def random(:mime_type), do: FakerFile.mime_type()
  def random(:phone_number), do: random(:compressed_us_phone_number)
  def random(:us_phone_number), do: random(:compressed_us_phone_number)

  # Geolocation
  def random(:latitude), do: FakerAddress.latitude()
  def random(:longitude), do: FakerAddress.longitude()

  # def random(:email), do: random(:email, :string)
  # def random(:avatar_url), do: random(:avatar_url, :string)
  # def random(:identicon_url), do: random(:identicon_url, :string)
  # def random(:phone_number), do: random(:phone_number, :string)

  def random(_), do: nil

  # UUID
  # def random(:short_id, :string), do: Faker.UUID.v4() |> String.replace("-", "")

  # Documents
  def random(:image_b64, :string), do: FakerString.base64()

  # Default Cases
  def random(field, type) do
    case {random(field), random(type)} do
      {nil, nil} ->
        Logger.warn("""

        ------------------------------------------------
        `ChatDB.Randoms.random/2` was unable to generate a case for:

          iex> Randoms.random(#{inspect(field)}, #{inspect(type)})

        ------------------------------------------------
        """)

        nil

      {random_field, random_type} ->
        random_field || random_type
    end
  end

  def random(_module, field, type), do: random(field, type)

  @doc """
  Builds a random Decimal` between `min` and `max`.
  """
  def random_decimal, do: random_decimal(-1_000_000..1_000_000)

  def random_decimal(min..max) do
    min..max
    |> pick()
    |> Decimals.cast_decimal!(:normal)
  end

  @doc """
  Choses a random entry from either `enum` or between `first` and `last`.
  """
  def pick_random(enum) when is_list(enum), do: pick(enum)
  def pick_random(first..last), do: pick(first..last)
end

defmodule ChatDB.Factory do
  @moduledoc false
  alias ChatDB.Randoms

  alias ChatDB.Schemas.Attachment
  alias ChatDB.Schemas.Chat
  alias ChatDB.Schemas.Handle
  alias ChatDB.Schemas.Message

  # use ExMachina.ExMachinaCustomEcto, repo: ChatDB.Repo
  # use ExMachina.ExMachinaCustomEcto
  use ExMachina.Ecto

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

ExUnit.start()
