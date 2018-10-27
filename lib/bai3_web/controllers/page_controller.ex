defmodule Bai3Web.PageController do
  use Bai3Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
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
