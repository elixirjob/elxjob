defmodule Elxjob.Repo.Migrations.CreateJobs do
  use Ecto.Migration

  def change do
    create table(:jobs) do
      add :title, :string
      add :description, :text
      add :occupation, :integer
      add :location, :string
      add :remote, :boolean
      add :pay_from, :integer
      add :pay_till, :integer
      add :currency, :integer
      add :pay_period, :integer
      add :post_period, :string
      add :company, :string
      add :email, :string
      add :site, :string
      add :phone, :string
      add :contact, :string
      add :views, :integer
      add :actual_till, :date
      add :owner_token, :string
      add :archive, :boolean, default: false
      add :moderation, :boolean, default: false

      timestamps()
    end
  end
end
