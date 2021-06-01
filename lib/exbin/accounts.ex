defmodule ExBin.Accounts do
  def authenticate_admin(given_password) do
    required = System.get_env("ADMIN_PASSWORD")
    if given_password == required do
      {:ok, %{username: "admin", id: 0}}
    else
      {:error, :unauthorized}
    end
  end
end
