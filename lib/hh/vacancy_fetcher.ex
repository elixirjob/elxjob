defmodule Hh.VacancyFetcher do
  require Logger

  alias Elxjob.Jobs

  use Timex

  @base_url "https://api.hh.ru/vacancies/"

  def get_all_vacancies do
    get(@base_url)
  end

  def show_vacancy(vacancy_id) do
    url = @base_url <> vacancy_id

    get(url)
  end

  # @spec search_vacancies(String.t) :: Map.t | nil
  def search_vacancies(text) do
    url = @base_url <> "?text=#{text}&search_field=name"
    get(url)["items"]
  end

  def handle_vacancy_search(search) do
    search_vacancies(search)
    |> Stream.map(&show_vacancy(&1["id"]))
    |> Stream.map(&mapping_job/1)
    |> Stream.reject(&is_nil/1)
    |> Enum.each(&handle_job/1)
  end

  # @spec get(String.t) :: Map.t | :ok
  defp get(url) do
    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        body |> Poison.Parser.parse!
      {:ok, %HTTPoison.Response{status_code: 404}} ->
        Logger.error "Invalid url: #{url}"
      {:error, %HTTPoison.Error{reason: reason}} ->
        Logger.error "Error: #{reason}"
    end
  end

  defp mapping_job(job_params) do
    %{
        title:          job_params["name"],
        description:    job_params["description"],
        remote:         remote?(job_params["schedule"]["id"]) ,
        location:       job_params["address"]["city"],
        company:        job_params["employer"]["name"],
        email:          job_params["contacts"]["email"],
        pay_till:       job_params["salary"]["to"],
        pay_from:       job_params["salary"]["from"],
        currency:       map_currency(job_params["salary"]["currency"]),
        moderation:     true,
        actual_till:    ElxjobWeb.JobView.month(Timex.today),
        owner_token:    Elxjob.Crypto.make_token(25),
        hh_vacancy_id:  job_params["id"],
        hh_vacancy_url: job_params["alternate_url"],
        occupation:     employment_type(job_params["employment"]["id"]) #  %{"Другое" => 0, "Полная занятость" => 1, "Частичная занятость" => 2, "Временная работа" => 3, "Работа по контракту" => 4}
    }
  end

  defp create_job(params) do
    case Jobs.create_job(params) do
      {:ok, _} -> :ok
      {:error, changeset} -> nil
    end
  end

  defp handle_job(params) do
    case params["hh_vacancy_id"] do
      nil -> create_job(params)
      _ ->
        job = Jobs.find_by_hh_vacancy(params)
        if is_nil(job), do: create_job(params)
    end
  end

  defp remote?(schedule_id) do
    if schedule_id == "remote", do: true, else: false
  end

  defp employment_type(employment_id) do
    if employment_id == "full", do: 1, else: 0
  end

  defp map_currency(currency) do
    case currency do
      "RUR" -> 0
      "USD" -> 1
      nil -> nil
      _ -> nil
    end
  end
end
