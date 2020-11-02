defmodule ChatDb.Contacts.ICalImporter do
  @moduledoc """
  The Contacts Photo Cache context.
  """

  alias ChatDb.Schemas.Contact

  @mimes ["JPEG"]
  alias ChatDb.Config

  # alias ChatDb.Contacts.ContactCache
  # alias ChatDb.Contacts.PhotoCache

  @doc """
  Imports contacts from iCal.
  """
  @spec import_contacts(Config.t()) :: :ok | {:error, any()}
  def import_contacts(config \\ Config.read())

  def import_contacts(
        %Config{
          import_vcards_path: import_vcards_path,
          export_jcards_path: export_jcards_path,
          export_contacts_json_path: export_contacts_json_path
        } = config
      ) do
    with :ok <- transform(import_vcards_path, export_jcards_path),
         {:ok, jcards} <- read_json(export_jcards_path),
         :ok <- persist(config, jcards) do
      :ok
    end
  end

  def cast_contacts(jcards) do
    contact_cards = Enum.map(jcards, &Contact.cast/1)

    contact_cards
    |> Enum.reject(&is_tuple/1)
  end

  def persist(%Config{} = config, jcards) when is_list(jcards) do
    Enum.each(jcards, &persist(config, &1))
    :ok
  end

  def persist(
        %Config{
          # contact_cache_dir: contact_cache_dir,
          # photo_cache_dir: photo_cache_dir
        },
        jcard
      )
      when is_map(jcard) do
    # with :ok <- PhotoCache.put(config, jcard),
    #      :ok <- ContactCache.put(config, jcard) do
    #   :ok
    # end

    :ok
  end

  def separate_photos(%{photos: photos} = contact) do
    contact_without_photos = Map.put(contact, :photos, [])
    {contact_without_photos, photos}
  end

  def write_photo(path, %{
        params: %{encoding: "BASE64", type: type},
        type: "binary",
        value: value
      })
      when is_binary(path) and type in @mimes and is_binary(value) do
    with {:ok, binary} <- Base.decode64(value),
         :ok <- File.write(path, binary) do
      :ok
    end
  end

  def contact_identifier(%{identifier_number: identifier_number})
      when is_binary(identifier_number) do
    {:ok, identifier_number}
  end

  def read_photo_base64(path) when is_binary(path) do
    with {:ok, binary} <- File.read(path) do
      mime = MIME.type(binary)
      base64 = Base.encode64(binary)
      data = "data:image/#{mime},#{base64}"
      {:ok, data}
    end
  end

  def transform(filename, output) when is_binary(filename) and is_binary(output) do
    with :ok <- file_exists_ok(filename) do
      case cmd_vcards_to_jcards(filename, output) do
        {_stdout, 0} -> :ok
        {_, 126} -> {:error, :cmd_not_found}
        _ -> {:error, :unknown}
      end
    end
  end

  defp cmd_vcards_to_jcards(filename, output) when is_binary(filename) and is_binary(output) do
    System.cmd("node", ["bin/vcards-to-jcards.js", "-f", filename, "-o", output])
  end

  defp file_exists_ok(filename) when is_binary(filename) do
    if File.exists?(filename) do
      :ok
    else
      {:error, {:missing_file, filename}}
    end
  end

  def read_json(filename) when is_binary(filename) do
    with {:ok, binary} <- File.read(filename),
         {:ok, json} <- Jason.decode(binary, keys: :atoms) do
      {:ok, json}
    end
  end
end
