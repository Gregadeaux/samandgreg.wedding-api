defmodule Wedding.ValidateFilters do
  @behaviour Plug
  import Plug.Conn
  alias Plug.Conn

  def init([required_filters, optional_filters]) when is_list(required_filters) do
    [required_filters, optional_filters]
  end

  def call(conn, [required_filters, optional_filters]) do
    valid_filters = required_filters ++ optional_filters
    validate_required_filters(conn, required_filters)
    |> validate_filters(valid_filters)
  end

  def validate_filters(conn, valid_filters) do
    invalid_filters = Dict.get(conn.params, "filter", %{})
    |> Dict.keys
    |> Enum.reject(fn(x) -> Enum.member?(valid_filters, x) end)

    if Enum.empty?(invalid_filters) do
      conn
    else
      invalid_filters_error(conn, invalid_filters)
    end
  end

  def validate_required_filters(conn, required_filters) do
    filters = Dict.get(conn.params, "filter", %{})
    |> Dict.take(required_filters)
    |> Dict.keys

    if Enum.count(required_filters) == Enum.count(filters) do
      conn
    else
       required_filters_error(conn, required_filters)
    end
  end

  def invalid_filters_error(conn, invalid_filters) do
    invalid_filters_string = Enum.join(invalid_filters, ",")
    error_map = %{ errors: [%{
        status: 400,
        code: "Invalid Filter(s)",
        title: "[#{invalid_filters_string}] are invalid filters.",
      }]}

    conn |> error(error_map)
  end

  def required_filters_error(conn, required_filters) do
    required_filters_string = Enum.join(required_filters, ",")
    error_map = %{ errors: [%{
        status: 400,
        code: "Invalid Filter(s)",
        title: "[#{required_filters_string}] are required filters.",
      }]}

    conn |> error(error_map)
  end

  def error(conn = %Conn{state: :sent}, _) do
    conn
  end

  def error(conn, error_map) do
    encoder = Application.get_env(:phoenix, :format_encoders) |> Keyword.get(:json, Poison)

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(400, encoder.encode!(error_map))
    |> halt
  end
end
