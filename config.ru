#!/usr/bin/env rackup
# encoding: utf-8

# This file can be used to start Padrino,
# just execute it from the command line.

require File.expand_path("../config/boot.rb", __FILE__)

require 'sass/plugin/rack' 
use Sass::Plugin::Rack

run Padrino.application
