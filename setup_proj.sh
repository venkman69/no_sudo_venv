#!/bin/bash

SCRIPTDIR=`readlink -f $0`
SCRIPTPDIR=`dirname $SCRIPTDIR`
PROJDIR=`dirname $SCRIPTPDIR`
. $PROJDIR/setenv.sh
export PYTHONPATH=$PROJDIR/pip
PIPDL=$PROJDIR/proj_setup/pipdl

echo "Project dir: $PROJDIR"

cd $PROJDIR/proj_setup

echo "Check which pip is being used:"
which pip
read -p "Proceed with this pip? [Y/n]? " yesno
if [ "$yesno" = "n" -o "$yesno" = "N" ]
then
    echo "Quitting due to user abort"
    exit 1
fi

if [ $# -lt 1 ]
then
    echo "Missing argument"
    echo "Usage: setup_proj.sh <create|download|install|list>"
    echo "create   : captures current list of packages into requirements.txt"
    echo "download : Downloads current list of packages using requirements.txt"
    echo "install  : Installs current list of packages using requirements.txt to ./pip directory"
    echo "Note: proxy can be setup by adding it to exported environment variable BEFORE using this command"
    echo "Note: as: HTTP_PROXY=http://username:password@atlwg-lb.corp.etradegrp.com:9090"
    echo "Note: and: HTTPS_PROXY=http://username:password@atlwg-lb.corp.etradegrp.com:9090"
    exit 1
fi
if [ "$1" = "list" ]
then
    pip list
fi
if [ "$1" = "create" ]
then
    if [ -f "requirements.txt" ]
    then
        echo "backing up requirements.txt to requirements.txt."`date "+%Y%m%d"`
        mv requirements.txt requirements.txt.`date "+%Y%m%d"`
    fi
    pip freeze > requirements.txt

elif [ "$1" = "download" ]
then
    if [ ! -d $PROJDIR/proj_setup/pipdl ]
    then
        mkdir $PROJDIR/proj_setup/pipdl
        if [ $? -ne 0 ]
        then
            echo "could not make pipdl dir $PIPDL"
            exit 1
        fi
    fi
    pip install --download $PIPDL --trusted-host pypi.python.org  -r requirements.txt
elif [ "$1" = "install" ]
then
    pip install -r requirements.txt --no-index -t $PROJDIR/pip --find-links $PIPDL
fi
if [ ! $? -eq 0 ]
then
    echo "Non zero exit code from pip - something failed"
    exit 1
fi
