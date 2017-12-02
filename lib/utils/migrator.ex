defmodule Utils.Migrator do
  def migrate do
    {:ok, _} = Application.ensure_all_started(:elxjob)

    path = Application.app_dir(:elxjob, "priv/repo/migrations")

    Ecto.Migrator.run(Elxjob.Repo, path, :up, all: true)

    :init.stop()
  end
end
