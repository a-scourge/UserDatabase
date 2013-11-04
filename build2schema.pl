#!/usr/bin/perl
#
use strict;
use warnings;

#!/usr/bin/perl
#
use strict;
use warnings;

# in a script
use DBIx::Class::Schema::Loader qw/ make_schema_at /;
make_schema_at(
    'My::Schema',
    { debug => 1,
      dump_directory => './schema_auto',
    },
    [ 'dbi:SQLite:dbname="db/example.db"',
       { loader_class => 'MyLoader' } # optionally
    ],
);
