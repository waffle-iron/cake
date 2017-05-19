defmodule Cake.Email.Template do
    alias Cake.Email
    alias Cake.Email.Template

    @type t :: %Template{ formatter: (t -> Email.t), data: any }

    defstruct [:formatter, :data]
end
