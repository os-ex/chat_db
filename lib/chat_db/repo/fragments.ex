defmodule ChatDb.Repo.Fragments do
  @moduledoc """
  iMessage chatdb fragments.
  """

  def unix_datetime(name) when is_binary(name) do
    ~s{datetime(#{name}/1000000000 + strftime("%s", "2001-01-01"), "unixepoch", "localtime")}
  end

  def select_max(name, as: as) when is_binary(name) and is_atom(as) do
    [table, field] = String.split(name, ".")

    """
    SELECT
      MAX(#{table}.#{field}) AS #{as}
    FROM
      #{table}
    """
  end
end
