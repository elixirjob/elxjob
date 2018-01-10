defmodule ElxjobWeb.PageController do
  use ElxjobWeb, :controller

  def project(conn, _params) do
    render conn, "project.html"
  end

  def conditions(conn, _params) do
    render conn, "conditions.html"
  end

  def index(conn, _params) do
    render conn, "index.html", current_user: get_session(conn, :current_user)
  end
end
