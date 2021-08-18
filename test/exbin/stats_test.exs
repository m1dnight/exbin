defmodule ExBin.StatsTest do
  use ExBin.DataCase, async: true
  alias ExBin.{Repo, Snippet, Stats, Clock}
  import ExBin.Factory


  describe "average_length/0" do
    test "returns 0.0 if no snippets in DB" do
      assert Repo.all(Snippet) == []
      assert Stats.average_length == 0.0
    end

    test "returns correct average as a decimal" do
      insert!(:snippet, %{content: "12345"})
      insert!(:snippet, %{content: "1234567890"})
      assert Stats.average_length == 7.5
    end
  end


  describe "count_snippets/0" do
    test "returns 0 if no snippets in DB" do
      assert Repo.all(Snippet) == []
      assert Stats.count_snippets == 0
    end

    test "returns correct number of snippets in DB as integer" do
      insert!(:snippet)
      insert!(:snippet)
      insert!(:snippet)
      assert Stats.count_snippets == 3
    end
  end

  describe "count_public_private/0" do
    test "returns correct 0 counts if no snippets in DB" do
      assert Repo.all(Snippet) == []
      assert %{private: 0, public: 0} == Stats.count_public_private
    end

    test "returns correct counts when only private snippets exist" do
      insert!(:snippet)
      insert!(:snippet)
      assert %{private: 2, public: 0} == Stats.count_public_private
    end

    test "returns correct counts when only public snippets exist" do
      insert!(:snippet, %{private: false})
      insert!(:snippet, %{private: false})
      assert %{private: 0, public: 2} == Stats.count_public_private
    end

    test "returns correct counts when both private and public snippets exist" do
      insert!(:snippet, %{private: true})
      insert!(:snippet, %{private: false})
      insert!(:snippet, %{private: false})
      assert %{private: 1, public: 2} == Stats.count_public_private
    end
  end


  describe "average_viewcount/0" do
    test "returns 0.0 if no snippets in DB" do
      assert Repo.all(Snippet) == []
      assert Stats.average_viewcount == 0.0
    end

    test "return correct average viewcount of all snippets, regardless of their public/private status" do
      insert!(:snippet, %{viewcount: 5, private: true})
      insert!(:snippet, %{viewcount: 10, private: false})
      assert Stats.average_viewcount == 7.5
    end
  end

  describe "most_popular/0" do
    test "returns nil if no snippets in DB" do
      assert Repo.all(Snippet) == []
      assert Stats.most_popular == nil
    end

    test "returns the correct (public) snippet if a private snippet has a higher viewcount than a public" do
      insert!(:snippet, %{private: true, viewcount: 100})
      less_popular = insert!(:snippet, %{private: false, viewcount: 10})
      assert less_popular == Stats.most_popular
    end

    test "returns most recent of two snippets if both have the same view count" do
      # Inserts them in reverse order of their given inserted_at dates, just to be sneaky.
      latest = insert!(:snippet, %{private: false, viewcount: 100, inserted_at: ~U[2021-08-07 00:00:00.000000Z]})
      insert!(:snippet, %{private: false, viewcount: 100, inserted_at: ~U[2021-08-05 00:00:00.000000Z]})
      assert latest == Stats.most_popular
    end
  end

  describe "count_per_month/0" do
    test "returns desired result structure if no snippets in DB" do

    end

    test "returns correct results for user time zone if snippet is created just before month rollover in UTC time" do

    end

    test "returns correct results for user time zone if snippet is created just after month rollover in UTC time" do

    end

    test "returns correct results for user time zone if snippet created just before month rollover in local time" do

    end

    test "returns correct results for user time zone if snippet created just after month rollover in local time" do

    end
  end
end
