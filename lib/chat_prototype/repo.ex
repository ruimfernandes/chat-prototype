defmodule ChatPrototype.Repo do
  use Ecto.Repo,
    otp_app: :chat_prototype,
    adapter: Ecto.Adapters.Postgres
end
