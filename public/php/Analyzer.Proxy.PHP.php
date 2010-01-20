<?php
/*
** The function:
*/
 
function PostRequest($url, $referer, $_data) {
    
    // convert variables array to string:
    //$data = array();    
    //while(list($n,$v) = each($_data)){
        //$data[] = "$n=$v";
    //}    
    
    //$data = implode($_data);

    $params = $url;

    // format --> test1=a&test2=b etc.
  
    // parse the given URL
    $url = parse_url($url);
    if ($url['scheme'] != 'http') { 
        die('Only HTTP request are supported !');
    }
    
    // extract host and path:
    $host = $url['host'];
    //$path = $url['path'];
    
    // open a socket connection on port 80
    $fp = fsockopen($host, 80, $errno, $errstr, 30);
    if (!$fp) {
      //echo "$errstr ($errno)\r\n";
    } else {
    
      //echo $host . ' - ' . $path . ' - ' . $referer . ' - ' . $data . ' - ' . strlen($data) . '\r\n';

        
      // send the request headers:
      fputs($fp, "POST $params HTTP/1.1\n");
      fputs($fp, "Host: $host\r\n");
      fputs($fp, "Referer: $referer\r\n");
      fputs($fp, "Content-type: application/x-www-form-urlencoded\r\n");
      fputs($fp, "Connection: close\r\n");
      fputs($fp, "Content-length: ". strlen($_data) . "\r\n\r\n");
      fputs($fp, "$_data");
      
      $result = ''; 
      while(!feof($fp)) {
          // receive the results of the request
          $result .= fgets($fp, 128);
      }
      //echo $result;
      
      // close the socket connection:
      fclose($fp);
      // split the result header from the content
      $result = explode("\r\n\r\n", $result, 2);
   
      $header = isset($result[0]) ? $result[0] : '';
      $content = isset($result[1]) ? $result[1] : '';
  
      // return as array:
      return array($header, $content);
    }
}
 
 
 
/*
** MAIN
*/

$strQueryString = $_SERVER['QUERY_STRING'];
if (isset($_GET["ivivoposturl"])) {
   $varIvivoPostURL = $_GET["ivivoposturl"];
   # Remove "ivivoposturl"
   $strQueryString = substr($strQueryString, strlen($varIvivoPostURL) + 17);
   $varIvivoPostURL = urldecode($varIvivoPostURL);
} else {
   $varIvivoPostURL = "http://www.ivivo.tv/Tools/StateWMP.asp";
}

if (isset($_SERVER['REMOTE_ADDR'])) {
   $remote_addr = $_SERVER['REMOTE_ADDR'];
} else {
   $headers = apache_request_headers();
   $remote_addr = $headers['X-Forwarded-For'];
}
    $GetParams = $_GET;
    $encodedTime = $GetParams['eventTime'];
    $GetParams['eventTime'] = urlencode($encodedTime);
    $encodedUrl = $GetParams['url'];
    $GetParams['url'] = urlencode($encodedUrl);
    
    // convert variables array to string:
    $get_params = array();    
    while(list($n,$v) = each($GetParams)){
        $get_params[] = "$n=$v";
    }    
    $get_params = implode('&', $get_params);
    
$RedURL = $varIvivoPostURL . '?' . $get_params . '&IP=' . $remote_addr;

$postdata = file_get_contents('php://input');
// send a request to ivivo (referer = ...)
list($header, $content) = PostRequest(
    $RedURL,
    "http://www.ivivo.tv/",
    $postdata
);
 
// print the result of the whole request:
if ($content != '') {
      $content = explode("\r\n", $content, 3);
      $content = $content[1];
}
print trim($content);
#print_r $header; #--> prints the headers
?>
