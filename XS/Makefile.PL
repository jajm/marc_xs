use Modern::Perl;
use ExtUtils::MakeMaker;
use Config;

WriteMakefile(
    NAME => 'MARC::XS',
    PREREQ_PM => {},
    VERSION_FROM => '../lib/MARC/XS.pm',
    CCFLAGS => '-Wall -Wextra -std=c99',
    LIBS => [''],
    INC => '-I.',
    OBJECT => '$(O_FILES)',
);
