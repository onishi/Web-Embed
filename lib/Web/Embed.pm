package Web::Embed;
use strict;
use warnings;

our $VERSION = '0.01';

use Any::Moose;
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

__PACKAGE__->meta->make_immutable;
no Any::Moose;

use Web::Embed::Response;

sub embed {
    my ($self, $uri) = @_;
    $uri = $self->canonical_url($uri);
    Web::Embed::Response->new(
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
