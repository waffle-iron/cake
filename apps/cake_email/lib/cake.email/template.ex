defmodule Cake.Email.Template do
    @moduledoc """
      A simple generic email template to build emails from.

      ##Fields

      ###:formatter
      A function that will accept the template and return an email.

      ###:data
      Any additional data you want to access from the formatter function.

      ##Example

        Cake.Email.compose(%Cake.Email.Template{
            formatter: fn %{ data: name } ->
                %Cake.Email{
                    subject: "A message to \#{name}",
                    body: %Cake.Email.Body{
                        text: "Hello \#{name}!"
                    }
                }
            end,
            data: "Blah"
        })
        \#=> %Cake.Email{attachments: nil, bcc: nil, body: %Cake.Email.Body{html: nil, text: "Hello Blah!"}, cc: nil, from: nil, headers: nil, reply_to: nil, subject: "A message to Blah", to: nil}
    """
    alias Cake.Email
    alias Cake.Email.Template

    @type t :: %Template{ formatter: (t -> Email.t), data: any }

    defstruct [:formatter, :data]
end
