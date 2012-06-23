package Web::Embed::Response;
use strict;
use warnings;
use 5.010;
use utf8;

our ($embeds);

use Encode;
use Encode::Guess;
use HTML::ResolveLink;
use Text::MicroTemplate;
use Web::Embed::Scraper;
use Web::Embed::oEmbed;

use Any::Moose;
has uri   => (is => 'ro');
has cache => (is => 'rw');
has agent => (is => 'rw');
has oembed_consumer => (
    is      => 'ro',
    isa     => 'Web::Embed::oEmbed',
    default => sub { Web::Embed::oEmbed->new },
);

__PACKAGE__->meta->make_immutable;
no Any::Moose;

sub new_from_uri {
    my ($class, $uri) = @_;
    my $res = $class->new( uri => $uri );
    $res;
}

sub render {
    my $self = shift;

    # 問い合わせ不要
    for my $embed (@$embeds) {
        if ($self->uri =~ $embed->{regexp}) {
            if (ref $embed->{format} eq 'CODE') {
                return $embed->{format}->(\%+);
            } else {
                my $sub = template($embed->{format}, [keys %+]);
                return $sub->(\%+);
            }
        }
    }

    # oEmbed
    if (my $oembed = $self->oembed) {
        return render_oembed($oembed);
    }

    return $self->summary;
}

sub summary {
    my $self = shift;
    my $uri = $self->uri;
    my $res = $self->http_response;
    if ($res && $res->content_type =~ m(^image/)) {
        return sprintf qq(<a href="%s" class="image"><img src="%s"></a>\n), $uri, $uri;
    }

}

sub title {
    my $self = shift;
    $self->{_title} ||= do { $self->scraper->text('title') };
}

sub description {
    my $self = shift;
    $self->og->{description} || $self->dc->{description} || $self->metadata->{description} || $self->extract_content;
}

sub image {
    my $self = shift;
    $self->og->{image} || $self->link->{image_src} || $self->microdata->{image} || $self->scraper->image;
}

sub metadata {
    my $self = shift;
    $self->{_metadata} ||= do {
        {
            description => $self->scraper->metas('description') || undef,
            keywords    => $self->scraper->metas('keywords') || undef,
        };
    }
}

sub microdata {
    # [TODO]: NOT IMPLEMENTED
    {};
}

sub og {
    my $self = shift;
    $self->{_og} ||= $self->scraper->og;
}

sub dc {
    my $self = shift;
    $self->{_dc} ||= $self->scraper->dc;
}

sub link {
    my $self = shift;
    $self->{_link} ||= $self->scraper->links;
}

sub scraper {
    my $self = shift;
    $self->{_scraper} ||= do {
        Web::Embed::Scraper->new( content => $self->content );
    };
}

sub extract_content {
    my $self = shift;
    my $text =  HTML::ExtractContent->new->extract($self->content)->as_text;
    $text =~ s{<[^>]*>}{}g;
    return $text;
}

sub content {
    my $self = shift;
    my $res = $self->http_response;
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
            base => $self->uri,
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
    my $self = shift;
    $self->{_http_response} ||= do {
        my $res;
        my $uri = $self->uri;
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

sub unindent ($) {
    my $string = shift;
    my ($indent) = ($string =~ /^\n?(\s*)/);
    $string =~ s/^$indent//gm;
    $string =~ s/\s+$//;
    $string;
}

sub template ($$) {
    my ($template, $keys) = @_;

    my $mt = Text::MicroTemplate->new(
        tag_start   => '{{',
        tag_end     => '}}',
        template    => unindent $template,
        escape_func => undef,
    );

    my $code     = $mt->code;
    my $expand   = join('; ', map { "my \$$_ = \$_[0]->{$_}" } @$keys);
    my $renderer = eval << "    ..." or die $@;
        sub {
            $expand;
            $code->();
        }
    ...
}

BEGIN {
    $embeds = [
        {
            regexp => qr{^https?://gist.github.com/(?<id>\d+)}i,
            format => q{<script src="https://gist.github.com/{{= $id }}.js"> </script>},
        },
        {
            regexp => qr{^https?://(?:jp|www)[.]youtube[.]com/watch[?]v=(?<id>[\w\-]+)}i,
            format => q{<iframe width="420" height="315" src="http://www.youtube.com/embed/{{= $id }}?wmode=transparent" frameborder="0" allowfullscreen></iframe>},
        },
        {
            regexp => qr{^http://(?<domain>ugomemo[.]hatena[.]ne[.]jp|flipnote[.]hatena[.]com)/(?<did>[0-9A-Fa-f]{16})[@]DSi/movie/(?<file>[0-9A-Za-z_]{10,30})}i,
            format => sub {
                my ($domain, $did, $file) = map { $_[0]->{$_} } qw/domain did file/;
                my $swf = {
                    'ugomemo.hatena.ne.jp' => 'http://ugomemo.hatena.ne.jp/js/ugoplayer_s.swf',
                    'flipnote.hatena.com' => 'http://flipnote.hatena.com/js/flipplayer_s.swf',
                }->{$domain};
                return sprintf(
                    q{<object data="%s" type="application/x-shockwave-flash" width="279" height="240"><param name="movie" value="%s"></param><param name="FlashVars" value="did=%s&file=%s"></param></object>},
                    $swf,
                    $swf,
                    $did,
                    $file,
                );
            }
        },
        {
            regexp => qr{^http://(?:www|live).nicovideo.jp/watch/(?<vid>\w+)}i,
            format => q{<script type="text/javascript" src="http://ext.nicovideo.jp/thumb_watch/{{= $vid }}"></script>},
        },
    ];
};

1;
