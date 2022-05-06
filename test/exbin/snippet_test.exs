defmodule Exbin.SnippetTest do
  use Exbin.DataCase, async: true
  alias Exbin.{Repo, Snippet}
  import Exbin.Factory

  test "errors if name is empty" do
    changeset = Snippet.changeset(build(:snippet, %{name: ""}))
    assert %{name: ["can't be blank"]} = errors_on(changeset)
  end

  test "errors if name is not unique" do
    insert!(:snippet, %{name: "DupeSnippet"})
    assert %Snippet{name: "DupeSnippet"} = Repo.one(Snippet)
    dupe_changeset = Snippet.changeset(%Snippet{}, %{name: "DupeSnippet", content: "not empty"})
    {:error, error_cs} = Repo.insert(dupe_changeset)
    assert %{name: ["has already been taken"]} = errors_on(error_cs)
  end

  test "defaults content to an empty string" do
    insert!(:snippet, %{name: "BasicSnippet"})
    assert %Snippet{name: "BasicSnippet", content: ""} = Repo.one(Snippet)
  end

  test "defaults viewcount to 0" do
    insert!(:snippet, %{name: "NeverViewed"})
    assert %Snippet{viewcount: 0, name: "NeverViewed"} = Repo.one(Snippet)
  end

  test "defaults private to true" do
    insert!(:snippet, %{name: "ItsPrivate"})
    assert %Snippet{private: true, name: "ItsPrivate"} = Repo.one(Snippet)
  end

  test "defaults ephemeral to false" do
    insert!(:snippet, %{name: "Ghostly"})
    assert %Snippet{ephemeral: false, name: "Ghostly"} = Repo.one(Snippet)
  end
end
