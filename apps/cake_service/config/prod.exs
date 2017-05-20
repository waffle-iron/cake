use Mix.Config

config :cake_service, Cake.Service.Mailer.Dispatch,
    adapter: Swoosh.Adapters.Logger,
    log_full_email: true,
    level: :debug
