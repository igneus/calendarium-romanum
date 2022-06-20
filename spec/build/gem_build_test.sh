#!/bin/bash

set -e # fail on first error

echo 'Running gem build test'

USE_RVM=1

# parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
	-R|--no-rvm)
	    USE_RVM=
	    shift
	    ;;
	-*|--*)
	    echo "Unknown option $1"
	    exit 1
	    ;;
	*)
	    echo "Unexpected argument $1"
	    exit 1
	    ;;
    esac
done

## build
gem build calendarium-romanum.gemspec

## install
GEMSET=gem_build_test_gemset

# determine gem file name
VERSION=`ruby -Ilib -rcalendarium-romanum/version -e 'puts CalendariumRomanum::VERSION'`
GEM=calendarium-romanum-$VERSION.gem

if [ -n "$USE_RVM" ]; then
    rvm gemset create $GEMSET
    rvm @$GEMSET do gem install --no-document $GEM

    ## test loading in a program
    rvm @$GEMSET do calendariumrom query
    echo $?

    ## clean
    rvm gemset delete --force $GEMSET
else
    echo 'Warning: installing test gem in default ruby environment' >&2

    gem install --no-document $GEM
    calendariumrom query
    echo $?
fi

echo 'Gem build test finished successfully'
