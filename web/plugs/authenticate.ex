defmodule Wedding.Authenticate do
  @behaviour Plug
  import Plug.Conn
  alias Timex.Date
  alias Wedding.Repo

  def init(_opts) do
  end

  def call(conn, _opts) do
    get_req_header(conn, "authorization")
    |> check_token(conn)
  end
  defp check_token(["Bearer " <> token], conn) do
    Joken.decode(token)
    |> setup_session(conn)
  end
  defp check_token(_, conn), do: auth_error_resp(conn)

  def setup_session({:error, _}, conn), do: auth_error_resp(conn)
  def setup_session({:ok, %{user_id: user_id}}, conn) do
    case Repo.get(User, user_id) do
      nil -> auth_error_resp(conn)
      user -> assign(conn, :current_user, user)
    end
  end

  def channel_auth(token) do
    case Joken.decode(token) do
      {:error, _} -> :error
      {:ok, %{user_id: user_id}} ->
        case Repo.get(User, user_id) do
          nil -> :error
          user -> {:ok, user}
        end
    end
  end

  def generate_token_for(user) do
    {:ok, token} = Joken.encode(%{user_id: user.id, exp: token_expiry_secs()})
    token
  end

  defp token_expiry_secs do
    Date.now
    |> Date.shift(mins: 60*30*24)
    |> Date.to_secs
  end

  def auth_error_resp(conn) do
    errors = %{ errors: [%{
        status: 401,
        code: "Not Authenticated",
        title: "User token is invalid or has expired. Please request a new one.",
        links: %{
          session: Wedding.Router.Helpers.session_path(conn, :index)
    }}]}

    encoder = Application.get_env(:phoenix, :format_encoders) |> Keyword.get(:json, Poison)

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(401, encoder.encode!(errors))
    |> halt
  end
end
