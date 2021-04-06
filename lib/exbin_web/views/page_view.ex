defmodule ExBinWeb.PageView do
  use ExBinWeb, :view

  def readerify(content) do
    content
    |> String.split("\n")
    |> Enum.map(fn line ->
      "#{line}"
    end)
    |> Enum.join()
  end

  def month_label(date) do
    Timex.format!(date, "%B ’%y", :strftime)
  end

  def month_labels(dataset) do
    dataset
    |> Enum.map(&elem(&1, 0))
    |> Enum.map(&month_label/1)
    |> Enum.map(fn m -> "'#{m}'" end)
    |> Enum.join(",")
    |> (fn s -> "[" <> s <> "]" end).()
  end

  def count_labels(dataset) do
    dataset
    |> Enum.map(&elem(&1, 1))
    |> Enum.join(",")
    |> (fn s -> "[" <> s <> "]" end).()
  end

  def human_readable_date(snippet) do
    Timex.format!(snippet.inserted_at, "{D}/{0M}/{YYYY}")
  end
end
