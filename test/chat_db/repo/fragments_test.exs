defmodule ChatDb.Repo.FragmentsTest do
  @moduledoc false

  use ExUnit.Case, async: true

  alias ChatDb.Repo.Fragments
  require ChatDb.Repo.Fragments

  describe ".unix_datetime/1" do
    test "with 'message.date' it returns valid sql" do
      name = "message.date"
      result = Fragments.unix_datetime(name)

      assert result ==
               ~S{datetime(message.date/1000000000 + strftime("%s", "2001-01-01"), "unixepoch", "localtime")}
    end
  end

  describe ".select_max/2" do
    test "with 'message.date' and {:as, :max_date} it returns valid sql" do
      name = "message.date"

      assert Fragments.select_max(name, as: :max_date) ==
               """
               SELECT
                 MAX(message.date) AS max_date
               FROM
                 message
               """
    end
  end
end
