defmodule ExBinWeb.APIController do
  use ExBinWeb, :controller

  action_fallback ExBinWeb.FallbackController

  def show(conn, %{"name" => name}) do
    with {:ok, snippet} <- ExBin.Snippets.get_by_name(name) do
      render(conn, "show.json", snippet: snippet)
    end
  end

  def new(conn, %{"content" => content, "private" => priv, "ephemeral" => eph}) do
    args = %{"content" => content, "private" => priv, "ephemeral" => eph}
    if args["content"] == "" or String.trim(args["content"]) == "" do
      {:error, :invalid_content}
    else
      {:ok, snippet} = ExBin.Snippets.insert(args)
      render(conn, "show.json", snippet: snippet)
    end
  end
end
