package Web::Embed::Response;
use strict;
use warnings;

our $providers;

use Web::Embed::oEmbed;
use HTML::ResolveLink;

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

sub content {
    my ($self, $uri) = @_;
    my $res = $self->http_response($uri);
    $self->{_content} ||= do {
        my $content = $res->decoded_content;
        # content_type 見る
        $content = $res->content_type =~ m/text|html|xml/i ? $content : '';

        # content_type が嘘でバイナリ含んでても空に
        if ($content && $content =~ /([\x00-\x06\x7f\xff])/) {
            $content = '';
        }
        my $code = $self->get_code($content);
        if ($code && !Encode::is_utf8($content)) {
            $content = Encode::decode($code, $content);
        }
        my $resolver = HTML::ResolveLink->new(
            base => $uri,
        );
        $content = $resolver->resolve($content);
        $content;
    }
}

sub get_code {
    my $self = shift;
    my $content = shift or return;
    my $code = '';
    if ($content =~ /\xFD\xFE/) {
        $code = 'euc-jp';
    } elsif ($content =~ /<meta[^>]+?charset=([^>]+)>/i) {
        my $charset = $1;
        if ($charset =~ /Shift_JIS|x-sjis|SJIS/i) {
            $code = 'shiftjis';
        } elsif ($charset =~ /euc-jp/i) {
            $code = 'euc-jp';
        } elsif ($charset =~ /iso-2022-jp/i) {
            $code = '7bit-jis';
        } elsif ($charset =~ /iso-8859/i) {
            $code = 'ascii';
        } elsif ($charset =~ /utf-8/i) {
            $code = 'utf-8';
        }
    } else {
        my $enc = guess_encoding($content, qw/shiftjis euc-jp 7bit-jis utf-8/);
        $code = ref($enc) ? $enc->name : 'utf-8';
    }
    return $code || 'utf-8';
}

sub http_response {
    my ($self, $uri) = @_;
    $self->{_http_response} ||= do {
        my $res;
        if ($self->cache) {
            $res = $self->cache->get($uri);
        }
        unless ($res) {
            for (1..3) { # retry
                $res = $self->agent->get($uri);
                $res->is_success and last;
            }
            if ($self->cache && $res->is_success) {
                $self->cache->set($uri, $res);
            }
        }
        $res;
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
