defmodule Exbin.Accounts.UserNotifier do
  # For simplicity, this module simply logs messages to the terminal.
  # You should replace it by a proper email or notification tool, such as:
  #
  #   * Swoosh - https://hexdocs.pm/swoosh
  #   * Bamboo - https://hexdocs.pm/bamboo
  #
  # defp deliver(to, body) do
  #   require Logger
  #   Logger.debug(body)
  #   {:ok, %{to: to, body: body}}
  # end
  require Logger
  import Swoosh.Email

  defp deliver(recipient, subject, body) do
    sender = Application.get_env(:exbin, Exbin.Mailer)[:from]

    email =
      new()
      |> to(recipient)
      |> from({"ExBin Mailer", sender})
      |> subject(subject)
      |> text_body(body)

    with {:ok, _metadata} <- Exbin.Mailer.deliver(email) do
      Logger.debug(email)
      {:ok, email}
    end
  end

  @doc """
  Deliver instructions to confirm account.
  """
  def deliver_confirmation_instructions(user, url) do
    deliver(user.email, "ExBin Account Confirmation", """

    ==============================

    Hi #{user.email},

    You can confirm your account by visiting the URL below:

    #{url}

    If you didn't create an account with us, please ignore this.

    ==============================
    """)
  end

  @doc """
  Deliver instructions to reset a user password.
  """
  def deliver_reset_password_instructions(user, url) do
    deliver(user.email, "Reset Password ExBin", """

    ==============================

    Hi #{user.email},

    You can reset your password by visiting the URL below:

    #{url}

    If you didn't request this change, please ignore this.

    ==============================
    """)
  end

  @doc """
  Deliver instructions to update a user email.
  """
  def deliver_update_email_instructions(user, url) do
    deliver(user.email, "Update Email Exbin", """

    ==============================

    Hi #{user.email},

    You can change your email by visiting the URL below:

    #{url}

    If you didn't request this change, please ignore this.

    ==============================
    """)
  end
end
