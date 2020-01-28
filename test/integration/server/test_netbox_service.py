

def test_netbox_service_is_running(host):
    service = host.service("netbox")
    assert service.is_running 
    assert service.is_enabled

def test_netbox_rq_service_is_running(host):
    service = host.service("netbox-rq")
    assert service.is_running 
    assert service.is_enabled

def test_webserver_is_running(host):
    assert (host.service("apache2").is_running or host.service("nginx").is_running)