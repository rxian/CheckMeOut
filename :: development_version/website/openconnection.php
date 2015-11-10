<?php
    
    try{
        $serverName = "tcp:yc4lfe5q04.database.windows.net,1433";
        $connectionOptions = array("Database"=>"checkmeout_db",
            "Uid"=>"checkmeout_admin@yc4lfe5q04", "PWD"=>"YHack2015","Encrypt"="yes";);
        $conn = sqlsrv_connect($serverName, $connectionOptions);
        if($conn == false)
            die(FormatErrors(sqlsrv_errors()));
    }
    catch(Exception $e){
        echo("Error!");
    }


    $lockid = $_POST["lockNum"];
    $itemid = $_POST["itemNum"]


    if($lockid != "" && $itemid != ""){
        $sql = "INSERT into Inventory (Lock_ID, Item_ID) VALUES ("$lock_ID","$itemid ");";
    }

    
?>