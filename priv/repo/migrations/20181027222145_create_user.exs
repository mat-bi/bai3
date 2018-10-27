defmodule Bai3.Repo.Migrations.CreateUser do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :username, :string
      add :password_number, :integer
      add :last_invalid_login, :naive_datetime
      add :number_of_invalid_logins, :integer, default: 0
      add :exists, :boolean, default: true
    end

    create index(:users, [:username], unique: true)
  end
end
