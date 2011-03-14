use Gearman::XS qw(:constants);
use Gearman::XS::Client;

$client = new Gearman::XS::Client;

$ret = $client->add_server( '127.0.0.1', '4730' );
if ( $ret != GEARMAN_SUCCESS ) {
    printf( STDERR "%s\n", $client->error() );
    exit(1);
}

# single client interface
( $ret, $result ) = $client->do( "reverse", 'teststring' );
if ( $ret == GEARMAN_SUCCESS ) {
    printf( "Result=%s\n", $result );
}

