# -*-Perl-*-
## Bioperl Test Harness Script for Modules
## $Id$

# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.t'

use strict;

BEGIN {

    # to handle systems with no installed Test::More module
    # we include the t dir (where a copy of Test/More.pm is located)
    # as a fallback
    eval { require Test::More; };
    if ($@) {
        use lib 't/lib';
    }
    use vars qw($NTESTS);
    
    $NTESTS = 65;

    use Test::More;
    plan tests => $NTESTS;
}

use_ok('Bio::SearchIO');
use_ok('Bio::Root::IO');

my $wabain = new Bio::SearchIO(
    -format => 'waba',
    -file   => Bio::Root::IO->catfile( 't', 'data', 'test.waba' )
);

isa_ok($wabain, 'Bio::SearchIO') ;

# These won't look the same as the WABA file because Jim's code is 0 based
# while we (bioperl) are 1 based.
my @results = (
    [
        'U57623',
        'pair1_hs.fa',
        'pair1_mm.fa',
        [
            'U02884',
            3,
            [qw(3833 34 2972 1 243 3688 1 40.9)],
            [qw(4211 3022 6914 1 3705 6848 1 43.7)],
            [qw(2218 7004 9171 1 6892 8712 1 50.3)],
        ],
    ],
    [
        'X57152', 'pair9_hs.fa',
        'pair9_mm.fa', [ 'X80685', 1, [qw(7572 4 5845 1 632 7368 1 46.8)], ],
    ]
);

while ( my $wabar = $wabain->next_result ) {
    my @r = @{ shift @results };
    is( $wabar->query_name,     shift @r, 'query_name'     );
    is( $wabar->query_database, shift @r, 'query database' );
    is( $wabar->database_name,  shift @r, 'database name'  );

    while ( my $wabah = $wabar->next_hit ) {
        my (@h) = @{ shift @r };
        is( $wabah->name, shift @h, 'name' );
        is( $wabah->hsps(), shift @h, 'hsps' );

        while ( my $wabahsp = $wabah->next_hsp ) {
            my (@hsp) = @{ shift @h };
            is( $wabahsp->length('total'),        shift @hsp , 'total length');
            is( $wabahsp->query->start,           shift @hsp , 'start'       );
            is( $wabahsp->query->end,             shift @hsp , 'end'         );
            is( $wabahsp->strand('query'),        shift @hsp , 'strand'      );
            is( $wabahsp->start('hit'),           shift @hsp , 'start'       );
            is( $wabahsp->end('subject'),         shift @hsp , 'end'         );
            is( $wabahsp->subject->strand,        shift @hsp, 'strand'       );
            is( length( $wabahsp->query_string ), $wabahsp->length('total') , 'query string');
            is( length( $wabahsp->hit_string ),   $wabahsp->length('total') , 'hit_string'  );
            is( length( $wabahsp->hmmstate_string ),
                $wabahsp->length('total') , 'hmmstate string');
            my $hs = $wabahsp->hit_string;
            is( $wabahsp->gaps('hit'), $hs =~ tr/\-// );
            my $qs = $wabahsp->query_string;
            is( $wabahsp->gaps('query'), $qs =~ tr/\-// );
            is( sprintf( "%.1f", $wabahsp->percent_identity ), shift @hsp );
        }
    }
}
