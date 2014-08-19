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
     version: "0.1.0",
     elixir: "~> 0.15.0",
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
    Elixir interface to the wpa_supplicant daemon. The wpa_supplicant
    provides application support for scanning for access points, managing
    Wi-Fi connections, and handling all of the security and other parameters
    associated with Wi-Fi.
    """
  end

  defp package do
    %{files: ["lib", "src/*.[ch]", "src/wpa_ctrl/*.[ch]", "test", "mix.exs", "README.md", "LICENSE", "Makefile"],
      contributors: ["Frank Hunleth"],
      licenses: ["Apache-2.0", "BSD-3c"],
      links: %{"GitHub" => "https://github.com/fhunleth/wpa_supplicant.ex"}}
  end

  defp deps do
    []
  end
end
