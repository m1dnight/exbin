defmodule Exbin.Stats do
  alias Exbin.{Snippet, Repo, Clock}
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

  Note that this returns the current month (a partial month) up until the
  current time, and the 11 months prior, so it's not quite a full year of data.
  Technically it's actually: 11 months + (between 1 day and 1 month)
  Any dates that are in the future are filtered out. (Although this should only
  happen in cases of database corruption, bad inserts, or changing the app TZ)

  Returns a map keyed with the beginning of the month, truncated to the second,
  as a NaiveDateTime, with a {public_count, private_count} tuple for each month.
  """
  def count_per_month() do
    buckets = empty_month_bucket_map()

    count_per_month_query()
    |> Repo.all()
    |> Enum.reduce(buckets, fn result, acc ->
      target_month_start = NaiveDateTime.truncate(result.month, :second)
      {publ, priv} = Map.get(acc, target_month_start)
      priv = if result.private, do: result.count, else: priv
      publ = if result.private, do: publ, else: result.count
      Map.put(acc, target_month_start, {publ, priv})
    end)
    # Turn the map into a list now that we no longer need to look up items
    |> Enum.into([])
    # And sort the list so the months are in order and the most recent one is last
    |> Enum.sort_by(&elem(&1, 0), &Timex.before?/2)
    # Prune the oldest element out of the list, as we only actually want 11 months.
    |> Enum.drop(1)
  end

  # We use this to solve https://github.com/elixir-ecto/ecto/issues/3159
  # (Ecto explodes because it doesn't understand that two fragments with the
  # same arguments are actually the same fragment, so it incorrectly demands
  # that you group_by a field which you're actually grouping by already.)
  #
  # NOTE: Elixir/Ecto is treating the timestamp columns as DateTimes with
  # zones, but in Postgres they're actually "datetime without zone"
  # (https://github.com/elixir-ecto/ecto/issues/1868#issuecomment-268169955)
  # Because of this when we do manipulations on the Postgres side we actually
  # need to first cast the timestamp into ETC/UTC and THEN move it to the
  # application TZ. (AT TIME ZONE stamps the TZ onto the timestamp *at the
  # same wall clock time*, rather than convert it to that TZ for "timestamp
  # without time zone" fields.
  defmacrop month_trunc_in_zone_frag(field, tz) do
    quote do
      fragment(
        "date_trunc('month', (? AT TIME ZONE 'Etc/UTC') AT TIME ZONE ?) as month_bucket",
        unquote(field),
        unquote(tz)
      )
    end
  end

  # Create a query to get the counts for each month in the last year, grouped by public/private
  # (So 2 results per month, assuming each month has both public and private snippets)
  defp count_per_month_query() do
    app_tz = Application.get_env(:exbin, :timezone)
    now = Clock.utc_now()

    from(s in Snippet)
    |> select(
      [s],
      %{
        month: month_trunc_in_zone_frag(s.inserted_at, ^app_tz),
        count: fragment("count(*)"),
        private: fragment("private")
      }
    )
    |> where(
      [s],
      fragment(
        "(? AT TIME ZONE 'Etc/UTC') AT TIME ZONE ? >= (? AT TIME ZONE ? - interval '1 year')",
        s.inserted_at,
        ^app_tz,
        ^now,
        ^app_tz
      )
    )
    |> where(
      [s],
      fragment("(? AT TIME ZONE 'Etc/UTC') AT TIME ZONE ? <= (? AT TIME ZONE ?)", s.inserted_at, ^app_tz, ^now, ^app_tz)
    )
    |> group_by([s], fragment("month_bucket"))
    |> group_by([s], s.private)
    |> order_by([s], fragment("month_bucket"))
  end

  # Generates a a bucket list for 12 months prior to the current time.
  # Resulting Map will be keyed with NaiveDateTimes truncated to the
  # second, indicating the beginning of the month, with a zeroed'
  # {public_count, private_count} tuple as the initial value.
  @spec empty_month_bucket_map() :: Map.t()
  defp empty_month_bucket_map() do
    application_tz = Application.get_env(:exbin, :timezone)

    current_month_start =
      Clock.utc_now()
      |> DateTime.shift_zone!(application_tz)
      |> Timex.beginning_of_month()
      |> NaiveDateTime.truncate(:second)

    0..12
    |> Enum.flat_map(fn offset ->
      month = Timex.shift(current_month_start, months: -1 * offset)
      [{month, {0, 0}}]
    end)
    |> Enum.into(%{})
  end
end
