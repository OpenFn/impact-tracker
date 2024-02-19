defmodule ImpactTrackerWeb.RemoteIPConfigurationTest do
  use ExUnit.Case, async: false

  alias ImpactTrackerWeb.RemoteIPConfiguration

  test "returns the configured collection of proxies" do
    put_temporary_env(
      :impact_tracker,
      :remote_ip_proxy_ips,
      "10.0.0.1,10.0.0.2,10.0.0.3"
    )

    assert(
      ["10.0.0.1", "10.0.0.2", "10.0.0.3"] = RemoteIPConfiguration.proxy_ips()
    )
  end

  test "removes any leading or trailing whitespace" do
    put_temporary_env(
      :impact_tracker,
      :remote_ip_proxy_ips,
      "  10.0.0.1 , 10.0.0.2  , 10.0.0.3  "
    )

    assert(
      ["10.0.0.1", "10.0.0.2", "10.0.0.3"] = RemoteIPConfiguration.proxy_ips()
    )
  end

  test "removes any empty proxy entries" do
    put_temporary_env(
      :impact_tracker,
      :remote_ip_proxy_ips,
      "10.0.0.1,,10.0.0.2,,10.0.0.3"
    )

    assert(
      ["10.0.0.1", "10.0.0.2", "10.0.0.3"] = RemoteIPConfiguration.proxy_ips()
    )
  end

  test "handles a single proxy correctly" do
    put_temporary_env(
      :impact_tracker,
      :remote_ip_proxy_ips,
      "10.0.0.1"
    )

    assert ["10.0.0.1"] = RemoteIPConfiguration.proxy_ips()
  end

  test "handles an empty proxy string as well" do
    put_temporary_env(
      :impact_tracker,
      :remote_ip_proxy_ips,
      ""
    )

    assert [] = RemoteIPConfiguration.proxy_ips()
  end

  def put_temporary_env(app, key, value) do
    previous_value = Application.get_env(app, key)
    Application.put_env(app, key, value)

    ExUnit.Callbacks.on_exit(fn ->
      Application.put_env(app, key, previous_value)
    end)
  end
end
