defmodule Exbin.Factory do
  alias Exbin.Repo

  def build(:snippet) do
    %Exbin.Snippet{name: "TestSnippet_#{random_string()}"}
  end



  def build(factory_name, attributes) do
    factory_name |> build() |> struct!(attributes)
  end

  def insert!(factory_name, attributes \\ []) do
    factory_name |> build(attributes) |> Repo.insert!()
  end


  # Generate a random string, of a random length (unless specified) that can be used to ensure uniqueness of fields
  defp random_string(length \\ Enum.random(12..64)) do
    :crypto.strong_rand_bytes(length) |> Base.url_encode64 |> binary_part(0, length)
  end

end
