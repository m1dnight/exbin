defmodule ExBin.Repo.Migrations.BinarySnippets do
  use Ecto.Migration

  def change do
    execute("ALTER TABLE snippets ALTER COLUMN content TYPE bytea USING content::bytea;")
  end
end
