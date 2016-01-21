defmodule PhoenixElm.Repo.Migrations.ChangeStatusToString do
  use Ecto.Migration

  def change do
    alter table(:seats) do
      modify :occupied, :string
    end
  end
end
