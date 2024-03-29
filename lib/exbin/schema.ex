defmodule Exbin.Schema do
  @moduledoc """
  A wrapper for Ecto.Schema that allows us to add some additional functionality.
  Current functionality includes autogenerating all timestamps using Exbin.Clock,
  which allows freezing time during testing.
  """
  defmacro __using__(_) do
    quote do
      use Ecto.Schema

      @timestamps_opts [
        autogenerate: {Exbin.Clock, :utc_now, []},
        type: :utc_datetime_usec
      ]
    end
  end
end
