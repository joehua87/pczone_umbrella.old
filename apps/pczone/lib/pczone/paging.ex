defmodule Dew.Paging do
  defstruct page: 1,
            page_size: 24,
            total_entities: nil,
            total_pages: nil
end
