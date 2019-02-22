#!/bin/bash

gpio mode 15 out
gpio mode 16 out

gpio mode 1 out
gpio mode 4 out
gpio mode 5 out
gpio mode 6 out
gpio mode 10 out
gpio mode 11 out
gpio mode 26 out
gpio mode 27 out


# 1er
gpio write 15 1
# 10 er
gpio write 16 1


# e
gpio write 1 $1
# d
gpio write 4 $1
# c
gpio write 5 $1
# DP 
gpio write 6 $1
# b
gpio write 10 $1 
# a
gpio write 11 $1
# f
gpio write 26 $1
# g
gpio write 27 $1
