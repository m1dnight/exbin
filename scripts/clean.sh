# !/bin/bash
root=$(pwd)

set -e

# Remove any existing database servers before git clean
cd "${root}/scripts/vagrant/"
vagrant destroy -f

# Git clean
cd "${root}"
git clean -dfx

# Vagrant
cd "${root}/scripts/vagrant/"
vagrant up

# Install dependencies
cd "${root}"
mix deps.get

# Install assets in website
cd "${root}/apps/website/assets/"
npm install

# Ecto.
echo "Setting up database.."
cd "${root}/apps/domain/"
mix ecto.drop
mix ecto.create
mix ecto.migrate
mix run priv/repo/seeds.exs


# Compile
cd $root
echo "Compiling.."
mix compile

# Run the tests
cd $root
echo "Testing.."
export MIX_ENV=test
mix ecto.drop
mix ecto.create
mix ecto.migrate
mix test
