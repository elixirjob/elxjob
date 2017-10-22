defmodule Elxjob.Jobs.Job do
  use Ecto.Schema
  import Ecto.Changeset

  alias Elxjob.Jobs.Job

  use Timex.Ecto.Timestamps

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

    timestamps()
  end

  @required_fields [:title, :description, :occupation, :remote, :actual_till, :email, :location]
  @optional_fields [:moderation, :owner_token, :archive, :views, :pay_from, :pay_till, :currency, :pay_period, :company, :email,
                    :site, :phone, :contact]


  @doc false
  def changeset(%Job{} = job, attrs) do
    job
    |> cast(attrs, @required_fields, @optional_fields)
    |> validate_required(@required_fields)
    |> validate_format(:email, ~r/@/)
    |> required_error_messages("необходимо заполнить")
  end

  def required_error_messages(changeset, new_error_message) do
    update_in changeset.errors, &Enum.map(&1, fn
      {key, {"can't be blank", l}} -> {key, {new_error_message, l}}
      {_key, _error} = tuple  -> tuple
    end)
  end
end
