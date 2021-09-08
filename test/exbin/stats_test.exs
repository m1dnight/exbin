defmodule ExBin.StatsTest do
  use ExBin.DataCase, async: true
  alias ExBin.{Repo, Snippet, Stats, Clock}
  import ExBin.Factory

  @test_zone "Europe/Brussels" # Tests are running in UTC+2 timezone
  @utc_zone "Etc/UTC"

  test "ensure we're in the right timezone for the tests to work" do
    # We're going to hard-code some values to check against, so these tests are
    # only expected to work in that zone. So we'll do a quick sanity check
    # before we run the rest of the tests.
    assert Application.get_env(:exbin, :timezone) == @test_zone
  end

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
      # We're gong to pick a time that is unambiguous in any time zone as it relates to the "beginning of the month".
      # This allows us to hard-code a resulting structure to compare to.
      Clock.freeze(~U[2021-08-15 12:00:00.000000Z])
      empty_count = Stats.count_per_month

      assert empty_count == [
          {~N[2020-09-01 00:00:00], {0,0}},
          {~N[2020-10-01 00:00:00], {0,0}},
          {~N[2020-11-01 00:00:00], {0,0}},
          {~N[2020-12-01 00:00:00], {0,0}},
          {~N[2021-01-01 00:00:00], {0,0}},
          {~N[2021-02-01 00:00:00], {0,0}},
          {~N[2021-03-01 00:00:00], {0,0}},
          {~N[2021-04-01 00:00:00], {0,0}},
          {~N[2021-05-01 00:00:00], {0,0}},
          {~N[2021-06-01 00:00:00], {0,0}},
          {~N[2021-07-01 00:00:00], {0,0}},
          {~N[2021-08-01 00:00:00], {0,0}}
        ]
    end

    test "does not return results for snippets created before the begining of the 11th ago month" do
      # Results before 2020-09-01 should not be included in any bucket, even if they are within a year of "now"
      insert!(:snippet, %{private: true, inserted_at: Timex.to_datetime(~N[2001-08-16 12:00:00.000000], @utc_zone)})
      insert!(:snippet, %{private: true, inserted_at: Timex.to_datetime(~N[2019-08-16 12:00:00.000000], @utc_zone)})
      # This one should be 1 minute before it's 2020-09-01 in @test_zone, and so should still not be in the result set.
      insert!(:snippet, %{private: false, inserted_at: Timex.to_datetime(~N[2020-08-31 21:59:00.000000], @utc_zone)})
      # The very last minute pre-reporting-period in the testing TZ, and so should not be in result set.
      insert!(:snippet, %{private: true, inserted_at: Timex.to_datetime(~N[2020-08-31 23:59:00.000000], @test_zone) |> DateTime.shift_zone!(@utc_zone)})

      # If it is 2021-08-15, we we should be getting results from 2020-09-01 and forward.
      Clock.freeze(~U[2021-08-15 12:00:00.000000Z])
      assert Stats.count_per_month == [
          {~N[2020-09-01 00:00:00], {0,0}},
          {~N[2020-10-01 00:00:00], {0,0}},
          {~N[2020-11-01 00:00:00], {0,0}},
          {~N[2020-12-01 00:00:00], {0,0}},
          {~N[2021-01-01 00:00:00], {0,0}},
          {~N[2021-02-01 00:00:00], {0,0}},
          {~N[2021-03-01 00:00:00], {0,0}},
          {~N[2021-04-01 00:00:00], {0,0}},
          {~N[2021-05-01 00:00:00], {0,0}},
          {~N[2021-06-01 00:00:00], {0,0}},
          {~N[2021-07-01 00:00:00], {0,0}},
          {~N[2021-08-01 00:00:00], {0,0}}
        ]
    end

    # Note, this was the test that exposed the errors. Every other test worked, but this one was just missing results.
    # That is why this one has a bunch of extra data being checked. If they helped diagnose the problem the first time,
    # they'll help guard against it in the future.
    test "returns correct results for user time zone if snippet is created just before month rollover in UTC time" do
      # This snippet should be in 2020-09 since it's in the middle of the month
      insert!(:snippet, %{private: true, inserted_at: Timex.to_datetime(~N[2020-09-15 23:55:00.000000], @utc_zone)})
      # These snippets should be in the month bucket after their naive insert date, since it's 2 hours later in "our" timezone
      insert!(:snippet, %{private: true, inserted_at: Timex.to_datetime(~N[2020-08-31 23:55:00.000000], @utc_zone)})
      insert!(:snippet, %{private: false, inserted_at: Timex.to_datetime(~N[2020-08-31 23:55:00.000000], @utc_zone)})
      insert!(:snippet, %{private: false, inserted_at: Timex.to_datetime(~N[2020-09-30 23:55:00.000000], @utc_zone)})
      insert!(:snippet, %{private: false, inserted_at: Timex.to_datetime(~N[2020-10-31 23:55:00.000000], @utc_zone)})
      insert!(:snippet, %{private: false, inserted_at: Timex.to_datetime(~N[2020-11-30 23:55:00.000000], @utc_zone)})
      insert!(:snippet, %{private: false, inserted_at: Timex.to_datetime(~N[2020-12-31 23:55:00.000000], @utc_zone)})
      insert!(:snippet, %{private: false, inserted_at: Timex.to_datetime(~N[2021-01-31 23:55:00.000000], @utc_zone)})
      insert!(:snippet, %{private: false, inserted_at: Timex.to_datetime(~N[2021-02-28 23:55:00.000000], @utc_zone)})
      insert!(:snippet, %{private: true, inserted_at: Timex.to_datetime(~N[2021-03-31 23:55:00.000000], @utc_zone)})
      insert!(:snippet, %{private: true, inserted_at: Timex.to_datetime(~N[2021-03-31 23:56:00.000000], @utc_zone)})
      insert!(:snippet, %{private: false, inserted_at: Timex.to_datetime(~N[2021-03-31 23:55:00.000000], @utc_zone)})
      insert!(:snippet, %{private: false, inserted_at: Timex.to_datetime(~N[2021-03-31 23:56:00.000000], @utc_zone)})
      insert!(:snippet, %{private: false, inserted_at: Timex.to_datetime(~N[2021-06-30 23:55:00.000000], @utc_zone)})

      Clock.freeze(~U[2021-08-15 12:00:00.000000Z])
      assert Stats.count_per_month == [
          {~N[2020-09-01 00:00:00], {1,2}},
          {~N[2020-10-01 00:00:00], {1,0}},
          {~N[2020-11-01 00:00:00], {1,0}},
          {~N[2020-12-01 00:00:00], {1,0}},
          {~N[2021-01-01 00:00:00], {1,0}},
          {~N[2021-02-01 00:00:00], {1,0}},
          {~N[2021-03-01 00:00:00], {1,0}},
          {~N[2021-04-01 00:00:00], {2,2}},
          {~N[2021-05-01 00:00:00], {0,0}},
          {~N[2021-06-01 00:00:00], {0,0}},
          {~N[2021-07-01 00:00:00], {1,0}},
          {~N[2021-08-01 00:00:00], {0,0}}
        ]
    end

    test "returns correct results for user time zone if snippet is created just after month rollover in UTC time" do
      # This snippet should be in the month bucket of their naive insert date, since it's 2 hours later in "our" timezone
      insert!(:snippet, %{private: false, inserted_at: Timex.to_datetime(~N[2021-07-01 00:01:00.000000], @utc_zone)})
      insert!(:snippet, %{private: true, inserted_at: Timex.to_datetime(~N[2021-08-01 00:01:00.000000], @utc_zone)})
      
      Clock.freeze(~U[2021-08-15 12:00:00.000000Z])
      assert Stats.count_per_month == [
          {~N[2020-09-01 00:00:00], {0,0}},
          {~N[2020-10-01 00:00:00], {0,0}},
          {~N[2020-11-01 00:00:00], {0,0}},
          {~N[2020-12-01 00:00:00], {0,0}},
          {~N[2021-01-01 00:00:00], {0,0}},
          {~N[2021-02-01 00:00:00], {0,0}},
          {~N[2021-03-01 00:00:00], {0,0}},
          {~N[2021-04-01 00:00:00], {0,0}},
          {~N[2021-05-01 00:00:00], {0,0}},
          {~N[2021-06-01 00:00:00], {0,0}},
          {~N[2021-07-01 00:00:00], {1,0}},
          {~N[2021-08-01 00:00:00], {0,1}}
        ]
    end

    test "returns correct results for user time zone if snippet created just before month rollover in local time" do
      # This snippet should be in bucket for their insert time, since they were inserted in "our" timezone
      insert!(:snippet, %{private: false, inserted_at: Timex.to_datetime(~N[2020-09-01 00:01:00.000000], @test_zone) |> DateTime.shift_zone!(@utc_zone)})
      insert!(:snippet, %{private: false, inserted_at: Timex.to_datetime(~N[2021-07-01 00:01:00.000000], @test_zone) |> DateTime.shift_zone!(@utc_zone)})
      insert!(:snippet, %{private: true, inserted_at: Timex.to_datetime(~N[2021-08-01 00:01:00.000000], @test_zone) |> DateTime.shift_zone!(@utc_zone)})

      Clock.freeze(~U[2021-08-15 12:00:00.000000Z])
      assert Stats.count_per_month == [
          {~N[2020-09-01 00:00:00], {1,0}},
          {~N[2020-10-01 00:00:00], {0,0}},
          {~N[2020-11-01 00:00:00], {0,0}},
          {~N[2020-12-01 00:00:00], {0,0}},
          {~N[2021-01-01 00:00:00], {0,0}},
          {~N[2021-02-01 00:00:00], {0,0}},
          {~N[2021-03-01 00:00:00], {0,0}},
          {~N[2021-04-01 00:00:00], {0,0}},
          {~N[2021-05-01 00:00:00], {0,0}},
          {~N[2021-06-01 00:00:00], {0,0}},
          {~N[2021-07-01 00:00:00], {1,0}},
          {~N[2021-08-01 00:00:00], {0,1}}
        ]
    end

    test "returns correct results for user time zone if snippet created just after month rollover in local time" do
      # This snippet should be in bucket for their insert time, since they were inserted in "our" timezone
      insert!(:snippet, %{private: false, inserted_at: Timex.to_datetime(~N[2020-09-01 00:01:00.000000], @test_zone) |> DateTime.shift_zone!(@utc_zone)})
      insert!(:snippet, %{private: false, inserted_at: Timex.to_datetime(~N[2021-07-01 00:01:00.000000], @test_zone) |> DateTime.shift_zone!(@utc_zone)})
      insert!(:snippet, %{private: true, inserted_at: Timex.to_datetime(~N[2021-08-01 00:01:00.000000], @test_zone) |> DateTime.shift_zone!(@utc_zone)})
      
      Clock.freeze(~U[2021-08-15 12:00:00.000000Z])
      assert Stats.count_per_month == [
          {~N[2020-09-01 00:00:00], {1,0}},
          {~N[2020-10-01 00:00:00], {0,0}},
          {~N[2020-11-01 00:00:00], {0,0}},
          {~N[2020-12-01 00:00:00], {0,0}},
          {~N[2021-01-01 00:00:00], {0,0}},
          {~N[2021-02-01 00:00:00], {0,0}},
          {~N[2021-03-01 00:00:00], {0,0}},
          {~N[2021-04-01 00:00:00], {0,0}},
          {~N[2021-05-01 00:00:00], {0,0}},
          {~N[2021-06-01 00:00:00], {0,0}},
          {~N[2021-07-01 00:00:00], {1,0}},
          {~N[2021-08-01 00:00:00], {0,1}}
        ]
    end
  end
end
