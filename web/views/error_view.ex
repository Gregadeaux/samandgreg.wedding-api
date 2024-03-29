defmodule Wedding.ErrorView do
  use Wedding.Web, :view
  def render("404.html", _assigns) do
    "Page not found - 404"
  end

  def render("500.html", _assigns) do
    "Server internal error - 500"
  end

  def render("500.json", _dc) do
    %{errors: [%{
          status: 500,
          title: "Server Error, contact support if it continues"
    }]}
  end

  def render("404.json", _dc) do
    %{errors: [%{
          status: 404,
          title: "Resource was not found"
    }]}
  end

  def render("403.json", _dc) do
    %{errors: [%{
          status: 403,
          title: "Request body was unusuable"
    }]}
  end

  def render("400.json", %{conn: conn}) do
    message = conn.assigns.reason.message
    %{errors: [%{
          status: 400,
          title: message,
    }]}
  end

  def render("400.json", _dc) do
    %{errors: [%{
          status: 400,
          title: "Malformed request"
    }]}
  end

  def render("401.json", _dc) do
    %{errors: [%{
          status: 401,
          title: "Not authenticated to interact with this resource"
    }]}
  end

  def render("errors.json", %{message: message}) do
    %{errors: [%{
          status: 400,
          code: "Invalid request",
          title: message
        }]}
  end

  # Render all other templates as 500
  def render(_, assigns) do
    render "500.html", assigns
  end
end

defimpl Plug.Exception, for: Poison.SyntaxError do
  def status(_exception), do: 400
end

defimpl Plug.Exception, for: Phoenix.MissingParamError do
  def status(_excepton), do: 403
end

defmodule JSONAPI.ResourceNotFound do
  defexception plug_status: 404, message: "resource not found"
end

defmodule CometApi.Route.NotAuthenticated do
  defexception plug_status: 401, message: "not authenticated to view"
end

defmodule CometApi.Route.Forbidden do
  defexception plug_status: 403, message: "not authenticated to view"
end

defmodule JSONAPI.Errors.BadRequest do
  defexception plug_status: 400, message: "invalid format for request (check query or body)"
end

defmodule JSONAPI.Errors.InvalidSort do
  defexception plug_status: 400, message: "invalid sort parameter(s)"
end
