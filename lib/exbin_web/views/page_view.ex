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
end
