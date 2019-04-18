defmodule TestData do
  def random_boolean() do
    :rand.uniform() > 0.5
  end

  @seconds_per_day 60 * 60 * 24
  defp now_in_seconds do
    :calendar.local_time() |> :calendar.datetime_to_gregorian_seconds()
  end

  defp convert_seconds_to_date(seconds) do
    :calendar.gregorian_seconds_to_datetime(seconds)
    |> Tuple.to_list()
    |> Enum.at(0)
  end

  def backward(range) when is_map(range) do
    range
    |> Enum.random()
    |> backward
  end

  def backward(days) when days >= 1 do
    do_create_date(days, :backward)
  end

  defp do_create_date(days, type) do
    now_in_seconds()
    |> shift(days, type)
    |> convert_seconds_to_date
    |> create_date
  end

  defp shift(seconds, days, :forward) do
    days = @seconds_per_day * days
    seconds + days
  end

  defp shift(seconds, days, :backward) do
    days = @seconds_per_day * days
    seconds - days
  end

  defp create_date({year, month, day}) do
    date = %DateTime{
      year: year,
      month: month,
      day: day,
      hour: Enum.random(0..23),
      minute: Enum.random(0..59),
      second: Enum.random(0..59),
      microsecond: {0, 0},
      zone_abbr: "UTC",
      utc_offset: 0,
      std_offset: 0,
      time_zone: "Etc/UTC"
    }

    date
  end
end

1..1000
|> Stream.map(fn id ->
  snip = %ExBin.Snippet{
    content: Elixilorem.paragraph(),
    id: id,
    inserted_at: TestData.backward(1..1000),
    name: "#{id}",
    private: TestData.random_boolean(),
    updated_at: TestData.backward(1..1000),
    viewcount: 2
  }

  ExBin.Repo.insert(snip)
end)
|> Enum.to_list()
