defmodule PcZoneWeb.Schema.App do
  use Absinthe.Schema.Notation

  object :app_mutations do
    field :upsert_data, non_null(:boolean) do
      arg :google_drive_file_id, :string

      resolve(fn args, _info ->
        Map.get(args, :google_drive_file_id)
        |> PcZone.get_upsert_files_from_google_drive()
        |> PcZone.initial_data()

        {:ok, true}
      end)
    end
  end
end
