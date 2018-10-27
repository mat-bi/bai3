defmodule Bai3Web.PageController do
  use Bai3Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end

  def login(conn, %{"username" => username, "password" => password}) do
    password = password 
          |> Enum.sort(fn {a,b}, {c, d} -> a < c end) 
          |> Enum.map(fn {_, value} -> value end)
          |> List.to_string()
    if Bai3.User.login(username, password) do
      conn
        |> put_session(:username, username)
        |> redirect(to: "/")
    else
      render conn, "login1.html", username: username, subsequence: Bai3.User.fetch_password(username).sequence, error: "Złe hasło"
    end
  end

  def login(conn, %{"username" => username}) do
    render conn, "login1.html", username: username, subsequence: Bai3.User.fetch_password(username).sequence, error: ""
  end

  def login(conn, _) do
    render conn, "login.html"
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
end
