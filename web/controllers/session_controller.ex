defmodule Wedding.SessionController do
  use Wedding.Web, :controller
  alias Wedding.ErrorView

  plug Wedding.Authenticate when action in [:index, :delete]
  plug :action

  # GET /session
  def index(conn, _params) do
    user = conn.assigns[:current_user]
    render conn, "show.json", data: Wedding.Session.make_session(user)
  end

  # POST /session
  def create(conn, json=%{"format" => "json"}) do
    user_json = Dict.get(json, "data", %{})
    email = Dict.get(user_json, "email", nil)
    password = Dict.get(user_json, "password", nil)

    # Find User
    case User.fetch(email) do
      nil -> put_status(conn, 400) |> render ErrorView, "errors.json", message: "Invalid email or password"
      user ->
        case User.password_check(user, password) do
          true ->
            put_resp_header(conn, "Location", session_path(conn, :index))
                    |> put_status(201)
                    |> render "show.json", data: Wedding.Session.make_session(user)
          false -> put_status(conn, 400) |> render ErrorView, "errors.json", message: "Invalid email or password"
        end
    end
  end

  # DELETE /session
  def delete(conn, _params) do
    conn
    |> resp(204, "")
    |> send_resp
  end
end
