defmodule ChatDb.Schemas.Contact do
  @moduledoc """
  Schema for `ChatDb.Schemas.Contact`.
  """

  # use PropSchema
  # import Ecto.Changeset

  @ignore_keys ["prodid", "version"]
  @group_keys ["tel", "adr", "x-abadr", "x-socialprofile", "impp", "email", "url", "caluri"]

  @duplicates [:tel, :adr, :x_abadr, :x_socialprofile, :impp, :email, :url, :caluri, :photo]

  @renames %{
    n: :name,
    fn: :fullname,
    x_socialprofile: :social_profiles,
    url: :urls,
    photo: :photos,
    email: :emails,
    adr: :addresses,
    tel: :phone_numbers,
    impp: :impps,
    caluri: :cal_uris
  }

  # @typedoc """
  # Struct type for `ChatDb.Schemas.Contact`.
  # """
  # @type t() :: %__MODULE__{
  #         # __meta__: Ecto.Schema.Metadata.t(),
  #         # chat_id: foreign_key :: pos_integer() | nil,
  #         # handle_id: binary_foreign_key :: String.t() | nil,
  #         # # inserted_at: DateTime.t() | nil,
  #         # # updated_at: DateTime.t() | nil,
  #         # chat: Chat.t() | Ecto.Association.NotLoaded.t() | nil,
  #         # handle: Handle.t() | Ecto.Association.NotLoaded.t() | nil
  #       }

  # @primary_key false
  # prop_embedded_schema do
  #   prop_field(:handle_id, :string, required: true)

  #   # timestamps(type: :utc_datetime_usec)
  # end

  # @doc """
  # Changeset based on `struct` and `params`.
  # """
  # @spec changeset(t() | Ecto.Changeset.t(), map()) :: Ecto.Changeset.t()
  # def changeset(struct, params \\ %{}) do
  #   struct
  #   |> cast(params, [])
  #   # |> cast_assoc(:chat)
  #   # |> cast_assoc(:handle)
  #   |> validate_required([])
  # end

  def sanitize_phone_number(phone_number) when is_binary(phone_number) do
    phone_number
    |> String.replace("+1", "")
    |> String.replace(~r/\D+/, "")
  end

  def cast(["vcard", fields, []]) when is_list(fields) do
    params =
      for entry <- fields, kv = do_cast(entry), kv not in [:ignore] do
        kv
      end

    dupes =
      for key <- @duplicates, into: %{} do
        vals = Keyword.get_values(params, key)
        {key, vals}
      end

    struct_params =
      params
      |> Enum.into(%{})
      |> Map.merge(dupes)
      |> Enum.into(%{}, fn {k, v} ->
        k_next = @renames[k] || k
        {k_next, v}
      end)

    name =
      case struct_params do
        %{fullname: %{value: fullname}} when is_binary(fullname) -> fullname
        _ -> "Unknown"
      end
      |> String.trim()

    initials =
      name
      |> String.split()
      |> Enum.map(&String.slice(&1, 0..0))
      |> Enum.join("")
      |> String.upcase()

    numbers = struct_params.phone_numbers |> Enum.map(& &1.value)

    number =
      case numbers do
        [] -> "Unknown"
        [number | _] -> number
      end

    struct_params =
      struct_params
      |> Map.merge(%{
        initials: initials,
        identifier_name: name,
        identifier_number: number,
        identifier_numbers: numbers |> Enum.map(&sanitize_phone_number/1)
      })

    # struct(__MODULE__, struct_params)
  end

  def cast2(["vcard", fields]) when is_list(fields) do
    # Enum.into(fields, %{}, fn
    fields
    |> Enum.into([], fn
      ["prodid", %{}, "text", prodid] ->
        {:prodid, prodid}

      ["version", %{}, "text", version] ->
        {:version, version}

      ["n", %{}, "text", names] ->
        {:names, names}

      ["fn", %{}, "text", fullname] ->
        {:fullname, fullname}

      # {:fullname, fullname |> String.trim() |> String.replace(~r/\W+/, " ")}

      ["tel", _props, "text", phone_number] ->
        {:phone_number, phone_number}

      # [
      #   "tel",
      #   %{"pref" => "1", "type" => ["HOME", "VOICE"]},
      #   "text",
      #   "(301) 904-5644"
      # ]

      # [
      #   "x-socialprofile",
      #   %{
      #     "type" => "facebook",
      #     "x-displayname" => ["Bethany Stafford"],
      #     "x-userid" => ["9016070"]
      #   },
      #   "unknown",
      #   "http://www.facebook.com/BStaff"
      # ]

      [
        "x-socialprofile",
        %{
          "type" => "facebook",
          "x-displayname" => display_names,
          "x-userid" => user_ids
        },
        "unknown",
        url
      ]
      when is_list(display_names) and is_list(user_ids) ->
        {:facebook, %{display_names: display_names, user_ids: user_ids, url: url}}

      [
        "x-socialprofile",
        %{
          "type" => "facebook",
          "x-displayname" => display_names
        },
        "unknown",
        url
      ]
      when is_list(display_names) and is_binary(url) ->
        {:facebook, %{display_names: display_names, user_ids: [], url: url}}

      [
        "x-socialprofile",
        %{
          "type" => "twitter",
          "x-displayname" => display_names,
          "x-userid" => user_ids
        },
        "unknown",
        url
      ]
      when is_binary(url) ->
        {:twitter, %{display_names: display_names, user_ids: user_ids, url: url}}

      ["x-socialprofile", %{"type" => "Instagram"}, "unknown", url] when is_binary(url) ->
        {:instagram, %{url: url}}

      ["x-socialprofile", %{"type" => "WhatsApp"}, "unknown", url] when is_binary(url) ->
        {:whats_app, %{url: url}}

      [
        "x-socialprofile",
        %{"type" => "linkedin"},
        "unknown",
        url
      ]
      when is_binary(url) ->
        {:linkedin, %{url: url}}

      [
        "x-socialprofile",
        %{"type" => "gamecenter", "x-user" => usernames},
        "unknown",
        url
      ]
      when is_list(usernames) and is_binary(url) ->
        {:gamecenter, %{usernames: usernames, url: url}}

      # "xmpp:03xv5or4j3lxn0rs4v5o4vrsls@public.talk.google.com"
      [
        "impp",
        %{"pref" => "1", "type" => "HOME", "x-service-type" => ["GoogleTalk"]},
        "uri",
        url
      ]
      when is_binary(url) ->
        {:impp_google_talk, %{url: url}}

      # "xmpp:jenschottlandohara"
      [
        "impp",
        %{"pref" => "1", "x-service-type" => ["Facebook"]},
        "uri",
        impp_facebook
      ]
      when is_binary(impp_facebook) ->
        {:impp_facebook, impp_facebook}

      [
        "impp",
        %{"x-service-type" => ["Facebook"]},
        "uri",
        impp_facebook
      ]
      when is_binary(impp_facebook) ->
        {:impp_facebook, impp_facebook}

      ["photo", %{}, "uri", "data:image/" <> img] ->
        {:photo_b64, "data:image/" <> img}

      ["org", %{}, "text", orgs] when is_list(orgs) ->
        {:orgs, orgs |> Enum.reject(&is_nil/1)}

      ["title", %{}, "text", title] when is_binary(title) ->
        {:title, title}

      ["email", %{"pref" => "1", "type" => "INTERNET"}, "text", email] when is_binary(email) ->
        {:email, email}

      ["email", %{"type" => "INTERNET"}, "text", email] when is_binary(email) ->
        {:email, email}

      ["email", %{"pref" => "1", "type" => ["INTERNET", "HOME"]}, "text", email]
      when is_binary(email) ->
        {:email, email}

      ["email", %{"type" => ["INTERNET", "HOME"]}, "text", email] when is_binary(email) ->
        {:email, email}

      ["email", %{"pref" => "1", "type" => ["INTERNET", "WORK"]}, "text", email]
      when is_binary(email) ->
        {:email, email}

      ["url", %{"group" => "ITEM1", "pref" => "1"}, "uri", url] when is_binary(url) ->
        {:url, url}

      ["url", %{"group" => "ITEM2", "pref" => "1"}, "uri", url] when is_binary(url) ->
        {:url, url}

      ["url", %{"group" => "ITEM2"}, "uri", url] when is_binary(url) ->
        {:url, url}

      ["url", %{"group" => "ITEM3"}, "uri", url] when is_binary(url) ->
        {:url, url}

      ["url", %{"group" => "ITEM4"}, "uri", url] when is_binary(url) ->
        {:url, url}

      ["url", %{"group" => "ITEM5"}, "uri", url] when is_binary(url) ->
        {:url, url}

      ["url", %{"group" => "ITEM6"}, "uri", url] when is_binary(url) ->
        {:url, url}

      [
        "caluri",
        %{"group" => "ITEM1", "pref" => "1"},
        "uri",
        mailto
      ]
      when is_binary(mailto) ->
        {:caluri, mailto}

      ["x-ablabel", %{"group" => "ITEM1"}, "unknown", "personal"] ->
        {:ablabel, nil}

      ["x-ablabel", %{"group" => "ITEM1"}, "unknown", "Móvil"] ->
        {:ablabel, nil}

      ["x-ablabel", %{"group" => "ITEM1"}, "unknown", "Profile"] ->
        {:ablabel, nil}

      ["x-ablabel", %{"group" => "ITEM2"}, "unknown", "Profile"] ->
        {:ablabel, nil}

      ["x-ablabel", %{"group" => "ITEM3"}, "unknown", "Profile"] ->
        {:ablabel, nil}

      ["x-ablabel", %{"group" => "ITEM1"}, "unknown", "_$!<HomePage>!$_"] ->
        {:ablabel, nil}

      ["x-ablabel", %{"group" => "ITEM2"}, "unknown", "_$!<HomePage>!$_"] ->
        {:ablabel, nil}

      ["x-ablabel", %{"group" => "ITEM3"}, "unknown", "_$!<HomePage>!$_"] ->
        {:ablabel, nil}

      ["x-ablabel", %{"group" => "ITEM4"}, "unknown", "_$!<HomePage>!$_"] ->
        {:ablabel, nil}

      ["x-ablabel", %{"group" => "ITEM5"}, "unknown", "_$!<HomePage>!$_"] ->
        {:ablabel, nil}

      ["x-ablabel", %{"group" => "ITEM6"}, "unknown", "_$!<HomePage>!$_"] ->
        {:ablabel, nil}

      ["x-ablabel", %{"group" => "ITEM1"}, "unknown", "Obsolete"] ->
        {:ablabel, nil}

      ["x-ablabel", %{"group" => "ITEM1"}, "unknown", "_$!<Other>!$_"] ->
        {:ablabel, nil}

      ["x-ablabel", _props, _unknown, _name] ->
        {:ablabel, nil}

      ["x-abadr", %{"group" => "ITEM1"}, "unknown", "us"] ->
        {:abadr, nil}

      ["x-abadr", %{"group" => "ITEM2"}, "unknown", "us"] ->
        {:abadr, nil}

      ["x-abadr", _props, _unknown, _name] ->
        {:abadr, nil}

      ["nickname", %{}, "text", nickname] when is_binary(nickname) ->
        {:nickname, nickname}

      # ["", "", "", "Pittsford", "New York", "", "United States"]
      [
        "adr",
        %{"pref" => "1", "type" => "HOME"},
        "text",
        home_address
      ]
      when is_list(home_address) ->
        {:home_address, home_address}

      [
        "adr",
        %{"type" => "HOME"},
        "text",
        home_address
      ]
      when is_list(home_address) ->
        {:home_address, home_address}

      # ["", "", "PO Box 5", "Canisteo", "NY", "14823", "USA"]
      [
        "adr",
        %{"pref" => "1", "type" => "WORK"},
        "text",
        work_address
      ]
      when is_list(work_address) ->
        {:work_address, work_address}

      [
        "adr",
        %{"type" => "WORK"},
        "text",
        work_address
      ]
      when is_list(work_address) ->
        {:work_address, work_address}

      [
        "adr",
        %{"type" => "OTHER"},
        "text",
        other_address
      ]
      when is_list(other_address) ->
        {:other_address, other_address}

      # "--11-02"
      ["bday", %{}, "date-and-or-time", birthday] when is_binary(birthday) ->
        {:birthday, birthday}

      ["kind", %{}, "text", kind] when is_binary(kind) ->
        {:kind, kind}
    end)
    |> Enum.into(%{})

    # |> Enum.sort()
    # |> Enum.map(fn {k, v} -> [k, v] end)
  end

  defp do_cast(["bday", %{}, "date-and-or-time", "--" <> month_and_day]) do
    [month, day] = month_and_day |> String.split("-") |> Enum.map(&String.to_integer/1)
    {:birthday, %{month: month, day: day, year: nil}}
  end

  defp do_cast(["bday", %{}, "date-and-or-time", birthday]) when is_binary(birthday) do
    [year, month, day] = birthday |> String.split("-") |> Enum.map(&String.to_integer/1)
    {:birthday, %{month: month, day: day, year: year}}
  end

  defp do_cast(["kind", %{}, "text", kind]) when is_binary(kind) do
    {:kind, kind}
  end

  defp do_cast(["nickname", %{}, "text", nickname]) when is_binary(nickname) do
    {:nickname, nickname}
  end

  defp do_cast([key, _details, _type, _kind]) when key in @ignore_keys do
    :ignore
  end

  defp do_cast([key, params, type, value]) when is_binary(key) do
    {String.to_atom(key), %{params: params, type: type, value: value}}
  end

  def tels(["vcard", fields] = jcard) when is_list(fields) do
    labels = x_ablabel_map(jcard)

    for ["x-ablabel", %{"group" => group} = details, category, type] <- fields, into: %{} do
      params = Map.merge(details, %{"category" => category, "type" => type})
      {group, params}
    end

    %{
      tel_home: nil,
      tel_voice: nil,
      tel_work: nil,
      tel_cell: nil
    }

    types = ["CELL", "HOME", "VOICE", "WORK"]
  end

  def x_ablabel_map(["vcard", fields]) when is_list(fields) do
    for ["x-ablabel", %{"group" => group} = details, category, type] <- fields, into: %{} do
      params = Map.merge(details, %{"category" => category, "type" => type})
      {group, params}
    end
  end

  def x_abadr_map(["vcard", fields]) when is_list(fields) do
    for ["x-abadr", %{"group" => group} = details, category, type] <- fields, into: %{} do
      params = Map.merge(details, %{"category" => category, "type" => type})
      {group, params}
    end
  end

  def extract(["vcard", fields], key) when is_list(fields) do
    for [^key, details, category, type] <- fields do
      {details, category, type}
    end
  end
end
