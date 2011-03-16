#!/usr/bin/perl

use strict;
use warnings;

use MooseX::Gearman::Worker;

my $mgw = MooseX::Gearman::Worker->new();
$mgw->init;
