defmodule Hh.VacancyFetcher do
  alias Elxjob.Jobs

  use Timex

  @base_url "https://api.hh.ru/vacancies/"

  def get_all_vacancies do
    get(@base_url)
  end

  # @spec search_vacancies(String.t) :: %{}
  def show_vacancy(vacancy_id) do
    url = @base_url <> vacancy_id

    get(url)
  end

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

  defp get(url) do
    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        body |> Poison.Parser.parse!
      {:ok, %HTTPoison.Response{status_code: 404}} ->
        IO.puts "Not found :("
      {:error, %HTTPoison.Error{reason: reason}} ->
        IO.inspect reason
    end
  end

  defp mapping_job(job_params) do
    params =
      case(job_params["contacts"]) do
        nil -> nil
        _ ->
          %{
            title:         job_params["name"],
            description:   job_params["description"],
            remote:        (if job_params["schedule"]["id"] == "remote", do: true, else: false) ,
            location:      job_params["address"]["city"],
            company:       job_params["employer"]["name"],
            email:         job_params["contacts"]["email"],
            moderation:    true,
            actual_till:   ElxjobWeb.JobView.month(Timex.today),
            owner_token:   Elxjob.Crypto.make_token(25),
            hh_vacancy_id: job_params["id"],
            occupation:    (if job_params["employment"]["id"] == "full", do: 1, else: 0) #  %{"Другое" => 0, "Полная занятость" => 1, "Частичная занятость" => 2, "Временная работа" => 3, "Работа по контракту" => 4}
          }
      end

    params
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
        job = Jobs.find_by_hh_vacancy(params["hh_vacancy_id"])
        if is_nil(job), do: create_job(params)
    end
  end
end
