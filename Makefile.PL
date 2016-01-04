use 5.006;
use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME             => 'HTML::FormHandlerX::JQueryRemoteValidator',
    AUTHOR           => q{David R. Baird <dave@zerofive.co.uk >},
    VERSION_FROM     => 'lib/HTML/FormHandlerX/JQueryRemoteValidator.pm',
    ABSTRACT_FROM    => 'lib/HTML/FormHandlerX/JQueryRemoteValidator.pm',
    LICENSE          => 'artistic_2',
    PL_FILES         => {},
    MIN_PERL_VERSION => 5.006,
    CONFIGURE_REQUIRES => {
        'ExtUtils::MakeMaker' => 0,
    },
    BUILD_REQUIRES => {
        'Test::More' => 0,
        'Test::LongString' => 0,
    },
    PREREQ_PM => {
        #'ABC'              => 1.6,
        #'Foo::Bar::Module' => 5.0401,
        'HTML::FormHandler::Moose::Role' => 0,
        'Method::Signatures::Simple' => 0,
        JSON => 0,
    },
    dist  => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean => { FILES => 'HTML-FormHandlerX-JQueryRemoteValidator-*' },
);
