#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Created on Wed May 10 15:33:50 2017

@author: confocal
"""

# statistics_test.py
# testing manual calculation of statistics 
# for use in jython/Fiji scripts
# written for python 2.7

import numpy as np
import math
import random

def MeanOfList(a):
    '''
    calculates the average
    a: list of numbers
    returns a float
    '''
    result = 0.0 # have to use the decimal to make it a float
    total = 0.0
    for num in a:
        total += num
    result = total/(len(a))
    return round(result,6)

def StdDevOfList(a):
    '''
    calculates the standard deviation
    which is the square root of the variance
    The variance is the average of the squared deviations from the mean
    a: list of numbers
    returns a float
    Note that this gives the same result as Excel STDEV.P (not STDEV) -- assuming this is the whole population
    '''
    
    result = 0.0
    sampleMean = MeanOfList(a)
    sqDevs = 0.0
    
    for num in a:
        sqDevs += (math.fabs(num-sampleMean))**2 # fabs = absolute value
    
    result = math.sqrt(sqDevs/len(a))
        
    return round(result,6)



# ---- testing

# a = [1,0,1,1,1,1,2]

a = []
for i in range(10):
    a.append(random.random())

print(a)

stdDev = math.sqrt(np.var(a))

print("My values:",MeanOfList(a),StdDevOfList(a))
print("Survey says",round(np.mean(a),6),round(stdDev,6))
