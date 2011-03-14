package MooseX::Gearman::Worker;

use Moose;
with 'MooseX::Traits';

use Class::MOP::Class;
use Gearman::XS qw(:constants);
use Gearman::XS::Worker;
use JSON;

use MooseX::Types::Common::Numeric qw/PositiveInt/;
use MooseX::Types::Common::String qw/SimpleStr/;

=head1 NAME

MooseX::Gearman::Worker - The great new MooseX::Gearman::Worker!

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use MooseX::Gearman::Worker;

    my $foo = MooseX::Gearman::Worker->new();
    ...

=cut

=head2 class attributes

Specify the class attributes.

=cut

has 'class_name' => ( is => 'rw', isa => 'Str', required => 1 );
has 'class_params' => (
    is         => 'rw',
    isa        => 'HashRef',
    required   => 1,
    auto_deref => 1
);

has 'metaclass' => (
    is  => 'rw',
    isa => 'Object',
);

has 'class_methods' => (
    is         => 'rw',
    isa        => 'ArrayRef[Object]',
    auto_deref => 1
);

=head2 gearman attributes

=cut

has 'gearman_host' => ( is => 'rw', isa => SimpleStr, default => '127.0.0.1' );
has 'gearman_port' => ( is => 'rw', isa => PositiveInt, default => '4730' );
has 'gearman_worker' => (
    is      => 'ro',
    isa     => 'Object',
    default => sub {
        Gearman::XS::Worker->new;
    },
    lazy => 1
);

sub init {
    my $self = shift;
    $self->get_class;
    $self->register_function;
}

before 'get_class' => sub {
    my $self = shift;
    eval { Class::MOP::load_class( $self->class_name, $self->class_params ); };
    die $@ if $@;
    $self->metaclass( Class::MOP::get_metaclass_by_name( $self->class_name ) );
};

=head2 get_class

Load the class and get the metaclass of the class.

=cut

sub get_class {
    my $self = shift;
    $self->class_methods( $self->_get_class_methods( $self->metaclass ) );
}

=head2 get_class_methods

Return all methods of the class.

=cut

sub _get_class_methods {
    my ( $self, $metaclass ) = @_;
    my @methods = $metaclass->get_all_methods;
    my @class_methods;
    foreach my $method (@methods) {
        push @class_methods, $method
          if $method->original_package_name eq $self->class_name;
    }
    \@class_methods;
}

# WORKING ON IT

before 'register_function' => sub {
    my $self = shift;
    $self->gearman_worker->add_server( $self->gearman_host,
        $self->gearman_port );
};

sub register_function {
    my $self = shift;
    foreach my $method ( $self->class_methods ) {
        $self->gearman_worker->add_function( $method->name, 0, $method->body,
            0 );
    }

    my $ret = $self->gearman_worker->add_function( "reverse", 0, \&_unserialization, 0 );

}

after 'register_function' => sub {
    my $self = shift;
    while (1) {
        my $ret = $self->gearman_worker->work();
        if ( $ret != GEARMAN_SUCCESS ) {
            print STDERR $self->gearman_worker->error;
            redo;
        }
    }
};

# AND IT
sub _unserialization {
    use Data::Dumper;
    print Dumper @_;
}

sub reverse {
    my $job = shift;

    my $workload = $job->workload();
    my $result   = reverse($workload);

    printf( "Job=%s Function_Name=%s Workload=%s Result=%s\n",
        $job->handle(), $job->function_name(), $job->workload(), $result );

    return $result;
}

=head2 

=head1 AUTHOR

Daniel de Oliveira Mantovani, C<< <daniel.oliveira.mantovani at gmail.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-moosex-gearman-worker at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=MooseX-Gearman-Worker>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.


=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc MooseX::Gearman::Worker


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=MooseX-Gearman-Worker>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/MooseX-Gearman-Worker>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/MooseX-Gearman-Worker>

=item * Search CPAN

L<http://search.cpan.org/dist/MooseX-Gearman-Worker/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2011 Daniel de Oliveira Mantovani.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut

1;    # End of MooseX::Gearman::Worker
