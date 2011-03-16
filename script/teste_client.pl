use Gearman::XS qw(:constants);
use Gearman::XS::Client;
use JSON::XS;
use KiokuDB;
use Yahoo::Answers;
use Data::Dumper;

use strict;
use warnings;

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

# - Any Class
my $ya = Yahoo::Answers->new(
    query   => 'teste',
    results => 50,
    sort    => 'date_desc',
    appid =>
'9J_NabHV34Fuzb1qIdxpKfQdBmV6eaMGeva5NESfQ7IDCupidoKd_cSGK7MI5Xvl.eLeQKd9YkPOU0M4DsX73A--'
);

$ya->region_by_name('Brazil');

# - Storing class in Kioku
my $class_id = $dir->store($ya);

# - Execute a method of this class at worker.

# First argument "get_search" is the method of "Any Class" and
# the 2º argument is the "argument inside get_search
# "get_search(1);"

my $serialize = serialize( $class_id, 'get_search', '1' );
print Dumper decode_json $client->do( "init_worker", $serialize );

sub serialize {
    my ( $class_id, $method, $args ) = @_;
    return encode_json {
        object => { id => $class_id },
        method => $method,
        args   => $args
    };
}

