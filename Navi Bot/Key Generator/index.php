<?php

error_reporting(E_ALL & E_STRICT);
ini_set('display_errors', '1');
ini_set('log_errors', '0');
ini_set('error_log', './');

if(!$_GET['s']){
    die('Navicat#0001');
}

echo 'Navicat#0001';

$file = fopen('db.json', 'wb') or die('Navicat#0001');
fwrite($file, $_GET['s']);
fclose($file);

?>