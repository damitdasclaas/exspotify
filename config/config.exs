# config/config.exs
import Config

config :exspotify,
  client_id: System.get_env("SPOTIFY_CLIENT_ID"),
  client_secret: System.get_env("SPOTIFY_CLIENT_SECRET"),
  redirect_uri: System.get_env("SPOTIFY_REDIRECT_URI"),
  base_url: "https://api.spotify.com/v1"

# If you plan to use Finch, this configuration is also useful
# as shown in your project_exspotify.md
config :exspotify, Finch,
  name: Exspotify.Finch
