defmodule CuriousMessengerWeb.PageController do
  use CuriousMessengerWeb, :controller

  plug CuriousMessengerWeb.AssignUser, preload: :conversations

  def index(conn, _params) do
    conn
    |> put_flash(:info, "Welcome Back!")
    |> PhxIzitoast.info("", "Welcome Back", position: "topRight", timeout: 5000)
    |> IO.inspect()
    |> render("index.html")
  end
end
