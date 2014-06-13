defmodule Mix.Tasks.Compile.WpaSupplicant do
  @shortdoc "Compiles the wpa_ex port binary"
  def run(_) do
    0=Mix.Shell.IO.cmd("make priv/wpa_ex")
  end
end

defmodule WpaSupplicant.Mixfile do
  use Mix.Project

  def project do
    [app: :wpa_supplicant,
     version: "0.0.1",
     elixir: "~> 0.14.0",
     compilers: [:WpaSupplicant, :elixir, :app],
     deps: deps,
     package: package,
     description: description
    ]
  end

  # Configuration for the OTP application
  def application do
    [applications: []]
  end

  defp description do
    """
    Elixir interface to the wpa_supplicant
    """
  end

  defp package do
    %{licenses: ["Apache-2.0", "BSD-3c"],
      links: %{"GitHub" => "https://github.com/fhunleth/wpa_supplicant.ex"}}
  end

  defp deps do
    []
  end
end
