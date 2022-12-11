# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Pczone.Repo.insert!(%Pczone.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

with {:ok, user} <-
       Pczone.Users.register_user(%{email: "admin@pczone.vn", password: "fdsajkl;", role: :admin}) do
  Pczone.Users.set_role(user, :admin)
end
