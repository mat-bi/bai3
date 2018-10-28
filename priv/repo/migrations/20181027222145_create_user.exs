defmodule Bai3.Repo.Migrations.CreateUser do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :username, :string
      add :password_number, :integer
      add :last_invalid_login, :utc_datetime
      add :max_invalid_logins, :integer
      add :blocking_enabled, :boolean, default: false
      add :number_of_invalid_logins, :integer, default: 0
      add :exists, :boolean, default: true
      add :blocked, :boolean, default: false
    end

    create index(:users, [:username], unique: true)
  end
end
