defmodule Pczone.MongoRepo do
  use Mongo.Repo,
    otp_app: :pczone,
    topology: :mongo
end
