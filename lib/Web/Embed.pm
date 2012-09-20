package Web::Embed;
use strict;
use warnings;

our $VERSION = '0.01';

use Any::Moose;
use Module::Load;

has agent => (
    is      => 'rw',
    isa     => 'LWP::UserAgent',
    default => sub {
        require LWP::UserAgent;
        LWP::UserAgent->new(
            agent    => __PACKAGE__ . "/" . $VERSION,
            max_size => 500_000,
        );
    }
);

has cache => (is => 'rw');

has response_class => (
    is  => 'rw',
    isa => 'Str',
    default => 'Web::Embed::Response',
);

__PACKAGE__->meta->make_immutable;
no Any::Moose;

sub embed {
    my ($self, $uri) = @_;
    $uri = $self->canonical_url($uri);

    load $self->response_class;

    $self->response_class->new(
        uri   => $uri,
        agent => $self->agent,
        cache => $self->cache,
    );
}

# shortcut method
sub render {
    my ($self, $uri) = @_;
    $self->embed($uri)->render;
}

sub canonical_url {
    my ($self, $uri) = @_;
    $uri =~ s{/#!/}{/}; # remove hash-bang
    $uri;
}

1;

=pod

=head1 NAME

Web::Embed - convert URL to embedded HTML

=head1 SYNOPSIS

  use Web::Embed

  my $api = Web::Embed->new(
    agent => $ua,
    cache => $cache,
  );

  my $res = $api->embed($url);

  $res->oembed;   # Web::oEmbed::Response

  $res->title;    # page title
  $res->metadata; # meta elemnt information (hashref)
  $res->link;     # link element information (hashref)

  $res->og;       # ogp information (hashref)
  $res->dc;       # dc (Dublin Core) information (hashref)

  print $res->render;

=head1 DESCRIPTION

Web::Embed is a module that convert URL to embedded HTML

=head1 AUTHOR

Yasuhiro Onishi E<lt>yasuhiro.onishi@gmail.comE<gt>

=head1 SEE ALSO

=over

=item L<Web::oEmbed>

=back

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
