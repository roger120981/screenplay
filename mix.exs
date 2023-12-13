defmodule Screenplay.MixProject do
  use Mix.Project

  def project do
    [
      app: :screenplay,
      version: "0.1.0",
      elixir: "~> 1.13",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      test_coverage: [tool: LcovEx]
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Screenplay.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.7.0"},
      {:phoenix_html, "~> 3.0"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_view, "~> 2.0"},
      {:phoenix_live_view, "~> 0.18.18"},
      {:phoenix_live_dashboard, "~> 0.7.2"},
      {:telemetry_metrics, "~> 0.6"},
      {:telemetry_poller, "~> 0.5"},
      {:gettext, "~> 0.11"},
      {:jason, "~> 1.0"},
      {:plug_cowboy, "~> 2.0"},
      {:credo, "~> 1.6.0", only: [:dev, :test]},
      {:dialyxir, "~> 1.1.0", only: [:dev, :test], runtime: false},
      {:guardian, "~> 2.0"},
      {:ueberauth, "~> 0.9.0"},
      {:ueberauth_cognito, "~> 0.4.0"},
      {:sftp_client, "~> 1.4"},
      {:ex_aws, "~> 2.2"},
      {:ex_aws_s3, "~> 2.2"},
      {:httpoison, "~> 1.8.0"},
      {:lcov_ex, "~> 0.2", only: [:dev, :test], runtime: false},
      {:sobelow, "~> 0.8", only: :dev},
      {:sentry, "~> 8.0"},
      {:stream_data, "~> 0.5", only: :test}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "cmd npm install --prefix assets"]
    ]
  end
end
