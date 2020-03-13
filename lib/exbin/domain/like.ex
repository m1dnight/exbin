defmodule LikeInjection do
  import Enum

  # Characters that have special meaning inside the `LIKE` clause of a query.
  #
  # `%` is a wildcard representing multiple characters.
  # `_` is a wildcard representing one character.
  # Source: https://stackoverflow.com/questions/712580/list-of-special-characters-for-sql-like-clause
  @metachars [?%, ?_]

  # What to replace `LIKE` metacharacters with. We want to prepend a literal
  # backslash to each metacharacter. Because String#gsub does its own round of
  # interpolation on its second argument, we have to double escape backslashes
  # in this String.
  @escape ?\

  # Public: Escape characters that have special meaning within the `LIKE` clause
  # of a SQL query.
  #
  # value - The String value to be escaped.
  #
  # Returns a String.
  def like_sanitize(value) do
    value
    |> String.to_charlist()
    |> flat_map(fn char ->
      if member?(@metachars, char) do
        [@escape, char]
      else
        [char]
      end
    end)
    |> List.to_string()
  end
end
