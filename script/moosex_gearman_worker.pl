#!/usr/bin/perl

use strict;
use warnings;

use 5.10.1;

use MooseX::Gearman::Worker;

my $moosex_gearman_worker =
  MooseX::Gearman::Worker->new( class_name => $ARGV[0] );

$moosex_gearman_worker->init;
