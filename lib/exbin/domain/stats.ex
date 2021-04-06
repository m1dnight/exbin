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

    buckets
    |> Map.merge(snippet_counts)
    |> Enum.into([])
    |> Enum.sort_by(&elem(&1, 0), &Timex.before?/2)
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
end
