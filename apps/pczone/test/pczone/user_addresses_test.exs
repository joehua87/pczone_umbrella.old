defmodule Pczone.UserAddressesTest do
  use Pczone.DataCase
  import Pczone.{Fixtures, UsersFixtures}
  alias Pczone.{Repo, Users}

  describe "user address" do
    test "create" do
      user = user_fixture()
      address_params = address_fixture()

      assert {:ok,
              %Pczone.UserAddress{
                address: %Pczone.Address{
                  first_name: "Dew",
                  last_name: "John",
                  full_name: "Dew John",
                  address1: "123 Some Street",
                  address2: nil
                }
              }} = Users.add_address(user.id, address_params)
    end

    test "update" do
      user = user_fixture()
      address_params = address_fixture()
      assert {:ok, %{id: address_id}} = Users.add_address(user.id, address_params)

      assert {:ok, %Pczone.UserAddress{address: %Pczone.Address{first_name: "New Dew"}}} =
               Users.update_address(user.id, address_id, %{address_params | first_name: "New Dew"})
    end

    test "delete" do
      user = user_fixture()
      address_params = address_fixture()

      assert {:ok, %{id: address_id}} = Users.add_address(user.id, address_params)

      assert {:ok, %Pczone.UserAddress{address: %Pczone.Address{first_name: "Dew"}}} =
               Users.remove_address(user.id, address_id)

      assert %{user_addresses: []} =
               Repo.get(Pczone.Users.User, user.id) |> Repo.preload(:user_addresses)
    end
  end
end
