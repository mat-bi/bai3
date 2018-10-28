defmodule Bai3.User do
  use Ecto.Schema
  import Ecto.Query
  import Ecto.Changeset
  alias Bai3.Repo

  schema "users" do
    field :username, :string
    field :password_number, :integer
    field :last_invalid_login, :utc_datetime
    field :number_of_invalid_logins, :integer
    field :max_invalid_logins, :integer
    field :blocking_enabled, :boolean
    field :blocked, :boolean
    field :exists, :boolean

    has_many :passwords, Bai3.Password
  end

  def changeset(user, params) do
    user
      |> cast(params, [:username, :password_number, :last_invalid_login, :number_of_invalid_logins, :exists, :max_invalid_logins, :blocking_enabled, :blocked])
  end

  def fetch_password(username) do
    create_nonexistent(username)
    user = Repo.get_by(__MODULE__, username: username)
    Bai3.Password
      |> Repo.get_by(number: user.password_number, user_id: user.id)
  end

  def change_password(username, last_password, password) do
    fun = fn ->
        p = fetch_password(username)
        user_id = p.user_id
        if Bcrypt.verify_pass(last_password, p.password) do
          Repo.delete_all(from password in Bai3.Password, where: password.user_id == ^user_id)
          find_passwords(password) |> Enum.with_index() |>
          Enum.each(fn { { sequence, password }, index } ->
            Bai3.Password.changeset(%Bai3.Password{}, %{number: index, sequence: sequence, password: password, user_id: user_id})
                |> Repo.insert!()
          end)
          :ok
        else
            :error
        end
    end
    case Repo.transaction(fun) do
        {_, value} -> value
    end
  end

  def login(username, password) do
    create_nonexistent(username)
    user = Repo.get_by(__MODULE__, username: username)
    time = DateTime.diff(DateTime.utc_now(), user.last_invalid_login || DateTime.utc_now()) >= user.number_of_invalid_logins*15
    %{password: hashed_password} = Repo.get_by(Bai3.Password, number: user.password_number, user_id: user.id)

    cond do
    Bcrypt.verify_pass(password, hashed_password) and user.exists and time and not user.blocked ->
      Repo.update!(Bai3.User.changeset(user, %{password_number: Enum.random(0..9), number_of_invalid_logins: 0}))
      { true, user.number_of_invalid_logins }
    user.blocked ->
      :blocked
    not time ->
      { :blocked, user.number_of_invalid_logins*15 - DateTime.diff(DateTime.utc_now(), user.last_invalid_login || DateTime.utc_now())   }
    true ->
      blocked = user.blocking_enabled and user.number_of_invalid_logins+1 >= user.max_invalid_logins
      Repo.update!(Bai3.User.changeset(user, %{blocked: blocked, number_of_invalid_logins: user.number_of_invalid_logins+1, last_invalid_login: DateTime.utc_now()}))
      if blocked do
        :blocked
      else
        false
      end
    end
  end

  def register(username, password) do
    user = changeset(%__MODULE__{}, %{username: username, password_number: Enum.random(0..9)})
    passwords = find_passwords(password)
    fun = fn ->
      Repo.delete_all(from user in __MODULE__, where: user.username == ^username and not user.exists)
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

  defp create_nonexistent(username) do
    %__MODULE__{
        username: username,
        password_number: 0,
        last_invalid_login: DateTime.utc_now(),
        number_of_invalid_logins: 0,
        exists: false,
        blocking_enabled: Enum.random([true, false]),
        max_invalid_logins: Enum.random(5..10),
    } |> Repo.insert!(on_conflict: :nothing)

    if Enum.empty?(Repo.get_by(__MODULE__, username: username) |> Repo.preload([:passwords]) |> Map.get(:passwords)) do
      %{id: user_id} = Repo.get_by(__MODULE__, username: username)
      { subsequence, password } =  Enum.random(find_passwords("password"))
      Bai3.Password.changeset(%Bai3.Password{}, %{number: 0, sequence: subsequence, password: password, user_id: user_id})
        |> Repo.insert!
    end
  end
end