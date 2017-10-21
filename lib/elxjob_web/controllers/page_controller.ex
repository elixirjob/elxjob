defmodule ElxjobWeb.PageController do
  use ElxjobWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
