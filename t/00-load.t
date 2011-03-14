#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'MooseX::Gearman::Worker' ) || print "Bail out!
";
}

diag( "Testing MooseX::Gearman::Worker $MooseX::Gearman::Worker::VERSION, Perl $], $^X" );
