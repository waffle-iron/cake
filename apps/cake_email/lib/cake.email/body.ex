defmodule Cake.Email.Body do
    alias Cake.Email.Body

    @type t :: %Body{ text: String.t | nil, html: String.t | nil }

    defstruct [:text, :html]
end
