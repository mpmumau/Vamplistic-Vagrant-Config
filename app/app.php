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

$VAMP_PKGS_DATA = pkgsData();
