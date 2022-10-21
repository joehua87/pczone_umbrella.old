defmodule Pczone.UserTaxInfoTest do
  use Pczone.DataCase
  import Pczone.{Fixtures, UsersFixtures}
  alias Pczone.{Repo, Users}

  describe "user tax_info" do
    test "create" do
      user = user_fixture()
      tax_info_params = tax_info_fixture()

      assert {:ok,
              %Pczone.UserTaxInfo{
                tax_info: %Pczone.TaxInfo{
                  name: "CÔNG TY CP KẾT NỐI PHONG CÁCH SỐNG",
                  tax_id: "0313496812"
                }
              }} = Users.add_tax_info(user.id, tax_info_params)
    end

    test "update" do
      user = user_fixture()
      tax_info_params = tax_info_fixture()
      assert {:ok, %{id: tax_info_id}} = Users.add_tax_info(user.id, tax_info_params)

      assert {:ok, %Pczone.UserTaxInfo{tax_info: %Pczone.TaxInfo{id: _, name: "New name"}}} =
               Users.update_tax_info(user.id, tax_info_id, %{
                 tax_info_params
                 | name: "New name"
               })
    end

    test "delete" do
      user = user_fixture()
      tax_info_params = tax_info_fixture()

      assert {:ok, %{id: tax_info_id}} = Users.add_tax_info(user.id, tax_info_params)

      assert {:ok,
              %Pczone.UserTaxInfo{
                tax_info: %Pczone.TaxInfo{name: "CÔNG TY CP KẾT NỐI PHONG CÁCH SỐNG"}
              }} = Users.remove_tax_info(user.id, tax_info_id)

      assert %{user_tax_infos: []} =
               Repo.get(Pczone.Users.User, user.id) |> Repo.preload(:user_tax_infos)
    end
  end
end
