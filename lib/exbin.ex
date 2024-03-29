defmodule Exbin do
  @moduledoc """
  Exbin keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """
  @version Mix.Project.config()[:version]

  def version() do
    @version
  end
end
