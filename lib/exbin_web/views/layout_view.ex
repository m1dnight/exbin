defmodule ExBinWeb.LayoutView do
  use ExBinWeb, :view

  def format_date(date) do
    Timex.format!(date, "{0D}/{0M}/{YY}")
  end

  @spec time_left(
          {{integer, pos_integer, pos_integer},
           {non_neg_integer, non_neg_integer, non_neg_integer}
           | {non_neg_integer, non_neg_integer, non_neg_integer, non_neg_integer | {non_neg_integer, non_neg_integer}}}
          | {integer, pos_integer, pos_integer}
          | %{
              :__struct__ => Date | DateTime | NaiveDateTime | Time,
              :calendar => atom,
              optional(:day) => pos_integer,
              optional(:hour) => non_neg_integer,
              optional(:microsecond) => {non_neg_integer, non_neg_integer},
              optional(:minute) => non_neg_integer,
              optional(:month) => pos_integer,
              optional(:second) => non_neg_integer,
              optional(:std_offset) => integer,
              optional(:time_zone) => binary,
              optional(:utc_offset) => integer,
              optional(:year) => integer,
              optional(:zone_abbr) => binary
            }
        ) :: <<_::48, _::_*8>>
  def time_left(date) do
    time_to_delete = Timex.shift(date, hours: 12)
    now = Timex.now()
    IO.inspect(time_to_delete, label: "Time to delete")
    IO.inspect(now, label: "Now")

    case Timex.diff(time_to_delete, now, :hours) do
      0 ->
        "#{Timex.diff(time_to_delete, now, :minutes)} minutes"

      h ->
        "#{h + 1} hours"
    end
  end
end
