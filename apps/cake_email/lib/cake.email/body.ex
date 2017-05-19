defmodule Cake.Email.Body do
    @moduledoc """
      The email's body representation.

      ##Fields

      ###:text
      The text version of the email's body.

      ###:html
      The HTML version of the email's body.

    """
    alias Cake.Email.Body

    @type t :: %Body{ text: String.t | nil, html: String.t | nil }

    defstruct [:text, :html]
end
