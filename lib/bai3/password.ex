defmodule Bai3.Password do
  use Ecto.Schema
  import Ecto.Query
  import Ecto.Changeset

  schema "passwords" do
    field :number, :integer
    field :password, :string
    field :sequence, {:array, :integer}

    belongs_to :user, Bai3.User
  end

  def changeset(password, params) do
    cast(password, params, [:number, :user_id, :password, :sequence])
  end
end