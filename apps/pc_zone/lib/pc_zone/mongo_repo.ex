defmodule PcZone.MongoRepo do
  use Mongo.Repo,
    otp_app: :pc_zone,
    topology: :mongo
end
