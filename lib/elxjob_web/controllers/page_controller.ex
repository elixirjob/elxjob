defmodule ElxjobWeb.PageController do
  use ElxjobWeb, :controller

  def project(conn, _params) do
    render conn, "project.html"
  end

  def conditions(conn, _params) do
    render conn, "conditions.html"
  end
end
