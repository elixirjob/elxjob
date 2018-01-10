defmodule Elxjob.Repo.Migrations.AddHhVacancyUrlToJobs do
  use Ecto.Migration

  def change do
    alter table(:jobs) do
      add :hh_vacancy_url, :string
    end
  end
end
