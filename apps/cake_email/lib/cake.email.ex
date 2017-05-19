defmodule Cake.Email do
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

    @spec compose(t | template) :: t
    def compose(email = %Email{}), do: email
    def compose(template = %{ formatter: formatter }) do
        formatter.(template)
    end
end
