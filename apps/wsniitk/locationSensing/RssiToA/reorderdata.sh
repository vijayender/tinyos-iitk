#!/bin/bash

awk '
BEGIN{
 N = 10;
 LEN = "1 1.5 2 2.5 3 3.5 4 4.5 5 5.5 6 6.5 7 7.5 8 8.5 9 9.5 10 10.5 11 11.5 12 12.5 13 13.5 14 14.5 15"
 split(LEN,len);
 for(i=0;i<100;i++){
  rssi[i] = 0;
  lqi[i] = 0;
  batt[i] = 0;
  tmsp[i] = 0;
 }
 sum=0;
 print "average\n";
 pos=1;
}
{
 if ($1 < N){
  tmsp[$1] = $2 - $3;
  rssi[$1] = $4;
  lqi[$1] = $5;
  batt[$1] = $6;
 } else {
  if (tmsp[$1-N] != 0){
   print $1-N" " (tmsp[$1-N] + $2 - $3)" " $4" " rssi[$1-N]" "$5" "lqi[$1-N]" "$6" "batt[$1-N]" "len[pos];
   if($1 != 2*N-1)
    sum+=(tmsp[$1-N] + $2 - $3);
  }
 }
 if ($1 == 2*N-1){
  print "average is "sum/N;
  for( i=0; i<N; i++){
    rssi[i] = 0;
    tmsp[i] = 0;
  }
  sum=0;
  pos++;
 }
}
'