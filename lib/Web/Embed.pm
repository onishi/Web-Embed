package Web::Embed;
use strict;
use warnings;

our $VERSION => '0.01';

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

has cache => (
    is      => 'rw',
    default => sub {
        require Cache::MemoryCache;
        Cache::MemoryCache->new({
            namespace => __PACKAGE__ . "/" . $VERSION,
        });
    }
);

use Web::oEmbed;

sub embed {
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