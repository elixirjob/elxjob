defmodule ElxjobWeb.LayoutView do
  use ElxjobWeb, :view

  def desc_content(desc, company) do
    if desc && company do
     company <> ", " <> desc
    else
      "Найти подходящую вам вакансию на Elixirjob.ru - сайте вакансий для Erlang и Elixir разработчиков"
    end
  end
end
