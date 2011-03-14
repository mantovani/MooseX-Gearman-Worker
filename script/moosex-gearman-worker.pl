#!/usr/bin/perl

use 5.10.1;

use strict;
use warnings;

use MooseX::Gearman::Worker;

my $mgw = MooseX::Gearman::Worker->new(
    class_name   => 'Yahoo::Answers',
    class_params => {
        query   => 'teste',
        results => 50,
        sort    => 'date_desc',
        appid =>
'9J_NabHV34Fuzb1qIdxpKfQdBmV6eaMGeva5NESfQ7IDCupidoKd_cSGK7MI5Xvl.eLeQKd9YkPOU0M4DsX73A--'
    }
);
$mgw->get_class;
