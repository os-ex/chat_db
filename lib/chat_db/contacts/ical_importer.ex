defmodule ChatDB.Contacts.ICalImporter do
  @moduledoc """
  The Contacts Photo Cache context.
  """

  alias ChatDB.Schemas.Contact

  alias ChatDB.Config

  # alias ChatDB.Contacts.ContactCache
  # alias ChatDB.Contacts.PhotoCache

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

  def transform(filename, output) when is_binary(filename) and is_binary(output) do
    with :ok <- file_exists_ok(filename),
         {_stdout, 0} <- cmd_vcards_to_jcards(filename, output) do
      :ok
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
