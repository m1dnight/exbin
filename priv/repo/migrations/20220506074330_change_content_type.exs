defmodule Exbin.Repo.Migrations.ChangeContentType do
  use Ecto.Migration

  def up do
    execute """
    ALTER TABLE snippets
    ALTER COLUMN content TYPE bytea
    USING content::bytea;
    """
  end

  def down do
    execute """
    create or replace function convert_binary_to_text(bin in bytea) returns text
    as $$
    declare
    begin
    return convert_from(bin, 'utf-8');
    end;
    $$ language plpgsql;
    """

    execute """
    ALTER TABLE snippets
    ALTER COLUMN content TYPE text
    USING (convert_binary_to_text(content));;
    """
  end
end

# Raw SQL:
# select * from snippets;

# ALTER TABLE snippets
# ALTER COLUMN content TYPE bytea
# USING content::bytea;

# create or replace function convert_binary_to_text(bin in bytea) returns text
# as $$
# declare
# begin
#   return convert_from(bin, 'utf-8');
# end;
# $$ language plpgsql;

# ALTER TABLE snippets
# ALTER COLUMN content TYPE text
# USING (convert_binary_to_text(content));;

# select * from snippets;
