#!/bin/bash
 
javac Mysecondjavaprogram.java

# Wait for any process to exit
wait -n

java Mysecondjavaprogram.java