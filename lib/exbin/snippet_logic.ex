defmodule ExBin.Logic.Snippet do
  use ExBinWeb, :controller
  alias ExBin.{Snippet, Repo}
  import Ecto.Query

  def list_snippets() do
    Repo.all(Snippet)
  end

  def public_snippets() do
    from(s in Snippet, where: s.private == false, order_by: [desc: s.inserted_at])
    |> Repo.all()
  end

  def count_public() do
    Repo.one(from(s in Snippet, where: s.private == false, select: count(s.id)))
  end

  def count_private() do
    Repo.one(from(s in Snippet, where: s.private == true, select: count(s.id)))
  end

  defp generate_name() do
    name = HorseStapleBattery.generate_compound([:verb, :noun])

    case Repo.one(from(s in Snippet, where: s.name == ^name)) do
      nil ->
        name

      _ ->
        generate_name()
    end
  end

  defp newest_snippet() do
    Repo.one(first(from(s in Snippet, where: s.private == false, order_by: [desc: s.inserted_at])))
  end

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
  Will indefinitely try to insert a snippet.
  """
  # %{"content" => "text", "private" => "false"}
  def insert(args) do
    IO.inspect(args)
    try_insert(args, 10)
  end

  defp try_insert(args, attempt) do
    name = generate_name()
    args = Map.merge(args, %{"name" => name})
    changeset = Snippet.changeset(%Snippet{}, args)

    case {Repo.insert(changeset), attempt} do
      {{:error, _e}, 0} ->
        {:error, "failed to insert snippet"}

      {{:error, _e}, _n} ->
        try_insert(args, attempt - 1)

      {{:ok, snippet}, _} ->
        {:ok, snippet}
    end
  end

  def update_viewcount(snippet, delta \\ 1) do
    Repo.transaction(fn ->
      s = Repo.get!(Snippet, snippet.id)
      s = Snippet.changeset(s, %{viewcount: s.viewcount + delta})
      Repo.update!(s)
    end)
  end

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
