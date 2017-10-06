defmodule AggRager.SC2Test do
  use AggRager.DataCase

  alias AggRager.SC2

  describe "seasons" do
    alias AggRager.SC2.Season

    @valid_attrs %{end: ~N[2010-04-17 14:00:00.000000], sesason_number: "some sesason_number", start: ~N[2010-04-17 14:00:00.000000], year: "some year"}
    @update_attrs %{end: ~N[2011-05-18 15:01:01.000000], sesason_number: "some updated sesason_number", start: ~N[2011-05-18 15:01:01.000000], year: "some updated year"}
    @invalid_attrs %{end: nil, sesason_number: nil, start: nil, year: nil}

    def season_fixture(attrs \\ %{}) do
      {:ok, season} =
        attrs
        |> Enum.into(@valid_attrs)
        |> SC2.create_season()

      season
    end

    test "list_seasons/0 returns all seasons" do
      season = season_fixture()
      assert SC2.list_seasons() == [season]
    end

    test "get_season!/1 returns the season with given id" do
      season = season_fixture()
      assert SC2.get_season!(season.id) == season
    end

    test "create_season/1 with valid data creates a season" do
      assert {:ok, %Season{} = season} = SC2.create_season(@valid_attrs)
      assert season.end == ~N[2010-04-17 14:00:00.000000]
      assert season.sesason_number == "some sesason_number"
      assert season.start == ~N[2010-04-17 14:00:00.000000]
      assert season.year == "some year"
    end

    test "create_season/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = SC2.create_season(@invalid_attrs)
    end

    test "update_season/2 with valid data updates the season" do
      season = season_fixture()
      assert {:ok, season} = SC2.update_season(season, @update_attrs)
      assert %Season{} = season
      assert season.end == ~N[2011-05-18 15:01:01.000000]
      assert season.sesason_number == "some updated sesason_number"
      assert season.start == ~N[2011-05-18 15:01:01.000000]
      assert season.year == "some updated year"
    end

    test "update_season/2 with invalid data returns error changeset" do
      season = season_fixture()
      assert {:error, %Ecto.Changeset{}} = SC2.update_season(season, @invalid_attrs)
      assert season == SC2.get_season!(season.id)
    end

    test "delete_season/1 deletes the season" do
      season = season_fixture()
      assert {:ok, %Season{}} = SC2.delete_season(season)
      assert_raise Ecto.NoResultsError, fn -> SC2.get_season!(season.id) end
    end

    test "change_season/1 returns a season changeset" do
      season = season_fixture()
      assert %Ecto.Changeset{} = SC2.change_season(season)
    end
  end
end
