defmodule Cake.Email do
    @moduledoc """
      Compose and represent emails.

      ##Fields

      ###:from
      The email address of the sender.

      ###:to
      The email address for the recipient(s).

      ###:reply_to
      The email address to direct replies to.

      ###:headers
      Any headers to include with the email.

      ###:cc
      The email address for any recipient(s) to CC to.

      ###:bcc
      The email address of any recipient(s) to BCC to.

      ###:subject
      The subject title of the email.

      ###:body
      The content of the email.

      ###:attachments
      The file attachments included in the email.
    """
    alias Cake.Email

    @type address :: { name :: String.t, email :: String.t } | email :: String.t
    @type attachment :: %{ path: String.t, filename: String.t, content_type: String.t } | file :: String.t
    @type t :: %Email{
        from: address | nil,
        to: [address] | address | nil,
        reply_to: address | nil,
        headers: map | nil,
        cc: [address] | address | nil,
        bcc: [address] | address | nil,
        subject: String.t,
        body: Email.Body.t,
        attachments: [attachment] | attachment | nil
    }
    @type template :: %{ :formatter => (template -> t), optional(any) => any }

    defstruct [
        :from,
        :to,
        :reply_to,
        :headers,
        :cc,
        :bcc,
        :subject,
        :body,
        :attachments
    ]

    @doc """
      Create an email from the given input.

      Emails can be composed from pre-existing emails and overriding certain fields. Or
      from constructing them from templates. A valid email template only needs to be a
      map consisting of a `:formatter` field with a function that accepts that map and
      returns an email.

      A common approach for templates is to use them for building commonly structured
      emails.

        iex> template = %Cake.Email.Template{
        ...>    formatter: fn %{ data: name } ->
        ...>        %Cake.Email{
        ...>            subject: "A message to \#{name}",
        ...>            body: %Cake.Email.Body{
        ...>                text: "Hello \#{name}!"
        ...>            }
        ...>        }
        ...>    end,
        ...>    data: "Blah"
        ...> }
        iex> Cake.Email.compose(template)
        %Cake.Email{attachments: nil, bcc: nil, body: %Cake.Email.Body{html: nil, text: "Hello Blah!"}, cc: nil, from: nil, headers: nil, reply_to: nil, subject: "A message to Blah", to: nil}
        iex> Cake.Email.compose(template, to: "foo@bar", subject: "Overridden")
        %Cake.Email{attachments: nil, bcc: nil, body: %Cake.Email.Body{html: nil, text: "Hello Blah!"}, cc: nil, from: nil, headers: nil, reply_to: nil, subject: "Overridden", to: "foo@bar"}
    """
    @spec compose(t | template, keyword) :: t
    def compose(email, params \\ [])
    def compose(email = %Email{}, params), do: Map.merge(email, Map.new(params))
    def compose(template = %{ formatter: formatter }, params), do: compose(formatter.(template), params)
end
