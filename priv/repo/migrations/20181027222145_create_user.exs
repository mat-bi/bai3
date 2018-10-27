defmodule Bai3.Repo.Migrations.CreateUser do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :username, :string
      add :password_number, :integer
    end

    create index(:users, [:username], unique: true)
  end
end
