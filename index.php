<?php
/*
 * RPC split and compare
 * This takes an ethereum rpc request, which arrives as json in postdata
 * and sends the request on to two different RPC servers, 
 * then compares and prints the results.
 */

error_log("Starting");

// get the post data
$postdata = file_get_contents("php://input");


// set up the curl requests
$ch1 = curl_init();
$ch2 = curl_init();

// set the curl options
curl_setopt($ch1, CURLOPT_URL, "http://localhost:5005");
curl_setopt($ch1, CURLOPT_POST, 1);
curl_setopt($ch1, CURLOPT_HTTPHEADER, array('Content-type: application/json'));
curl_setopt($ch1, CURLOPT_POSTFIELDS, $postdata);
curl_setopt($ch1, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch1, CURLOPT_CONNECTTIMEOUT, 400); 
curl_setopt($ch1, CURLOPT_TIMEOUT, 10000);

curl_setopt($ch2, CURLOPT_URL, "http://localhost:5006");
curl_setopt($ch2, CURLOPT_POST, 1);
curl_setopt($ch2, CURLOPT_HTTPHEADER, array('Content-type: application/json'));
curl_setopt($ch2, CURLOPT_POSTFIELDS, $postdata);
curl_setopt($ch2, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch2, CURLOPT_CONNECTTIMEOUT, 400); 
curl_setopt($ch2, CURLOPT_TIMEOUT, 10000);

// create the multiple cURL handle
$mh = curl_multi_init();

// add the handles
curl_multi_add_handle($mh,$ch1);
curl_multi_add_handle($mh,$ch2);

// execute the multi handle
do {
    curl_multi_exec($mh, $running);
    curl_multi_select($mh);
} while ($running > 0);

// close the handles
curl_multi_remove_handle($mh, $ch1);
curl_multi_remove_handle($mh, $ch2);
curl_multi_close($mh);

// get the results
$result1 = curl_multi_getcontent($ch1);
$result2 = curl_multi_getcontent($ch2);

// decode the results
$json1 = json_decode($result1);
$json2 = json_decode($result2);

// compare the results
if ($json1 == $json2) {
    print(json_encode($json1));
    
} else {

    error_log($postdata);

    error_log("Result 1:\n");
    error_log($result1);
    error_log("\nResult 2:\n");
    error_log($result2);

    die('{"jsonrpc":"2.0","id":null,"error":{"code":-32600,"message":"Invalid request"}}');
    // echo "Results do not match\n";
}


