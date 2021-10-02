defmodule Exbin.InitialUser do
  @app :exbin

  defp load_app do
    Application.load(@app)
    Application.ensure_all_started(@app, :permanent)
  end

  defp current_users() do
    Exbin.Stats.count_users()
  end

  # https://dev.to/diogoko/random-strings-in-elixir-e8i
  defp insert_first_user() do
    pass = for _ <- 1..20, into: "", do: <<Enum.random('0123456789abcdef')>>

    user_data = %{
      email: "admin@exbin.call-cc.be",
      password: pass,
      admin: true
    }

    IO.puts("Created a user with email #{user_data.email} and password #{user_data.password}")
    {:ok, user} = Exbin.Accounts.register_user(user_data)
    user
  end

  def initial_user() do
    load_app()

    case current_users() do
      0 ->
        insert_first_user()

      _ ->
        IO.puts("Did not create a user because there are already registered users in the database.")
        :ok
    end
  end
end

Exbin.InitialUser.initial_user()
