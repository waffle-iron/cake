[![Stories in Ready](https://badge.waffle.io/ZURASTA/cake.png?label=ready&title=Ready)](https://waffle.io/ZURASTA/cake?utm_source=badge)
# Cake (Email Delivery)

Provides support for composing emails from reusable templates and utilises the `Swoosh` library to provide support for delivering emails.


### Usage

The service component (`Cake.Service`) is an OTP application that should be started prior to making any requests to the service. This component should only be interacted with to configure/control the service explicitly.

An API (`Cake.API`) is provided to allow for convenient interaction with the service from external applications.

An email composition library (`Cake.Email`) is provided to simplify the creation of emails.


### Composing Emails

Emails can be created from a template or a pre-existing email representation. Email templates are reusable maps that can be used to generate an email representation.

```elixir
defmodule InvoiceTemplate do
    defstruct [
        formatter: &InvoiceTemplate.format/1,
        client: nil,
        amount: nil,
        date: nil
    ]

    def format(%{ client: { name, email }, amount: amount, date: date }) do
        %Cake.Email{
            from: "billings@foo.bar",
            to: email,
            subject: "Invoice for #{date}",
            body: %Cake.Email.Body{
                text: "Hi #{name}, your account was billed #{amount} for the period (#{date})."
            }
        }
    end
end

Cake.API.Mailer.post(%InvoiceTemplate{ client: { "Foo", "foo@bar" }, amount: "$100", date: "January" })
```

To see more on how composing works see `Cake.Email.compose/2`.


Todo
----

- [ ] Normalise success and failure results for the API (so it isn't dependent on swoosh adapter).
