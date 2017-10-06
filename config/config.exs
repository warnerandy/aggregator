# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :agg_rager,
  ecto_repos: [AggRager.Repo]

# Configures the endpoint
config :agg_rager, AggRagerWeb.Endpoint,
  url: [host: "warnerinc.from-tx.com:10010"],
  secret_key_base: "76RmPFp4RXOojbLVT4CGBX5yCPsSZmhj00DIyRQNZTKLLUiOcGLavpPerX5T1k2r",
  render_errors: [view: AggRagerWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: AggRager.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"

# %% Coherence Configuration %%   Don't remove this line
config :coherence,
  user_schema: AggRager.Coherence.User,
  repo: AggRager.Repo,
  module: AggRager,
  web_module: AggRagerWeb,
  router: AggRagerWeb.Router,
  messages_backend: AggRagerWeb.Coherence.Messages,
  logged_out_url: "/",
  email_from_name: "Your Name",
  email_from_email: "yourname@example.com",
  opts: [:authenticatable, :recoverable, :lockable, :trackable, :unlockable_with_token, :invitable, :registerable]

config :coherence, AggRagerWeb.Coherence.Mailer,
  adapter: Swoosh.Adapters.Sendgrid,
  api_key: "your api key here"
# %% End Coherence Configuration %%

config :coherence_assent, :providers, [
  battle_net: [
    client_id: "67jxp4sh6arppt5u4cefbk2mhryavtgg",
    client_secret: "PUCba9AWnqPtce74vJTrSv6JS79e5W9t",
    custom_redirect_uri: "https://warnerinc.from-tx.com:10010/auth/battle_net/callback",
    strategy: CoherenceAssent.Strategy.BattleNet
  ]
]

config :oauth2, debug: true