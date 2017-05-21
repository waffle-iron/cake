defmodule Cake.Service.Mailer.DispatchTest do
    use ExUnit.Case
    alias Cake.Service.Mailer.Dispatch
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
        assert { :ok, _ } = Dispatch.post(%TestTemplate{ destination: "foo@bar" })
    end
end
