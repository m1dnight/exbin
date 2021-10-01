# It's worth noting that ths test tests the features of Clock that work
# in the test environment ONLY, as the functionality differs based on
# compile_env. It seems weird to test code that's only use in testing,
# but hey, why not?
# One note is that we have to fudge a little bit on testing equality of
# "now()" functions, so we use the Timex.equal function truncated to
# 1-second granularity, basically assuming that the two datetimes
# are equivalent if they're within a single second of each other.
# It's not perfect, but it's close enough.
# Unfortunately because of this we have to sleep for 1.5 seconds in
# testing to ensure that the datetimes aren't equal if checked less
# than a second apart. Fortunately due to :async, this shouldn't
# slow down the overall tests too much.
defmodule Exbin.ClockTest do
  use ExUnit.Case, async: true
  require Exbin.Clock
  alias Exbin.Clock

  describe "utc_now/0" do
    test "returns correct datetime" do
      assert Timex.equal?(Clock.utc_now(), DateTime.utc_now())
    end
  end

  defmodule FreezeTest do
    use ExUnit.Case, async: true
    require Exbin.Clock
    alias Exbin.Clock

    describe "freezing the clock" do
      test "does not change the internal time while Clock is frozen" do
        Clock.freeze()
        start_time = Clock.utc_now()
        Process.sleep(1500)
        end_time = Clock.utc_now()
        Clock.unfreeze()

        assert start_time == end_time
      end

      test "freezes to requested time if one is given" do
        target = ~U[2001-12-25 12:17:39.0000Z]
        Clock.freeze(target)
        assert Clock.utc_now() == target
        Clock.unfreeze()
        refute Clock.utc_now() == target
      end
    end
  end

  defmodule ThawTest do
    use ExUnit.Case, async: true
    require Exbin.Clock
    alias Exbin.Clock

    describe "unfreeze/0" do
      test "restores to correct time after unfreezing" do
        Clock.freeze()
        Process.sleep(1500)
        refute Timex.equal?(Clock.utc_now(), DateTime.utc_now())
        Clock.unfreeze()

        assert Timex.equal?(Clock.utc_now(), DateTime.utc_now())
      end
    end
  end

  defmodule TimeTravelTest do
    use ExUnit.Case, async: true
    require Exbin.Clock
    alias Exbin.Clock

    describe "time_travel" do
      test "executes a block with time frozen at the given time, and restores to real time after block" do
        target = ~U[2001-12-25 12:17:39.0000Z]

        Clock.time_travel target do
          assert Clock.utc_now() == target
          Process.sleep(1500)
          assert Clock.utc_now() == target
        end

        assert Timex.equal?(Clock.utc_now(), DateTime.utc_now())
      end

      test "re-freezes time to where it was if it was frozen before the block" do
        long_ago = ~U[2001-12-25 12:17:39.0000Z]

        Clock.freeze()
        frozen_time = Clock.utc_now()

        Clock.time_travel long_ago do
          assert Clock.utc_now() == long_ago
        end

        assert Timex.equal?(Clock.utc_now(), frozen_time)
      end
    end
  end
end
