defmodule Elxjob.Jobs.Job do
  use Ecto.Schema

  import Ecto.Changeset

  alias Elxjob.Jobs.Job

  use Timex.Ecto.Timestamps

  @requred_attrs [:title, :description, :occupation, :remote, :actual_till, :email]

  schema "jobs" do
    field :title, :string
    field :description, :string
    field :occupation, :integer
    field :location, :string
    field :remote, :boolean
    field :pay_from, :integer
    field :pay_till, :integer
    field :currency, :integer
    field :pay_period, :integer
    field :post_period, :string
    field :company, :string
    field :email, :string
    field :site, :string
    field :phone, :string
    field :contact, :string
    field :views, :integer
    field :actual_till, Timex.Ecto.Date
    field :owner_token, :string
    field :archive, :boolean
    field :moderation, :boolean
    field :hh_vacancy_id, :string
    field :hh_vacancy_url, :string

    timestamps()
  end

  @doc false
  def changeset(%Job{} = job, attrs) do
    job
    |> cast(attrs, [:title, :description, :occupation, :remote, :actual_till, :email, :location, :owner_token,
                    :moderation, :archive, :views, :pay_from, :pay_till, :currency, :pay_period, :company, :email,
                    :site, :phone, :contact, :hh_vacancy_id, :hh_vacancy_url])
    |> validate_required(pick_required_attrs(attrs))
    |> validate_format(:email, ~r/@/)
    |> unique_constraint(:hh_vacancy_id, message: "Hh vacany with such id already exist")
    |> required_error_messages("необходимо заполнить")
  end

  def required_error_messages(changeset, new_error_message) do
    update_in changeset.errors, &Enum.map(&1, fn
      {key, {"can't be blank", l}} -> {key, {new_error_message, l}}
      {_key, _error} = tuple  -> tuple
    end)
  end

  defp pick_required_attrs(attrs) do
    case Map.fetch(attrs, :hh_vacancy_url) do
      {:ok, url} ->
        if is_nil(url) do
          @requred_attrs
        else
          {_, attrs} = List.pop_at(@requred_attrs, -1)
          attrs
        end

      :error -> @requred_attrs
    end
  end
end
