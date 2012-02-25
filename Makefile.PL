use Modern::Perl;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME              => 'MARC',
    VERSION_FROM      => 'lib/MARC/XS.pm',
    PREREQ_PM         => {},
    AUTHOR            => 'Julian Maurice <jajm@jajm.org>',
    LIBS              => [''], # e.g., '-lm'
    DEFINE            => '', # e.g., '-DHAVE_SOMETHING'
    INC               => '-I.', # e.g., '-I. -I/usr/include/other'
    DIR               => ['XS']
);
