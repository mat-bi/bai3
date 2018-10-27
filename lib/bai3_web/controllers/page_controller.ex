defmodule Bai3Web.PageController do
  use Bai3Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
