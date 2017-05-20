use Mix.Config

config :cake_service, Cake.Service.Mailer.Dispatch,
    adapter: Swoosh.Adapters.Local
