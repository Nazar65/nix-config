{ inputs, pkgs, config, ... }:
let
  composerPhar = builtins.fetchurl{
    url = "https://github.com/composer/composer/releases/download/2.2.22/composer.phar";
    sha256 = "1lmibmdlk2rsrf4zr7xk4yi5rhlmmi8f2g8h2izb8x4sik600dbx";
  };
in {
  packages = [
    pkgs.git
    pkgs.gnupatch
    pkgs.n98-magerun2
    pkgs.envsubst
  ];

  scripts.composer.exec = ''php ${composerPhar} $@'';

  dotenv.enable = true;

  env = {
    PROJECT_HOST = "burpee.local:8081";
    APP_ROOT = "/home/nazar/environments/web-development/source/burpee";
    DOLLAR="$";
    DEVENV_HTTP_PORT = "8081";
    DEVENV_MAIL_UI_PORT = "3031";
    DEVENV_MAIL_SMTP_PORT = "3032";

    NGINX_PKG_ROOT = pkgs.nginx;
    DEVENV_STATE_NGINX = "${config.env.DEVENV_STATE}/nginx";
    DEVENV_PHPFPM_SOCKET = "${config.env.DEVENV_STATE}/php-fpm.sock";

    DEVENV_DB_NAME = "burpee";
    DEVENV_DB_USER = "burpee";
    DEVENV_DB_PASS = "burpee";
  };

  languages.php = {
    enable = true;
    package = pkgs.php81.buildEnv {
      extensions = { all, enabled }: with all; enabled ++ [ redis xdebug xsl ];
      extraConfig = ''
        memory_limit = -1
        error_reporting=E_ALL
        xdebug.mode = coverage,debug
        sendmail_path = ${pkgs.mailpit}/bin/mailpit sendmail -S 127.0.0.1:${config.env.DEVENV_MAIL_SMTP_PORT}
        display_errors = On
        display_startup_errors = On
      '';
    };
    fpm.phpOptions =''
       memory_limit = -1
       error_reporting=E_ALL
       xdebug.mode = debug
       endmail_path = ${pkgs.mailpit}/bin/mailpit sendmail -S 127.0.0.1:${config.env.DEVENV_MAIL_SMTP_PORT}
       display_errors = On
       display_startup_errors = On
    '';
    fpm.pools.web = {
      listen = "${config.env.DEVENV_PHPFPM_SOCKET}";
      settings = {
        "clear_env" = "no";
        "pm" = "dynamic";
        "pm.max_children" = 20;
        "pm.start_servers" = 6;
        "pm.min_spare_servers" = 1;
        "pm.max_spare_servers" = 10;
      };
    };
  };

  languages.javascript = {
    enable = true;
    package = pkgs.nodejs-18_x;
  };

  services.opensearch.enable = true;
  services.mailhog.enable = true;
  services.redis = {
    enable = true;
    port = 6379;
  };

  services.nginx = {
    enable = true;
    configFile = "${config.env.DEVENV_STATE_NGINX}/nginx.conf";
  };

  enterShell = ''
    mkdir -p ${config.env.DEVENV_STATE}/nginx/tmp/
    envsubst < ${config.env.DEVENV_ROOT}/nginx/nginx-template.conf > ${config.env.DEVENV_STATE}/nginx/nginx.conf
    envsubst < ${config.env.DEVENV_ROOT}/nginx/magento2-template.conf > ${config.env.DEVENV_STATE}/nginx/magento2.conf
  '';

  services.rabbitmq = {
    enable = true;
    managementPlugin.enable = true;
  };

  services.mailpit = {
    enable = true;
    uiListenAddress   = "127.0.0.1:${config.env.DEVENV_MAIL_UI_PORT}";
    smtpListenAddress = "127.0.0.1:${config.env.DEVENV_MAIL_SMTP_PORT}";
  };


  services.mysql = {
    enable = true;
    package = pkgs.mariadb_106;
    settings = {
      mysqld = {
        innodb_buffer_pool_size = "2G";
        table_open_cache = "2048";
        sort_buffer_size = "8M";
        join_buffer_size = "8M";
        query_cache_size = "256M";
        query_cache_limit = "2M";
      };
    };
    initialDatabases = [{ name = "${config.env.DEVENV_DB_NAME}"; }];
    ensureUsers = [
      {
        name = "${config.env.DEVENV_DB_USER}";
        password = "${config.env.DEVENV_DB_PASS}";
        ensurePermissions = { "${config.env.DEVENV_DB_NAME}.*" = "ALL PRIVILEGES"; };
      }
    ];
  };
}
  
