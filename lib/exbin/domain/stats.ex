defmodule ExBin.Domain.Statistics do
  alias ExBin.{Snippet, Repo}
  import Ecto.Query

  @doc """
  Computes the average length of a snippet.
  """
  def average_length() do
    if count_snippets() > 0 do
      query =
        from(s in Snippet,
          select: %{len: fragment("avg(length(?))", s.content)}
        )

      %{len: avg} = Repo.one(query)
      Decimal.to_float(avg)
    else
      0.0
    end
  end

  @doc """
  Count all the snippets.
  """
  def count_snippets() do
    Repo.one(from(s in Snippet, select: count(s.id)))
  end

  @doc """
  Groups snippets created per month and returns the totals per month for a year.
  """
  def stats_activity() do
    # {~U[2021-01-01 00:00:00Z], {{1, 2021}, 0}}
    # {~U[2021-02-01 00:00:00Z], {{2, 2021}, 0}}
    # {~U[2021-03-01 00:00:00Z], {{3, 2021}, 0}}
    # {~U[2021-04-01 00:00:00Z], {{4, 2021}, 17}}
    # {~U[2020-05-01 00:00:00Z], {{5, 2020}, 0}}
    # {~U[2020-06-01 00:00:00Z], {{6, 2020}, 0}}
    # {~U[2020-07-01 00:00:00Z], {{7, 2020}, 0}}
    # {~U[2020-08-01 00:00:00Z], {{8, 2020}, 0}}
    # {~U[2020-09-01 00:00:00Z], {{9, 2020}, 0}}
    # {~U[2020-10-01 00:00:00Z], {{10, 2020}, 0}}
    # {~U[2020-11-01 00:00:00Z], {{11, 2020}, 0}}
    # {~U[2020-12-01 00:00:00Z], {{12, 2020}, 0}}

    # {"['May','June','July','August','September','October','November','December','January','February','March','April']",
    #  "[0,0,0,0,0,0,0,0,0,0,0,17]"}

    # Create the buckets for last 12 months.
    curr_month =
      DateTime.now!("Etc/UTC")
      |> Timex.beginning_of_month()

    buckets =
      0..11
      |> Enum.reduce([], fn i, months ->
        [Timex.shift(curr_month, months: -1 * i) | months]
      end)
      |> Enum.map(&{&1, 0})
      |> Enum.into(%{})

    query =
      from(s in Snippet,
        select: %{
          month: fragment("date_trunc('month', ? AT TIME ZONE 'UTC')", s.inserted_at),
          count: fragment("count(*)")
        },
        where: fragment("date_trunc('month', ? AT TIME ZONE 'UTC') >= date_trunc('year', NOW())", s.inserted_at),
        group_by: fragment("date_trunc('month', ? AT TIME ZONE 'UTC')", s.inserted_at),
        order_by: fragment("date_trunc('month', ? AT TIME ZONE 'UTC') asc", s.inserted_at)
      )

    snippet_counts =
      Repo.all(query)
      |> Enum.map(&{&1.month, &1.count})
      |> Enum.into(%{})

    counts =
      buckets
      |> Map.merge(snippet_counts)
      |> Enum.into([])
      |> Enum.sort_by(&elem(&1, 0), &Timex.before?/2)

    # |> Enum.map(fn {d, c} ->
    #   month_name = d |> Map.get(:month) |> Timex.month_name()
    #   {month_name, c}
    # end)

    # # Compute the date a year ago. Only take stats for 1 year.
    # today = DateTime.utc_now()
    # yearago = %DateTime{today | year: today.year - 1}

    # # Generate the last
    # map =
    #   (Enum.to_list((yearago.month + 1)..12) ++ Enum.to_list(1..today.month))
    #   |> Enum.zip(List.duplicate(yearago.year, 12 - today.month) ++ List.duplicate(today.year, today.month))
    #   |> Enum.map(fn k -> {k, 0} end)
    #   |> Enum.into(%{})

    # {months, counts} =
    #   Repo.all(Snippet)
    #   |> Stream.map(fn s ->
    #     s.inserted_at
    #   end)
    #   |> Stream.map(fn dt ->
    #     year = dt.year
    #     month = dt.month
    #     {month, year}
    #   end)
    #   |> Enum.to_list()
    #   |> Enum.reduce(map, fn e, acc ->
    #     if Map.has_key?(acc, e) do
    #       Map.update!(acc, e, &(&1 + 1))
    #     else
    #       acc
    #     end
    #   end)
    #   |> Enum.map(fn {{m, y}, c} ->
    #     dt = Timex.to_datetime({{y, m, 1}, {0, 0, 0}}, "Etc/UTC")
    #     {dt, {{m, y}, c}}
    #   end)
    #   |> Enum.map(fn x ->
    #     IO.inspect(x)
    #     x
    #   end)
    #   |> Enum.filter(fn x -> not Kernel.match?({{:error, _}, _}, x) end)
    #   |> Enum.sort_by(fn {dt, _} -> dt end, &Timex.before?/2)
    #   |> Enum.map(fn {_, v} -> v end)
    #   |> Enum.map(fn {{m, y}, c} -> {{Timex.month_name(m), y}, c} end)
    #   |> Enum.unzip()

    # months_string =
    #   months
    #   |> Enum.map(fn {m, _} -> "'#{m}'" end)
    #   |> Enum.join(",")
    #   |> (fn s -> "[" <> s <> "]" end).()

    # values_string =
    #   counts
    #   |> Enum.join(",")
    #   |> (fn s -> "[" <> s <> "]" end).()

    # {months_string, values_string}
  end

  @doc """
  Compute the average views per snippet.
  """
  def compute_average_views() do
    result = Repo.one(from(s in Snippet, select: avg(s.viewcount)))

    if result do
      Decimal.to_float(result)
    else
      0.0
    end
  end

  @doc """
  Returns the most popular snippet by viewcount.
  Returns nil if no snippet is found.
  """
  def most_popular() do
    from(from(s in Snippet, where: s.private == false, order_by: [desc: :viewcount], limit: 1))
    |> Repo.one()
  end

  @doc """
  Turns a datetime object into a human readable data.
  Today if the date is not less than 24 hours ago.
  """
  def human_readable_date(snippet) do
    import DateTime

    case abs(diff(snippet.inserted_at, utc_now(), :second)) do
      x when x < 86400 ->
        "Today"

      _ ->
        d = snippet.inserted_at
        s = "#{d.day}/#{d.month} #{d.hour}:#{d.minute}"
        s
    end
  end
end
