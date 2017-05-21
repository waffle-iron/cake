defmodule Cake.API.MailerTest do
    use ExUnit.Case
    alias Cake.API.Mailer
    alias Cake.Email

    defmodule TestTemplate do
        defstruct [
            formatter: &TestTemplate.format/1,
            destination: nil
        ]

        def format(%{ destination: destination }) do
            %Email{
                to: destination,
                from: "foo@foo",
                subject: "A test message",
                body: %Email.Body{
                    text: "Hi"
                }
            }
        end
    end

    test "send email" do
        assert { :ok, _ } = Cake.Service.Mailer.Dispatch.post(%TestTemplate{ destination: "foo@bar" })
    end
end
