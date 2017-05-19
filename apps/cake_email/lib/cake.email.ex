defmodule Cake.Email do
    @moduledoc """
      Compose and represent emails.

      The `Cake.Email` struct is enumerable, where it will enumerate over fields
      that are non-nil.

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
        subject: String.t | nil,
        body: Email.Body.t | nil,
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

    defimpl Enumerable, for: Email do
        def count(email) do
            { :ok,
                Map.values(email)
                |> Enum.count(fn
                    Email -> false
                    nil -> false
                    _ -> true
                end)
            }
        end

        def member?(%Email{ from: from }, :from), do: { :ok, from != nil }
        def member?(%Email{ to: to }, :to), do: { :ok, to != nil }
        def member?(%Email{ reply_to: reply_to }, :reply_to), do: { :ok, reply_to != nil }
        def member?(%Email{ headers: headers }, :headers), do: { :ok, headers != nil }
        def member?(%Email{ cc: cc }, :cc), do: { :ok, cc != nil }
        def member?(%Email{ bcc: bcc }, :bcc), do: { :ok, bcc != nil }
        def member?(%Email{ subject: subject }, :subject), do: { :ok, subject != nil }
        def member?(%Email{ body: body }, :body), do: { :ok, body != nil }
        def member?(%Email{ attachments: attachments }, :attachments), do: { :ok, attachments != nil }
        def member?(_, _), do: { :ok, false }

        def reduce(_, { :halt, acc }, _), do: { :halted, acc }
        def reduce(email, { :suspend, acc }, fun), do: { :suspended, acc, &reduce(email, &1, fun) }
        def reduce(email = %Email{}, { :cont, acc }, fun), do: reduce({ :from, email }, { :cont, acc }, fun)
        def reduce({ :from,     email = %Email{ from: value } },        { :cont, acc }, fun) when is_nil(value), do: reduce({ :to, email },          { :cont, acc }, fun)
        def reduce({ :to,       email = %Email{ to: value } },          { :cont, acc }, fun) when is_nil(value), do: reduce({ :reply_to, email },    { :cont, acc }, fun)
        def reduce({ :reply_to, email = %Email{ reply_to: value } },    { :cont, acc }, fun) when is_nil(value), do: reduce({ :headers, email },     { :cont, acc }, fun)
        def reduce({ :headers,  email = %Email{ headers: value } },     { :cont, acc }, fun) when is_nil(value), do: reduce({ :cc, email },          { :cont, acc }, fun)
        def reduce({ :cc,       email = %Email{ cc: value } },          { :cont, acc }, fun) when is_nil(value), do: reduce({ :bcc, email },         { :cont, acc }, fun)
        def reduce({ :bcc,      email = %Email{ bcc: value } },         { :cont, acc }, fun) when is_nil(value), do: reduce({ :subject, email },     { :cont, acc }, fun)
        def reduce({ :subject,  email = %Email{ subject: value } },     { :cont, acc }, fun) when is_nil(value), do: reduce({ :body, email },        { :cont, acc }, fun)
        def reduce({ :body,     email = %Email{ body: value } },        { :cont, acc }, fun) when is_nil(value), do: reduce({ :attachments, email }, { :cont, acc }, fun)
        def reduce({ :attachments,      %Email{ attachments: value } }, { :cont, acc }, _)   when is_nil(value), do: { :done, acc }
        def reduce({ :from,     email = %Email{ from: value } },        { :cont, acc }, fun), do: reduce({ :to, email },          fun.({ :from, value }, acc),     fun)
        def reduce({ :to,       email = %Email{ to: value } },          { :cont, acc }, fun), do: reduce({ :reply_to, email },    fun.({ :to, value }, acc),       fun)
        def reduce({ :reply_to, email = %Email{ reply_to: value } },    { :cont, acc }, fun), do: reduce({ :headers, email },     fun.({ :reply_to, value }, acc), fun)
        def reduce({ :headers,  email = %Email{ headers: value } },     { :cont, acc }, fun), do: reduce({ :cc, email },          fun.({ :headers, value }, acc),  fun)
        def reduce({ :cc,       email = %Email{ cc: value } },          { :cont, acc }, fun), do: reduce({ :bcc, email },         fun.({ :cc, value }, acc),       fun)
        def reduce({ :bcc,      email = %Email{ bcc: value } },         { :cont, acc }, fun), do: reduce({ :subject, email },     fun.({ :bcc, value }, acc),      fun)
        def reduce({ :subject,  email = %Email{ subject: value } },     { :cont, acc }, fun), do: reduce({ :body, email },        fun.({ :subject, value }, acc),  fun)
        def reduce({ :body,     email = %Email{ body: value } },        { :cont, acc }, fun), do: reduce({ :attachments, email }, fun.({ :body, value }, acc),     fun)
        def reduce({ :attachments,      %Email{ attachments: value } }, { :cont, acc }, fun) do
            { _, acc } = fun.({ :attachments, value }, acc)
            { :done, acc }
        end
    end
end
