defmodule ExbinWeb.SnippetView do
  use ExbinWeb, :view

  #############################################################################
  # Generate the raw strings to embed the statistics data in the html.

  def month_label(date) do
    Timex.format!(date, "%B ’%y", :strftime)
  end

  def month_labels(dataset) do
    dataset
    |> Enum.map(&elem(&1, 0))
    |> Enum.map(&month_label/1)
    |> Enum.map(fn m -> "\"#{m}\"" end)
    |> Enum.join(",")
    |> (fn s -> "[" <> s <> "]" end).()
  end

  def count_labels(dataset, priv) do
    dataset
    |> Enum.map(fn {_, {pub, prv}} -> if priv == :public, do: pub, else: prv end)
    |> Enum.join(",")
    |> (fn s -> "[" <> s <> "]" end).()
  end

  #############################################################################
  # Date formatting.

  def human_readable_date(snippet) do
    Timex.format!(snippet.inserted_at, "{D}/{0M}/{YYYY}")
  end

  def format_age(date) do
    days = Timex.diff(Timex.now(), date, :days)
    hours = Timex.diff(Timex.now(), date, :hours)
    minutes = Timex.diff(Timex.now(), date, :minutes)

    case {days, hours, minutes} do
      {0, 0, 0} ->
        "Just now"

      {0, 0, m} ->
        "#{m} minutes ago"

      {0, h, _} ->
        "#{h} hours ago"

      {d, _, _} ->
        cond do
          d < 7 ->
            "#{d} days ago"

          true ->
            Timex.format!(date, "{0D}/{0M}/{YY}")
        end
    end
  end

  #############################################################################
  # Summarize the snippet content (i.e., first lines).

  def summary(content) do
    content
    |> String.trim()
    |> (fn s -> Regex.replace(~r/[\n\r]/, s, " ") end).()
    |> (fn s -> Regex.replace(~r/(\s)+/, s, " ") end).()
    |> String.split(" ")
    |> Enum.take(50)
    |> Enum.join(" ")
  end

  #############################################################################
  # Sanitize snippet to make it reader friendly.

  def readerify(content) do
    content
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(fn line ->
      line
      |> String.trim()
      |> String.capitalize()
    end)
    |> Enum.join("\n")
    |> (fn s -> Regex.replace(~r/(\n)(\n)+/, s, "\n\n") end).()
    |> (fn s -> Regex.replace(~r/( )( )+/, s, " ") end).()
  end
end
