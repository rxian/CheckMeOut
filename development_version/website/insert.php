<?php
    
    // function OpenConnection(){
    //     $serverName = "tcp:yc4lfe5q04.database.windows.net,1433";
    //     $connectionOptions = array("Database"=>"checkmeout_db",
    //         "Uid"=>"checkmeout_admin@yc4lfe5q04", "pwd"=>"YHack2015");
    //     $conn = sqlsrv_connect($serverName, $connectionOptions);
    //     if($conn == false){
    //         echo "string";
    //         // die(FormatErrors(sqlsrv_errors()));
    //     }
    // }

    // function InsertData($lockid, $itemid){
    //     try
    //     {
    //         $conn = OpenConnection();
    //         $tsql = "INSERT checkmeout_db.Inventory (Lock_ID, Item_ID) VALUES ("$lockid", "$itemid");";);

    //         $insertReview = sqlsrv_query($conn, $tsql);
    //         if($insertReview == FALSE)
    //             die(FormatErrors( sqlsrv_errors()));
    //         echo "Product Key inserted is :";   

    //         sqlsrv_close($conn);
    //     }
    //     catch(Exception $e)
    //     {
    //         echo("Error!");
    //     }
    // }


    // $conn = OpenConnection();
    // InsertData($_POST['lockID'], $_POST['itemid']);
?>