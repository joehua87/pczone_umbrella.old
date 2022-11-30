defmodule PczoneWeb.Schema.Types.JSON do
  @moduledoc """
  The Json scalar type allows arbitrary JSON values to be passed in and out.
  Requires `{ :jason, "~> 1.1" }` package: https://github.com/michalmuskala/jason
  """
  use Absinthe.Schema.Notation

  scalar :json, open_ended: true do
    parse fn value -> {:ok, value} end
    serialize fn value -> value end
  end
end
