<?php
$chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
for ( $i = 0; $i < 8; $i++ )
  echo $chars{ rand(0, strlen($chars)-1) };
