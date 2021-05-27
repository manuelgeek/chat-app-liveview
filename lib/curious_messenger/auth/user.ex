defmodule CuriousMessenger.Auth.User do
  use Ecto.Schema
  use Pow.Ecto.Schema

  import Ecto.Changeset

  alias CuriousMessenger.Chat.ConversationMember


  schema "auth_users" do
    field :nickname, :string
    pow_user_fields()

    timestamps()

    has_many :conversation_members, ConversationMember
    has_many :conversations, through: [:conversation_members, :conversation]
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> pow_changeset(attrs)
    |> cast(attrs, [:nickname])
    |> validate_required([:nickname])
    |> unique_constraint(:nickname)
  end
end
