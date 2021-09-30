defmodule ExbinWeb.LayoutView do
  use ExbinWeb, :view

  def format_date(date) do
    Timex.format!(date, "{0D}/{0M}/{YY}")
  end

  def time_left(date) do
    maximum_age = Application.get_env(:exbin, :ephemeral_age)
    time_to_delete = Timex.shift(date, minutes: maximum_age)
    now = Timex.now()
    IO.inspect(time_to_delete, label: "Time to delete")
    IO.inspect(now, label: "Now")

    case Timex.diff(time_to_delete, now, :hours) do
      0 ->
        diff_minutes = Timex.diff(time_to_delete, now, :minutes)
        # If the snippet should have been deleted already.
        if diff_minutes < 0 do
          "0 minutes"
        else
          "#{diff_minutes} min."
        end

      h ->
        "#{h + 1} hours"
    end
  end
end
