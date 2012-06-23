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
        render_oembed($oembed);
    }
}

sub oembed {
    my $self = shift;
    $self->{_oembed} ||= eval {
        $self->oembed_consumer->embed($self->uri);
    };
}

sub render_oembed {
    my $response = shift;
    if ($response->type eq 'photo') {
        if ($response->{web_page}) {
            my $element = HTML::Element->new('a', href => $response->{web_page});
            $element->attr(title => $response->title) if defined $response->title;
            my $img     = HTML::Element->new(
                'img',
                src    => $response->url,
            );
            $img->attr(alt => $response->title) if defined $response->title;
            $element->push_content($img);
            return $element->as_HTML;
        } else {
            my $img = HTML::Element->new(
                'img',
                src    => $response->url,
            );
            $img->attr(alt => $response->title) if defined $response->title;
            return $img->as_HTML;
        }
    }
    if ($response->type eq 'link') {
        my $element = HTML::Element->new('a', href => $response->url);
        $element->push_content(defined $response->title ? $response->title : $response->url);
        return $element->as_HTML;
    }
    if ($response->html) {
        return $response->html;
    }
}

1;
