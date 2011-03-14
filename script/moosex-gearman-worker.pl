#!/usr/bin/perl

use 5.10.1;

use strict;
use warnings;

use MooseX::Gearman::Worker;

my $mgw = MooseX::Gearman::Worker->new( class_name => $ARGV[0], );
$mgw->init;
