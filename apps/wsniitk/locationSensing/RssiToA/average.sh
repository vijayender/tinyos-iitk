#!/bin/bash

awk '
{ x[$9] +=  $3+$4 }
END{
  for ( a in x )
    print a
}

'