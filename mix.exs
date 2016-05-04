defmodule Mix.Tasks.Compile.WpaSupplicant do
  @shortdoc "Compiles the wpa_ex port binary"
  def run(_) do
    {result, _error_code} = System.cmd("make", ["priv/wpa_ex"], stderr_to_stdout: true)
    IO.binwrite result
    Mix.Project.build_structure
  end
end

defmodule WpaSupplicant.Mixfile do
  use Mix.Project

  def project do
    [app: :wpa_supplicant,
     version: "0.2.0",
     elixir: "~> 1.2",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     compilers: Mix.compilers ++ [:WpaSupplicant],
     deps: deps,
      docs: [extras: ["README.md"]],
     package: package,
     description: description
    ]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger]]
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
      maintainers: ["Frank Hunleth"],
      licenses: ["Apache-2.0", "BSD-3c"],
      links: %{"GitHub" => "https://github.com/fhunleth/wpa_supplicant.ex"}}
  end

  defp deps do
    [
      {:earmark, "~> 0.1", only: :dev},
      {:ex_doc, "~> 0.11", only: :dev},
      {:credo, "~> 0.3", only: [:dev, :test]}
    ]
  end
end
