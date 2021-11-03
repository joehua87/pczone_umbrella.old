defmodule Xeon.SkeletonMotherboard do
  use Ecto.Schema

  schema "skeleton_motherboard" do
    belongs_to :skeleton, Xeon.Skeleton
    belongs_to :motherboard, Xeon.Motherboard
  end
end
