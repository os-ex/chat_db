defmodule ChatDB.Contacts.PhotoCache do
  @moduledoc """
  The Contacts Photo Cache context.
  """

  alias ChatDB.Config

  def get(
        %Config{
          # photo_cache_dir: photo_cache_dir
        },
        key
      )
      when is_binary(key) do
  end

  def put(
        %Config{
          # photo_cache_dir: photo_cache_dir
        },
        key,
        photo
      )
      when is_binary(key) and is_binary(photo) do
  end
end
