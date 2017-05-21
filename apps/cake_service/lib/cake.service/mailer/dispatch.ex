defmodule Cake.Service.Mailer.Dispatch do
    @moduledoc false
    use Swoosh.Mailer, otp_app: :cake_service

    alias Cake.Email

    @spec post(Email.t | Email.template, keyword) :: { :ok, term } | { :error, term }
    def post(email, params \\ []) do
        Email.compose(email, params)
        |> Keyword.new
        |> create_email
        |> deliver
    end

    defp create_email(attributes, email \\ %Swoosh.Email{})
    defp create_email([], email), do: email
    defp create_email([{ :from,        value }|attributes], email), do: create_email(attributes, Swoosh.Email.from(email, value))
    defp create_email([{ :to,          value }|attributes], email), do: create_email(attributes, Swoosh.Email.to(email, value))
    defp create_email([{ :reply_to,    value }|attributes], email), do: create_email(attributes, Swoosh.Email.reply_to(email, value))
    defp create_email([{ :cc,          value }|attributes], email), do: create_email(attributes, Swoosh.Email.cc(email, value))
    defp create_email([{ :bcc,         value }|attributes], email), do: create_email(attributes, Swoosh.Email.bcc(email, value))
    defp create_email([{ :subject,     value }|attributes], email), do: create_email(attributes, Swoosh.Email.subject(email, value))
    defp create_email([{ :attachments, value }|attributes], email) do
        create_attachment = fn
            %{ path: path, filename: filename, content_type: type } -> Swoosh.Attachment.new(path, filename: filename, content_type: type)
            %{ path: path, filename: filename } -> Swoosh.Attachment.new(path, filename: filename)
            %{ path: path, content_type: type } -> Swoosh.Attachment.new(path, content_type: type)
            path -> Swoosh.Attachment.new(path)
        end

        email = if is_list(value) do
            Enum.reduce(value, email, fn attachment, email ->
                Swoosh.Email.attachment(email, create_attachment.(attachment))
            end)
        else
            Swoosh.Email.attachment(email, create_attachment.(value))
        end

        create_email(attributes, email)
    end
    defp create_email([{ :headers,     value }|attributes], email) do
        create_email(attributes, Enum.reduce(value, email, fn { name, value }, email ->
            Swoosh.Email.header(email, name, value)
        end))
    end
    defp create_email([{ :body,        %Email.Body{ text: text, html: html } }|attributes], email) do
        email = if(text != nil, do: Swoosh.Email.text_body(email, text), else: email)
        email = if(html != nil, do: Swoosh.Email.html_body(email, html), else: email)

        create_email(attributes, email)
    end
end
