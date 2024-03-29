defmodule Wedding.Session do
  defstruct user: nil, email: nil, id: nil

  def make_session(user) do
    %__MODULE__{
      user: user,
      email: user.email,
      id: user.id
    }
  end
end
