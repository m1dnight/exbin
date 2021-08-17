defmodule ExBin.Stats do
  alias ExBin.{Snippet, Repo}
  import Ecto.Query

  @doc """
  Computes the average length of a snippet.
  """
  def average_length() do
    query = from(s in Snippet, select: %{len: fragment("avg(length(?))", s.content)})

    case Repo.one(query) do
      %{len: nil} ->
        0.0

      %{len: d} ->
        Decimal.to_float(d)
    end
  end

  @doc """
  Count all the snippets.
  """
  def count_snippets() do
    Repo.one(from(s in Snippet, select: count(s.id)))
  end

  @doc """
  Counts the total of private and public snippets in the database.
  """
  def count_public_private() do
    q =
      from s in Snippet,
        select: %{private?: s.private, total: count()},
        group_by: s.private

    case Repo.all(q) do
      [] ->
        %{private: 0, public: 0}

      [%{private?: true, total: priv}] ->
        %{private: priv, public: 0}

      [%{private?: false, total: publ}] ->
        %{private: 0, public: publ}

      [%{private?: false, total: publ}, %{private?: true, total: priv}] ->
        %{private: priv, public: publ}
    end
  end

  @doc """
  Compute the average views per snippet.
  """
  def average_viewcount() do
    query = from(s in Snippet, select: avg(s.viewcount))

    case Repo.one(query) do
      nil ->
        0.0

      d ->
        Decimal.to_float(d)
    end
  end

  @doc """
  Returns the most popular public snippet by viewcount.
  Breaks a tie in viewcount by choosing the most recently created.
  Returns nil if no snippet is found.
  """
  def most_popular() do
    from(from(s in Snippet, where: s.private == false, order_by: [desc: :viewcount, desc: :inserted_at], limit: 1))
    |> Repo.one()
  end

  @doc """
  Groups snippets created per month and returns the totals per month for a year.
  """
  def count_per_month() do
    timezone = Application.get_env(:exbin, :timezone)
    # Query all the snippets by computing the month they were created.
    query =
      from(s in Snippet)
      |> select(
        [s],
        %{
          month: fragment("date_trunc('month', ? AT TIME ZONE 'UTC')", s.inserted_at),
          count: fragment("count(*)"),
          private: fragment("private")
        }
      )
      |> where([s], fragment("date_trunc('month', ? AT TIME ZONE 'UTC') >= date_trunc('year', NOW())", s.inserted_at))
      |> group_by([s], fragment("date_trunc('month', ? AT TIME ZONE 'UTC')", s.inserted_at))
      |> group_by([s], s.private)
      |> order_by([s], fragment("date_trunc('month', ? AT TIME ZONE 'UTC') ASC", s.inserted_at))

    # Generate the list of last 12 months.
    # {month, {public, private}}
    buckets =
      0..11
      |> Enum.flat_map(fn offset ->
        month = Timex.now(timezone) |> Timex.beginning_of_month() |> Timex.shift(months: -1 * offset)
        [{month, {0, 0}}, {month, {0, 0}}]
      end)
      |> Enum.into(%{})

    # Insert the counts from the database.
    snippet_counts =
      Repo.all(query)
      |> Enum.reduce(buckets, fn r, buckets ->
        # The snippet comes out in UTC, so its shifted to the local timezone before putting in the bucket.
        r = %{r | month: DateTime.shift_zone!(r.month, timezone)}
        {publ, priv} = Map.get(buckets, r.month)

        priv = if r.private, do: r.count, else: priv
        publ = if r.private, do: publ, else: r.count

        Map.put(buckets, r.month, {publ, priv})
      end)

    # Create an ordered list.
    buckets
    |> Map.merge(snippet_counts)
    |> Enum.into([])
    |> Enum.sort_by(&elem(&1, 0), &Timex.before?/2)
  end
end
