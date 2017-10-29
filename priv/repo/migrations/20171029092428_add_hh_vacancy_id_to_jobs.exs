defmodule Elxjob.Repo.Migrations.AddHhVacancyIdToJobs do
  use Ecto.Migration

  def change do
    alter table(:jobs) do
      add :hh_vacancy_id, :string
    end

    create unique_index(:jobs, [:hh_vacancy_id])
  end
end
