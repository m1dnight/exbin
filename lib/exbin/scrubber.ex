defmodule Exbin.Scrubber do
  require Logger

  def child_spec(_arg) do
    Periodic.child_spec(
      id: __MODULE__,
      run: &run/0,
      every: :timer.minutes(10),
      initial_delay: :timer.minutes(5)
    )
  end

  defp run() do
    maximum_age = Application.get_env(:exbin, :ephemeral_age)
    Logger.warn("Running scrubber for all snippets older than #{maximum_age} minutes.")
    Exbin.Snippets.scrub(maximum_age)
  end
end
