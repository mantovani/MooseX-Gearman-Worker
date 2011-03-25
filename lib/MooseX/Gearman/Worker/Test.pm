package MooseX::Gearman::Worker::Test;

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

42;
