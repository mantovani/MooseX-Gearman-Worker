package main;
use MooseX::Gearman::Worker;
use Gearman::XS qw(:constants);
use Gearman::XS::Client;
use JSON::XS;
use KiokuDB;
use Yahoo::Answers;
use Data::Dumper;
use Test::Simple tests => 1;

#worker

my $pid = fork;
if ( $pid == 0 ) {
    my $mgw = MooseX::Gearman::Worker->new();
    $mgw->init;
}

#client
# - Gearman
my $client = new Gearman::XS::Client;
my $ret = $client->add_server( '127.0.0.1', '4730' );
if ( $ret != GEARMAN_SUCCESS ) {
    printf( STDERR "%s\n", $client->error() );
    exit(1);
}

# - KiokuDb
my $dir = KiokuDB->connect("config/store.yml");
my $s   = $dir->new_scope;

my $foo = Foo->new;

my $class_id = $dir->store($foo);

my $serialize = serialize( $class_id, 'test', '1' );
my $response = decode_json $client->do( "init_worker", $serialize );

ok( $response == 2, "Response = 2" );

sub serialize {
    my ( $class_id, $method, $args ) = @_;
    return encode_json {
        object => { id => $class_id },
        method => $method,
        args   => $args
    };
}

package Foo;

use Moose;

sub test {
    my ( $self, $arg ) = @_;
    return ( 1 + $arg );
}
