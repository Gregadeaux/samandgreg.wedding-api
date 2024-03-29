defmodule Wedding.Mixfile do
  use Mix.Project

  def project do
    [app: :wedding,
     version: "0.0.1",
     elixir: "~> 1.0",
     elixirc_paths: ["lib","web"],
     compilers: [:phoenix] ++ Mix.compilers,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  def application do
    [mod: {Wedding, []},
      applications: [:phoenix, :cowboy, :logger, :ecto, :crypto, :bcrypt]]
  end

  def deps do
    [
      {:phoenix, "~> 0.13"},
      {:phoenix_ecto, "~> 0.5.0"},
      {:cowboy, "~> 1.0"},
      {:jsonapi, github: "jeregrine/jsonapi", branch: "master"},
      {:plug, "~> 0.12.1"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 1.0"},

      # for CORS support
      {:corsica, "~> 0.2"},

      # for created_at and updated_at
      {:timex, "~> 0.13.2"},

      # for JWT auth
      {:erlpass, github: "ferd/erlpass", tag: "1.0.1"},
      {:joken, "~> 0.11.0"}
    ]
  end
end
