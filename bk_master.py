#!/usr/bin/python

import socket
import sys, os, pwd, grp, signal, time, glob
#from resource_management import *
from subprocess import call
from xml.dom.minidom import parse
import xml.dom.minidom



# function

def getValueByTagName(node, tagName):
    tag =  node.getElementsByTagName(tagName)
    if (tag.length > 0 ):
        return tag[0].childNodes[0].data
    else:
        return "null"

## AMBARI
def AMBARI():
    host = getValueByTagName(service, 'host')
    hostname_socket = socket.gethostname()
    if hostname_socket == host :
        port = getValueByTagName(service, 'port')
        db = service.getElementsByTagName('db')
        for database in db:
#            db_type = database.getElementsByTagName('type')
            db_type = getValueByTagName(database, 'type')
            db_host = getValueByTagName(database, 'host')
            db_port = getValueByTagName(database, 'port')
            db_user = getValueByTagName(database, 'user')
            db_passwd = getValueByTagName(database, 'passwd')
            db_name = getValueByTagName(database, 'db_name')
            print "#############################"
            print "#     Variabili ambari      #"
            print "#############################"
            print "host: %s" % host
            print "port: %s" % port
            print "db_type: %s" % db_type
            print "db_host: %s" % db_host
            print "db_port: %s" % db_port
            print "db_user: %s" % db_user
            print "db_name: %s" % db_name

            comando="%s/bk_ambari.sh %s %s %s %s %s %s %s" %(script_dir, script_dir, gb_bk_dir, db_type, db_host, db_user, db_name)
            #%print comando
            os.system(comando)

## HDP-search
def HDP_search():
    hosts = service.getElementsByTagName('host')
    hostname_socket = socket.gethostname()
    for host in hosts:
        hostname_xml = host.childNodes[0].data
        if hostname_socket == hostname_xml :
            print "Host: %s" % host.childNodes[0].data
            ambari_host = host.childNodes[0].data 
            port = service.getElementsByTagName('port')
            collections = service.getElementsByTagName('collection')
            install_dir = service.getElementsByTagName('install_dir')
            tmp_local_path = service.getElementsByTagName('tmp_local_path')
            print "socket: %s" % hostname_socket
            print "port: %s" % port[0].childNodes[0].data
            print "collection: %s" % collections[0].childNodes[0].data
            print "collection: %s" % collections[1].childNodes[0].data
            print "install_dir: %s" % install_dir[0].childNodes[0].data
            print "tmp_local_path %s" % tmp_local_path[0].childNodes[0].data

## HDFS CHECKPOINT
def HDFS_checkpoint():
    hosts = service.getElementsByTagName('host')
    hostname_socket = socket.gethostname()
 #   for host in hosts:
  #      hostname_xml = host.childNodes[0].data
#        if hostname_socket == hostname_xml :
        



# ENV path
installation_dir = "/opt/draculabk"
script_dir = installation_dir + "/script"
conf_file = installation_dir + "/conf.xml"

#%print installation_dir, script_dir, conf_file

# Open XML document using minidom parser
DOMTree = xml.dom.minidom.parse(conf_file)
collection = DOMTree.documentElement
if collection.hasAttribute("version"):
    print "Config version: %s" % collection.getAttribute("version")

# Global configs
gb_config = collection.getElementsByTagName('global')
#gb_bk_dir = gb_config[0].getElementsByTagName('bk_dir')
gb_bk_dir = getValueByTagName(gb_config[0], 'bk_dir')

if not os.path.exists(gb_bk_dir):
    os.makedirs(gb_bk_dir)

#%print gb_bk_dir

# Run etc bk

comando = "sh %s/bk_local_file.sh %s" %(script_dir, gb_bk_dir)
#os.system(comando)
#%print comando
#%comando = "sh %s/pwd.sh %s %s " %(script_dir, script_dir, gb_bk_dir)
#%os.system(comando)
# Get all services 
services = collection.getElementsByTagName("services")

# lanch specify function for service 
for service in services:
    print "*****Service*****"
    serv_name =  service.getAttribute("name")
    print serv_name
    #% host = service.getElementsByTagName('host')
    #% print "host: %s" % host[0].childNodes[0].data
    #% print "host: %s" % getValueByTagName(service, 'host')
    if serv_name == "AMBARI":
        AMBARI()
    if serv_name == "HDP-search":
        HDP_search()
    if serv_name == "HDFS":
        HDFS_checkpoint

#   type = movie.getElementsByTagName('type')[0]
#   print "Type: %s" % type.childNodes[0].data
#   format = movie.getElementsByTagName('format')[0]
#   print "Format: %s" % format.childNodes[0].data
#   rating = movie.getElementsByTagName('rating')[0]

#   print "Rating: %s" % rating.childNodes[0].data
#   description = movie.getElementsByTagName('description')[0]
#   print "Description: %s" % description.childNodes[0].data

