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
    field :user_token, non_null(:string) do
      arg :email, non_null(:string)
      arg :password, non_null(:string)

      resolve(fn %{email: email, password: password}, _info ->
        if user = Users.get_user_by_email_and_password(email, password) do
          token = Users.generate_user_session_token(user) |> Base.encode64()
          {:ok, token}
        else
          {:error, "Invalid email or password"}
        end
      end)
    end

    field :user_by_email_and_password, :user do
      arg :email, non_null(:string)
      arg :password, non_null(:string)

      resolve(fn %{email: email, password: password}, _info ->
        {:ok, Users.get_user_by_email_and_password(email, password)}
      end)
    end

    field :user_by_token, :user do
      arg :token, non_null(:string)

      resolve(fn %{token: token}, _info ->
        token = Base.decode64!(token)
        {:ok, Users.get_user_by_session_token(token)}
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
