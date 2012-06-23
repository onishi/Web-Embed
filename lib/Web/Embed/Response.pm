package Web::Embed::Response;
use strict;
use warnings;

our $providers;

use Web::Embed::oEmbed;
use Any::Moose;
has uri  => (is => 'ro');

has oembed_consumer => (
    is      => 'ro',
    isa     => 'Web::Embed::oEmbed',
    default => sub {
        my $consumer = Web::Embed::oEmbed->new;
        $consumer->register_provider($_) for @$providers;
        $consumer;
    }
);

sub new_from_uri {
    my ($class, $uri) = @_;
    my $res = $class->new( uri => $uri );
    $res;
}

sub render {
    my $self = shift;
    if (my $oembed = $self->oembed) {
        return $oembed->render;
    }
}

sub oembed {
    my $self = shift;
    $self->{_oembed} ||= eval {
        $self->oembed_consumer->embed($self->uri);
    };
}

1;
