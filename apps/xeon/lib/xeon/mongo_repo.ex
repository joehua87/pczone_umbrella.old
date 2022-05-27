defmodule Xeon.MongoRepo do
  use Mongo.Repo,
    otp_app: :xeon,
    topology: :mongo
end
