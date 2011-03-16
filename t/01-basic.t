package Foo;

use Moose;

sub numeric {
    my ( $self, $arg ) = @_;
    return $arg;
}

sub hashref {
    my ( $self, $arg ) = @_;
    return { foo => $arg };
}

sub arrayref {
    my ( $self, $arg ) = @_;
    return [ 0 .. $arg ];
}

package main;
use MooseX::Gearman::Worker;
use Gearman::XS qw(:constants);
use Gearman::XS::Client;
use JSON::XS;
use KiokuDB;
use Yahoo::Answers;

use Test::Simple tests => 30;

# Init MooseX::Gearman::Worker

my $pid = fork;
if ( $pid == 0 ) {
    my $mgw = MooseX::Gearman::Worker->new();
    $mgw->init;
}

# - Gearman Conection
my $client = new Gearman::XS::Client;
my $ret = $client->add_server( '127.0.0.1', '4730' );
if ( $ret != GEARMAN_SUCCESS ) {
    printf( STDERR "%s\n", $client->error() );
    exit(1);
}

# - KiokuDb
my $dir      = KiokuDB->connect("config/store.yml");
my $s        = $dir->new_scope;
my $foo      = Foo->new;
my $class_id = $dir->store($foo);                      #Storing "Foo" class

# - Test Numeric

for ( 1 .. 10 ) {
    my $serialize = serialize( $class_id, 'numeric', $_ );
    my $response = decode_json $client->do( "init_worker", $serialize );
    ok( $response->[0] == $_, "Response Numeric" );
}

# - Test HashRef

for ( 1 .. 10 ) {
    my $serialize = serialize( $class_id, 'hashref', $_ );
    my $response = decode_json $client->do( "init_worker", $serialize );
    ok( $response->[0]->{foo} == $_, "Response HashRef" );
}

# - Test ArrayRef

for ( 1 .. 10 ) {
    my $serialize = serialize( $class_id, 'arrayref', $_ );
    my $response = decode_json $client->do( "init_worker", $serialize );
    ok( scalar @{ $response->[0] } == ( $_ + 1 ), "Response ArrayRef" );
}

sub serialize {
    my ( $class_id, $method, $args ) = @_;
    return encode_json {
        object => { id => $class_id },
        method => $method,
        args   => $args
    };
}

# Kill MooseX::Gearman::Worker
my $kill_worker = kill 1, $pid;

