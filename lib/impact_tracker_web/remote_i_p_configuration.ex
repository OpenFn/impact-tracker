defmodule ImpactTrackerWeb.RemoteIPConfiguration do
  @moduledoc """
  Provides dynamic configuration for the RemoteIP plug

  """
  def proxy_ips do
    Application.get_env(:impact_tracker, :remote_ip_proxy_ips)
    |> String.split(",")
    |> Enum.map(&String.trim/1)
    |> Enum.filter(&(String.length(&1) > 0))
  end
end
