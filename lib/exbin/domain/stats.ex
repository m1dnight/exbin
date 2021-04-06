defmodule ExBin.Domain.Statistics do
  alias ExBin.{Snippet, Repo}
  import Ecto.Query

  @doc """
  Computes the average length of a snippet.
  """
  def average_length() do
    if count_snippets() > 0 do
      query =
        from s in Snippet,
          select: %{len: fragment("avg(length(?))", s.content)}


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
    # Compute the date a year ago. Only take stats for 1 year.
    today = DateTime.utc_now()
    yearago = %DateTime{today | year: today.year - 1}

    # Generate the last
    map =
      (Enum.to_list((yearago.month + 1)..12) ++ Enum.to_list(1..today.month))
      |> Enum.zip(List.duplicate(yearago.year, 12 - today.month) ++ List.duplicate(today.year, today.month))
      |> Enum.map(fn k -> {k, 0} end)
      |> Enum.into(%{})

    {months, counts} =
      Repo.all(Snippet)
      |> Stream.map(fn s ->
        s.inserted_at
      end)
      |> Stream.map(fn dt ->
        year = dt.year
        month = dt.month
        {month, year}
      end)
      |> Enum.to_list()
      |> Enum.reduce(map, fn e, acc ->
        if Map.has_key?(acc, e) do
          Map.update!(acc, e, &(&1 + 1))
        else
          acc
        end
      end)
      |> Enum.map(fn {{m, y}, c} ->
        dt = Timex.to_datetime({{y, m, 1}, {0, 0, 0}}, "Etc/UTC")
        {dt, {{m, y}, c}}
      end)
      |> Enum.map(fn x ->
        IO.inspect(x)
        x
      end)
      |> Enum.filter(fn x -> not Kernel.match?({{:error, _}, _}, x) end)
      |> Enum.sort_by(fn {dt, _} -> dt end, &Timex.before?/2)
      |> Enum.map(fn {_, v} -> v end)
      |> Enum.map(fn {{m, y}, c} -> {{Timex.month_name(m), y}, c} end)
      |> Enum.unzip()

    months_string =
      months
      |> Enum.map(fn {m, _} -> "'#{m}'" end)
      |> Enum.join(",")
      |> (fn s -> "[" <> s <> "]" end).()

    values_string =
      counts
      |> Enum.join(",")
      |> (fn s -> "[" <> s <> "]" end).()

    {months_string, values_string}
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
