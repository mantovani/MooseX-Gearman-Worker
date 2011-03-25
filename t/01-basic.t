use lib 'lib';

use MooseX::Gearman::Worker;
use Gearman::XS qw(:constants);
use Gearman::XS::Client;
use JSON::XS;
use KiokuDB;
use Yahoo::Answers;

use Test::Simple tests => 30;

use MooseX::Gearman::Worker::Test;

# Init MooseX::Gearman::Worker

my $pid = fork;
if ( $pid == 0 ) {
    my $mgw =
      MooseX::Gearman::Worker->new(
        class_name => 'MooseX::Gearman::Worker::Test' );
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
my $foo      = MooseX::Gearman::Worker::Test->new;
my $class_id = $dir->store($foo);                      #Storing "Foo" class

# - Test Numeric

for ( 1 .. 10 ) {
    my $exec_method = 'numeric';
    my $serialize   = serialize( $class_id, $exec_method, $_ );
    my $response    = decode_json $client->do( $exec_method, $serialize );
    ok( $response->[0] == $_, "Response Numeric" );
}

# - Test HashRef

for ( 1 .. 10 ) {
    my $exec_method = 'hashref';
    my $serialize   = serialize( $class_id, $exec_method, $_ );
    my $response    = decode_json $client->do( $exec_method, $serialize );
    ok( $response->[0]->{foo} == $_, "Response HashRef" );
}

# - Test ArrayRef

for ( 1 .. 10 ) {
    my $exec_method = 'arrayref';
    my $serialize   = serialize( $class_id, $exec_method, $_ );
    my $response    = decode_json $client->do( $exec_method, $serialize );
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

