use Gearman::XS qw(:constants);
use Gearman::XS::Client;
use JSON;

my $client = new Gearman::XS::Client;

my $ret = $client->add_server( '127.0.0.1', '4730' );
if ( $ret != GEARMAN_SUCCESS ) {
    printf( STDERR "%s\n", $client->error() );
    exit(1);
}
my $json = encode_json {
    method       => 'get_search',
    args         => 'Brazil',
    class_params => {
        query   => 'teste',
        results => 50,
        sort    => 'date_desc',
        appid =>
'9J_NabHV34Fuzb1qIdxpKfQdBmV6eaMGeva5NESfQ7IDCupidoKd_cSGK7MI5Xvl.eLeQKd9YkPOU0M4DsX73A--'
    }
};
print $json, "\n";

my $res = decode_json $client->do( "init_worker", $json );

use Data::Dumper;
print Dumper $res;
