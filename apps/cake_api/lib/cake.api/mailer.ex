defmodule Cake.API.Mailer do
    @moduledoc """
      Handles the dispatching of emails.
    """

    @service Cake.Service.Mailer

    alias Cake.Email

    @doc """
      Send an email.

      Returns `{ :ok, result }` on successful send, where result is the state returned
      by the internal mailing service. Otherwise returns `{ :error, result }`, where
      result is the state returned by the internal mailing service.
    """
    @spec post(Email.t | Email.template, keyword) :: { :ok, term } | { :error, term }
    def post(email, attributes \\ []) do
        GenServer.call(@service, { :post, { email, attributes } })
    end
end
