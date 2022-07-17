defmodule PczoneWeb.Schema.App do
  use Absinthe.Schema.Notation

  object :app_mutations do
    field :upsert_data, non_null(:boolean) do
      arg :google_drive_file_id, :string

      resolve(fn args, _info ->
        Map.get(args, :google_drive_file_id)
        |> Pczone.get_upsert_files_from_google_drive()
        |> Pczone.initial_data()
      end)
    end
  end
end
