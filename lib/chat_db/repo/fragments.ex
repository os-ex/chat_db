defmodule ChatDB.Repo.Fragments do
  @moduledoc """
  iMessage chatdb fragments.
  """

  defmacro unix_datetime(name) when is_binary(name) do
    quote do
      ~s{datetime(#{unquote(name)}/1000000000 + strftime("%s", "2001-01-01"), "unixepoch", "localtime")}
    end
  end

  defmacro select_max(name, opts \\ []) when is_binary(name) do
    [table, field] = String.split(name, ".")
    maybe_as = field_alias(opts)

    quote do
      """
      SELECT
        MAX(#{unquote(table)}.#{unquote(field)})#{unquote(maybe_as)}
      FROM
        #{unquote(table)}
      """
    end
  end

  def field_alias(opts) when is_list(opts) do
    case Keyword.get(opts, :as) do
      "" -> ""
      "" -> ""
      as when is_atom(as) -> " AS #{as}"
      as when is_binary(as) -> " AS #{as}"
      _ -> ""
    end
  end
end
