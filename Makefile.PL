use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME => 'MooseX::Gearman::Worker',
    AUTHOR =>
      q{Daniel de Oliveira Mantovani <daniel.oliveira.mantovani@gmail.com>},
    VERSION_FROM  => 'lib/MooseX/Gearman/Worker.pm',
    ABSTRACT_FROM => 'lib/MooseX/Gearman/Worker.pm',
    ( $ExtUtils::MakeMaker::VERSION >= 6.3002
        ? ( 'LICENSE' => 'perl' )
        : () ),
    PL_FILES  => {},
    PREREQ_PM => {
        'Test::More'                     => 0,
        'Gearman::XS'                    => '0.11',
        'Moose'                          => 0,
        'MooseX::Types::Common::Numeric' => 0,
        'MooseX::Types::Common::String'  => 0,
        'KiokuDB'                        => 0,
    },
    dist  => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean => { FILES    => 'MooseX-Gearman-Worker-*' },
);
