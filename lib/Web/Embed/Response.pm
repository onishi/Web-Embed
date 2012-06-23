package Web::Embed::Response;
use strict;
use warnings;

use Any::Moose;
has uri           => (is => 'ro');
has http_response => (is => 'ro', isa => 'HTTP::Response');
has matched_uri   => (is => 'ro');

sub new_from_uri {
    my ($class, $uri) = @_;
    my $res = $class->new( uri => $uri );
    $res;
}

1;
