defmodule PhoenixElm.Seat do
  use PhoenixElm.Web, :model

  schema "seats" do
    field :seat_no, :integer
    field :occupied, :string, default: "Available"

    timestamps
  end

  @required_fields ~w(seat_no occupied)
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end
end

defimpl Poison.Encoder, for: PhoenixElm.Seat do
  def encode(model, opts) do
    %{id: model.id,
      seatNo: model.seat_no,
      status: model.occupied} |> Poison.Encoder.encode(opts)
  end
end
