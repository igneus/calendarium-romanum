#!/bin/bash

set -e # fail on first error

echo 'Running gem build test'

## build
gem build calendarium-romanum.gemspec

## install
GEMSET=gem_build_test_gemset

# determine gem file name
VERSION=`ruby -Ilib -rcalendarium-romanum/version -e 'puts CalendariumRomanum::VERSION'`
GEM=calendarium-romanum-$VERSION.gem

rvm gemset create $GEMSET
rvm @$GEMSET do gem install --no-document $GEM

## test loading in a program
rvm @$GEMSET do calendariumrom query
echo $?

## clean
rvm gemset delete --force $GEMSET

echo 'Gem build test finished successfully'
