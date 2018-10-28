defmodule Bai3Web.PageController do
  use Bai3Web, :controller

  plug :check_logged when action in [:index]

  def index(conn, _params) do
    render conn, "index.html", username: get_session(conn, :username)
  end

  def login(conn, %{"username" => username, "password" => password}) do
    password = password 
          |> Enum.sort(fn {a,b}, {c, d} -> a < c end) 
          |> Enum.map(fn {_, value} -> value end)
          |> List.to_string()
    case Bai3.User.login(username, password) do
      { true, number_of_invalid_logins } ->
        conn
          |> put_session(:username, username)
          |> put_session(:number_of_invalid_logins, number_of_invalid_logins)
          |> redirect(to: "/")
      :blocked -> render conn, "login1.html", username: username, subsequence: Bai3.User.fetch_password(username).sequence, error: "Konto zablokowane"
      {:blocked, time} -> render conn, "login1.html", username: username, subsequence: Bai3.User.fetch_password(username).sequence, error: "Konto czasowo zablokowane. Pozostały czas #{time} sekund"
      false -> render conn, "login1.html", username: username, subsequence: Bai3.User.fetch_password(username).sequence, error: "Złe hasło"
      end
  end

  def login(conn, %{"username" => username}) do
    render conn, "login1.html", username: username, subsequence: Bai3.User.fetch_password(username).sequence, error: ""
  end

  def login(conn, _) do
    render conn, "login.html"
  end

  def logout(conn, _) do
    conn
      |> clear_session
      |> redirect(to: "/login")
  end

  def register(conn, %{"username" => username, "password" => password}) do
    if String.length(password) < 8 or String.length(password) > 16 do
      render conn, "register.html", error: "Zła długość hasła!"
    else
      Bai3.User.register(username, password)
      redirect conn, to: "/"
    end
  end

  def register(conn, _) do
    render conn, "register.html", error: ""
  end

  defp check_logged(conn, _) do
    if !is_nil(get_session(conn, :username)) do
      conn
    else
      conn
        |> redirect(to: "/login")
        |> halt()
    end
  end
end
