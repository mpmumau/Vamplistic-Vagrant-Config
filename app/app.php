<?php

define('VAMP_DB_USER', (getenv('VAMP_DB_USER') ? getenv('VAMP_DB_USER') : NULL));
define('VAMP_DB_PASS', (getenv('VAMP_DB_PASS') ? getenv('VAMP_DB_PASS') : NULL));
define('VAMP_DB_NAME', (getenv('VAMP_DB_NAME') ? getenv('VAMP_DB_NAME') : NULL));

function pkgIsInstalled($pkgName)
{
    $pkgName = trim($pkgName);
    $cmd = 'dpkg -l | awk -v pkg_given="'.$pkgName.'" \'{ if ($2 == pkg_given) print $2; }\'';
    $name = shell_exec($cmd);

    if (!empty($name))
        return true;
    return false;
}

function pkgVersion($pkgName)
{
    $pkgName = trim($pkgName);
    $cmd = 'dpkg -l | awk -v pkg_given="' . $pkgName . '" \'{ if ($2 == pkg_given) print $3; }\'';
    $version = shell_exec($cmd);

    if (!empty($version)) 
        return $version;
    return NULL;
}

function pkgsData()
{
    $list = array();

    $pkgsFile = "../logs/installed_pkgs.log";
    $fh = fopen($pkgsFile, 'r');

    while (($pkgName = fgets($fh)) !== false)
    {
        $isInstalled = pkgIsInstalled($pkgName);
        $version = pkgVersion($pkgName);

        $list[$pkgName] = array(
            "installed" => $isInstalled,
            "version" => $version
        );
    }
    fclose($fh);

    return $list;
}

function osVersion() {
    // Get the OS version
    $cmd = "hostnamectl | sed -n 7p";
    $raw = shell_exec($cmd);
    $pos = strpos($raw, ":") + 1;
    $raw = substr($raw, $pos);

    return $raw;
}

function sysCPUCount() {
    return shell_exec("lscpu | sed -n 4p | awk '{print $2}'");
}

function sysCPUName() {
    return shell_exec("lscpu | sed -n 13p | awk -F':' '{print $2}' | sed 's/ //g'");
}

function sysRAM() {
    return shell_exec("free -m | sed -n 2p | awk '{print $2}'");
}

function sysInfo() {
    $data = array(
        "os_version" => osVersion(),
        "cpu_name" => sysCPUName(),
        "cpu_count" => sysCPUCount(),
        "memory" => sysRAM()
    );

    return $data;
}

$VAMP_PKGS_DATA = pkgsData();
$VAMP_SYS_INFO = sysInfo();
