defmodule Bai3.User do
  use Ecto.Schema
  import Ecto.Query
  import Ecto.Changeset
  alias Bai3.Repo

  schema "users" do
    field :username, :string
    field :password_number, :integer

    has_many :passwords, Bai3.Password
  end

  def changeset(user, params) do
    user
      |> cast(params, [:username, :password_number])
  end

  def register(username, password) do
    user = changeset(%__MODULE__{}, %{username: username, password_number: Enum.random(0..9)})
    passwords = find_passwords(password)
    fun = fn ->
      %{id: user_id} = Repo.insert! user
      passwords = passwords |> Enum.with_index() |>
      Enum.map(fn { { sequence, password }, index } ->
        Bai3.Password.changeset(%Bai3.Password{}, %{number: index, sequence: sequence, password: password, user_id: user_id})
            |> Repo.insert!()
      end)
    end

    Repo.transaction(fun)
    :ok 
  end

  defp while_unique(subsequence, password, passwords) do
    if subsequence in passwords do
      while_unique(find_subsequence(password), password, passwords)
    else
      subsequence
    end
  end

  defp find_subsequence(password) do
    Enum.reduce(1..5, { [], 0..(String.length(password)-1) }, fn _, { pass, rest } ->
      chosen = Enum.random(rest)
      rest = Enum.filter(rest, &(&1 !== chosen))
      { [chosen | pass], rest }
    end) |> elem(0) |> Enum.sort()
  end

  defp find_passwords(password) do
    Enum.reduce(1..10, [], fn _, passwords ->
      pass =  password |> find_subsequence() |> while_unique(password, passwords)
      [pass | passwords]
    end)
    |> Enum.map(fn subsequence -> 
      { subsequence, Enum.reduce(subsequence, "", fn el, pass ->
        pass <> String.at(password, el)
      end) |> Bcrypt.hash_pwd_salt() }
    end)
  end
end