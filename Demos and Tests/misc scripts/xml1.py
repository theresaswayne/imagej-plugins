# -*- coding: utf-8 -*-
"""
Created on Fri Jan 20 12:28:03 2017

@author: confocal
"""

# tutorial from https://www.blog.pythonlibrary.org/2010/11/12/python-parsing-xml-with-minidom/

import xml.dom.minidom

import xml.etree.ElementTree as etree

# put pubmed results in proper xml format

# 1. add the xml and open tags at the beginning

#import codecs
#f = codecs.open('pubmed.xml', encoding='utf-8', mode='r+')
#
#old = f.read() # read everything in the file
#f.seek(0) # rewind
#f.write('<?xml version="1.0" encoding="UTF-8"?>' + '\n' + '<data>' + '\n' + old) # write the new line before
## f.write('doo\n'+old)
#f.close()
#
## append the final close tag
#with open('pubmed.xml', 'a') as f: # allows appending
#    f.write('</data>\n')


file = "pubmed2.xml"

# pubmed_dom = xml.dom.minidom.parse(file)

# each PubmedArticle has one AuthorList
# which in turn has one or more Author. 
# Each Author has a LastName, Forename, and Initials.
# The goal: for each iLab user
# find a matching author lastname and initials (possibly the first initial only)
# and look up the pmid from that paper
# finally collecting the PMIDs for all matches and turning them into an url

tree = etree.parse(file)
root = tree.getroot()
print(len(root))     

for child in root:
    print(child)
