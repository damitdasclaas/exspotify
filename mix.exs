defmodule Exspotify.MixProject do
  use Mix.Project

  @version "0.1.4"
  @source_url "https://github.com/damitdasclaas/exspotify"

  def project do
    [
      app: :exspotify,
      version: @version,
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      docs: docs(),
      name: "Exspotify",
      source_url: @source_url
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Exspotify.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:jason, "~> 1.4"},
      {:req, "~> 0.5"},
      {:finch, "~> 0.19"},
      {:oauth2, "~> 2.0"},
      {:dotenv, "~> 3.0.0", only: [:dev, :test]},
      {:mox, "~> 1.0", only: :test},
      {:ex_doc, "~> 0.31", only: :dev, runtime: false}
    ]
  end

  defp description do
    """
    A comprehensive Elixir client for the Spotify Web API with complete coverage
    of endpoints, type-safe struct parsing, and automatic token management.
    """
  end

  defp package do
    [
      name: "exspotify",
      files: ~w(lib .formatter.exs mix.exs README* LICENSE*),
      licenses: ["MIT"],
      links: %{
        "GitHub" => @source_url,
        "Changelog" => "#{@source_url}/blob/main/CHANGELOG.md",
        "Sponsor" => "#{@source_url}/sponsors"
      },
      maintainers: ["damitdasclaas"],
      keywords: [
        "spotify",
        "api",
        "music",
        "audio",
        "streaming",
        "playlist",
        "http",
        "client",
        "elixir"
      ]
    ]
  end

  defp docs do
    [
      main: "Exspotify",
      source_ref: "v#{@version}",
      source_url: @source_url,
      formatters: ["html"],
      groups_for_modules: groups_for_modules(),
      extras: [
        "README.md": [title: "Overview"],
        "CHANGELOG.md": [title: "Changelog"]
      ]
    ]
  end

  defp groups_for_modules do
    [
      "Core": [
        Exspotify,
        Exspotify.Client,
        Exspotify.Error,
        Exspotify.Auth,
        Exspotify.TokenManager
      ],
      "API Modules": [
        Exspotify.Albums,
        Exspotify.Artists,
        Exspotify.Tracks,
        Exspotify.Playlists,
        Exspotify.Search,
        Exspotify.Player,
        Exspotify.Users
      ],
      "Content Modules": [
        Exspotify.Shows,
        Exspotify.Episodes,
        Exspotify.Audiobooks,
        Exspotify.Chapters,
        Exspotify.Categories,
        Exspotify.Markets
      ],
      "Data Structures": [
        Exspotify.Structs.Album,
        Exspotify.Structs.Artist,
        Exspotify.Structs.Track,
        Exspotify.Structs.Playlist,
        Exspotify.Structs.User,
        Exspotify.Structs.Paging
      ]
    ]
  end
end
