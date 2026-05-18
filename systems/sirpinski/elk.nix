_: {
  virtualisation.quadlet.networks.elk = {};

  virtualisation.quadlet.containers.elk = {
    containerConfig = {
      name = "elk";
      image = "ghcr.io/acuteaura/elk:nvs@sha256:abe43dd6b421f6cd4aa41640d94d0c256f1cfc64d15bc07daf2025a2580e63a1";
      volumes = [
        "/var/lib/elk/data:/elk/data:U"
      ];
      environments = {
        "NUXT_PUBLIC_DEFAULT_SERVER" = "gts.foxsnuggl.es";
        "NUXT_PUBLIC_SINGLE_INSTANCE" = "true";
      };
      networks = ["elk.network"];
      publishPorts = ["127.0.0.1:8085:5314"];
    };
    unitConfig = {
      After = ["network.target"];
      Wants = ["network.target"];
    };
  };

  services.nginx.virtualHosts."elk.foxsnuggl.es" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:8085";
      proxyWebsockets = true;
      recommendedProxySettings = true;
    };
  };
}
