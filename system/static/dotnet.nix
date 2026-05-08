{ config, pkgs, lib, ... }:

let
  odbcLibraryPath = lib.makeLibraryPath [
    pkgs.unixODBC
    pkgs.freetds
    pkgs.openssl
  ];
in
{
  environment.systemPackages = with pkgs; [
    dotnet-sdk_8
    unixODBC
    freetds
    openssl
  ];

  environment.variables = {
    LD_LIBRARY_PATH = odbcLibraryPath;
    ODBCSYSINI = "/etc";
    OPENSSL_CONF = "/etc/ssl/openssl-sqlserver2012.cnf";
  };

  environment.etc."odbcinst.ini".text = ''
    [FreeTDS]
    Description=FreeTDS ODBC driver for SQL Server
    Driver=${pkgs.freetds}/lib/libtdsodbc.so
    Setup=${pkgs.freetds}/lib/libtdsS.so
    UsageCount=1
  '';

  environment.etc."ssl/openssl-sqlserver2012.cnf".text = ''
    openssl_conf = openssl_init

    [openssl_init]
    ssl_conf = ssl_sect

    [ssl_sect]
    system_default = system_default_sect

    [system_default_sect]
    MinProtocol = TLSv1
    CipherString = DEFAULT@SECLEVEL=1
  '';
}