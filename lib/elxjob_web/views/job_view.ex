defmodule ElxjobWeb.JobView do
  use ElxjobWeb, :view
  use Timex

  # TODO
  def format_date(date) do
    [h|_] = Ecto.DateTime.to_string(date) |> String.split(" ")
    h
  end

  def to_html(text) do
    raw Earmark.as_html!(text, %Earmark.Options{})
  end

  def connect_type(type) do
    case type do
      "office" -> "Офис"
      "onsite" -> "На проект"
      "remote" -> "Удаленно"
    end
  end

  def occupation(type \\ nil) do
    if type do
      case type do
        0 -> "Другое"
        1 -> "Полная занятость"
        2 -> "Частичная занятость"
        3 -> "Временная работа"
        4 -> "Работа по контракту"
      end
    else
      %{"Другое" => 0, "Полная занятость" => 1, "Частичная занятость" => 2, "Временная работа" => 3, "Работа по контракту" => 4}
    end
  end

  def currency(type \\ nil) do
    case type do
      nil -> %{"рублей" => 0, "долларов" => 1, "евро" => 2}
      0 -> "рублей"
      1 -> "долларов"
      2 -> "евро"
    end
  end

  def pay_period(type \\ nil) do
    if type do
      case type do
        0 -> "в год"
        1 -> "в месяц"
        2 -> "в час"
        3 -> "за проект"
      end
    else
      %{"в год" => 0, "в месяц" => 1, "в час" => 2, "за проект" =>3}
    end
  end

  def post_period(inserted_at \\ nil) do

    case inserted_at do
      nil ->
        start = Timex.today
        %{"Неделя" => week(start), "Две недели" => two_week(start), "Месяц" => month(start)}

      _-> inserted_at
    end
  end

  def week(start) do
    start |> Timex.shift(days: 7) |> Kernel.to_string
  end

  def two_week(start) do
    start |> Timex.shift(days: 14) |> Kernel.to_string
  end

  def month(start) do
    start |> Timex.shift(months: 1) |> Kernel.to_string
  end

  def job_query_params_path(conn, page) do
    case conn.params["type"] do
      "" ->
        job_path(conn, :index, page: page)
      nil ->
        job_path(conn, :index, page: page)
      _ ->
        job_path(conn, :index, page: page, type: conn.params["type"], q: conn.params["q"])
    end
  end
end
