defmodule Bai3.Repo.Migrations.CreatePasswords do
  use Ecto.Migration

  def change do
    create table(:passwords) do
      add :user_id, references(:users, on_delete: :delete_all)
      add :password, :string
      add :number, :integer
      add :sequence, {:array, :integer}
    end

    create index(:passwords, [:user_id, :number], unique: true)
  end
end
