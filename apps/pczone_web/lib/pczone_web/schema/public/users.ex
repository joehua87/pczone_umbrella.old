defmodule PczoneWeb.Schema.Users do
  use Absinthe.Schema.Notation
  alias Absinthe.Resolution.Helpers
  alias Pczone.Users

  enum :role do
    value :user
    value :admin
  end

  object :user_address do
    field :id, non_null(:id)
    field :address, non_null(:address)
  end

  object :user_tax_info do
    field :id, non_null(:id)
    field :tax_info, non_null(:tax_info)
  end

  object :user do
    field :id, non_null(:id)
    field :username, non_null(:string)
    field :name, non_null(:string)
    field :email, non_null(:string)
    field :phone, :string
    field :avatar, :embedded_medium
    field :bio, :string
    field :role, non_null(:role)
    field :confirmed_at, :datetime

    field :user_addresses, non_null(list_of(non_null(:user_address))),
      resolve: Helpers.dataloader(PczoneWeb.Dataloader)

    field :user_tax_infos, non_null(list_of(non_null(:user_tax_info))),
      resolve: Helpers.dataloader(PczoneWeb.Dataloader)
  end

  input_object :register_user_input do
    field :username, non_null(:string)
    field :email, non_null(:string)
    field :name, non_null(:string)
    field :phone, :string
    field :password, non_null(:string)
  end

  input_object :login_user_input do
    field :email, non_null(:string)
    field :password, non_null(:string)
  end

  input_object :add_user_address_input do
    field :user_id, non_null(:id)
    field :address, non_null(:address_input)
  end

  input_object :update_user_address_input do
    field :user_id, non_null(:id)
    field :address_id, non_null(:id)
    field :address, non_null(:address_input)
  end

  input_object :remove_user_address_input do
    field :user_id, non_null(:id)
    field :address_id, non_null(:id)
  end

  input_object :add_user_tax_info_input do
    field :user_id, non_null(:id)
    field :tax_info, non_null(:tax_info_input)
  end

  input_object :update_user_tax_info_input do
    field :user_id, non_null(:id)
    field :tax_info_id, non_null(:id)
    field :tax_info, non_null(:tax_info_input)
  end

  input_object :remove_user_tax_info_input do
    field :user_id, non_null(:id)
    field :tax_info_id, non_null(:id)
  end

  object :user_queries do
    field :current_user, :user do
      resolve(fn _, %{context: %{user: user}} ->
        {:ok, user}
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
    field :login_user, non_null(:string) do
      arg :data, non_null(:login_user_input)

      resolve(fn %{data: %{email: email, password: password}}, _info ->
        if user = Users.get_user_by_email_and_password(email, password) do
          token = Users.generate_user_session_token(user) |> Base.encode64()
          {:ok, token}
        else
          {:error, "Invalid email or password"}
        end
      end)
    end

    field :logout_user, non_null(:string) do
      arg :token, non_null(:string)

      resolve(fn %{token: token}, _info ->
        Users.delete_session_token(token)
        {:ok, token}
      end)
    end

    field :register_user, non_null(:string) do
      arg :data, non_null(:register_user_input)

      resolve(fn %{data: data}, _info ->
        case Users.register_user(data) do
          {:ok, user} ->
            token = Users.generate_user_session_token(user) |> Base.encode64()
            {:ok, token}

          {:error, %Ecto.Changeset{} = changeset} ->
            {:error, changeset}
        end
      end)
    end

    field :add_user_address, non_null(:user_address) do
      arg :data, non_null(:add_user_address_input)

      resolve(fn %{data: %{user_id: user_id, address: address}}, _info ->
        Users.add_address(user_id, address)
      end)
    end

    field :update_user_address, non_null(:user_address) do
      arg :data, non_null(:update_user_address_input)

      resolve(fn %{data: %{user_id: user_id, address_id: address_id, address: address}}, _info ->
        Users.update_address(user_id, address_id, address)
      end)
    end

    field :remove_user_address, non_null(:user_address) do
      arg :data, non_null(:remove_user_address_input)

      resolve(fn %{data: %{user_id: user_id, address_id: address_id}}, _info ->
        Users.remove_address(user_id, address_id)
      end)
    end

    field :add_user_tax_info, non_null(:user_tax_info) do
      arg :data, non_null(:add_user_tax_info_input)

      resolve(fn %{data: %{user_id: user_id, tax_info: tax_info}}, _info ->
        Users.add_tax_info(user_id, tax_info)
      end)
    end

    field :update_user_tax_info, non_null(:user_tax_info) do
      arg :data, non_null(:update_user_tax_info_input)

      resolve(fn %{data: %{user_id: user_id, tax_info_id: tax_info_id, tax_info: tax_info}},
                 _info ->
        Users.update_tax_info(user_id, tax_info_id, tax_info)
      end)
    end

    field :remove_user_tax_info, non_null(:user_tax_info) do
      arg :data, non_null(:remove_user_tax_info_input)

      resolve(fn %{data: %{user_id: user_id, tax_info_id: tax_info_id}}, _info ->
        Users.remove_tax_info(user_id, tax_info_id)
      end)
    end
  end
end
