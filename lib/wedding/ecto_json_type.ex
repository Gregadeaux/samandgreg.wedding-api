defmodule Wedding.Types.JSON do
  @behaviour Ecto.Type

  def type, do: :json

  def cast(any), do: {:ok, any}
  def load(value), do: {:ok, value}
  def dump(value), do: {:ok, value}
end

defmodule Extensions.JSON do
  alias Postgrex.TypeInfo

  @behaviour Postgrex.Extension

  def init(_parameters, opts),
    do: opts

  def matching(_library),
    do: [type: "json", type: "jsonb"]

  def format(_library),
    do: :binary

  def encode(%TypeInfo{type: "json"}, map, _state, _library),
    do: Poison.encode!(map)
  def encode(%TypeInfo{type: "jsonb"}, map, _state, _library),
    do: <<1, Poison.encode!(map)::binary>>

  def decode(%TypeInfo{type: "json"}, json, _state, _library),
    do: Poison.decode!(json)
  def decode(%TypeInfo{type: "jsonb"}, <<1, json::binary>>, _state, _library),
    do: Poison.decode!(json)
end
