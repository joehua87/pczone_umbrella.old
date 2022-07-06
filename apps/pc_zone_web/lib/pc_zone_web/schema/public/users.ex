defmodule PcZoneWeb.Schema.Users do
  use Absinthe.Schema.Notation
  alias PcZone.Users

  object :user do
    field :id, non_null(:id)
    field :email, non_null(:string)
  end

  input_object :register_user_input do
    field :email, non_null(:string)
    field :password, non_null(:string)
  end

  input_object :login_user_input do
    field :email, non_null(:string)
    field :password, non_null(:string)
  end

  object :user_queries do
    field :user_by_email_and_password, :user do
      arg :email, non_null(:string)
      arg :password, non_null(:string)

      resolve(fn %{email: email, password: password}, _info ->
        {:ok, Users.get_user_by_email_and_password(email, password)}
      end)
    end

    field :user_by_id, :user do
      arg :id, non_null(:id)

      resolve(fn %{id: id}, _info ->
        {:ok, Users.get_user!(id)}
      end)
    end
  end

  object :user_mutations do
    field :register_user, non_null(:user) do
      arg :data, non_null(:register_user_input)

      resolve(fn %{data: data}, _info ->
        case Users.register_user(data) do
          {:ok, user} ->
            # TODO: Deliver user confirmation instructions
            # {:ok, _} =
            #   Users.deliver_user_confirmation_instructions(
            #     user,
            #     &Routes.user_confirmation_url(conn, :edit, &1)
            #   )

            {:ok, user}

          {:error, %Ecto.Changeset{} = changeset} ->
            {:error, changeset}
        end
      end)
    end
  end
end
