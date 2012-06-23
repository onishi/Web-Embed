package Web::Embed::oEmbed;
use strict;
use warnings;

our ($providers, $extended);

use Any::Moose;
extends 'Web::oEmbed';

sub BUILD {
    my $self = shift;
    $self->register_provider($_) for @$providers;
    return $self;
}

# Twitter など http でも https でも1つの定義で動くように
override '_compile_url' => sub {
    my($self, $url) = @_;
    my $res = super();
    $res =~ s{^http:}{https?:};
    $res;
};

override 'request_url' => sub {
    my($self, $uri, $opt) = @_;

    for my $re (keys %$extended) {
        if ($uri =~ $re) {
            return $extended->{$re}->();
        }
    }

    my $req_uri = super();
    my $provider = $self->provider_for($uri);

    ## oembed endpoint auto-discovery
    # [TODO]: NOT IMPLEMENTED
    # unless ($provider) {
    #     $req_uri = $self->request_url_from_link($uri);
    #     return $req_uri if $req_uri;
    # }
    # # それでもなければあきらめる
    # $provider or return;

    # wordpress が for=hoge というクエリ付けないといけないので拡張
    if (my $params = $provider->{params}) {
        $req_uri->query_form(
            $req_uri->query_form,
            %$params,
        );
    }

    return $req_uri;
};

BEGIN {
    $providers = [
        {
            url  => 'http://*.flickr.com/*',
            api  => 'http://www.flickr.com/services/oembed/',
        },
        {
            url  => 'http://*.wordpress.com/*',
            api  => 'http://public-api.wordpress.com/oembed/',
            params => {
                for => __PACKAGE__,
            },
        },
        {
            url => 'http://www.slideshare.net/*/*',
            api => 'http://www.slideshare.net/api/oembed/2',
        },
        {
            url => 'http://*.viddler.com/*',
            api => 'http://lab.viddler.com/services/oembed/',
        },
        {
            url => 'http://qik.com/*',
            api => 'http://qik.com/api/oembed.{format}',
        },
        {
            url => 'http://*.revision3.com/*',
            api => 'http://revision3.com/api/oembed/',
        },
        {
            url => 'http://www.hulu.com/watch/*',
            api => 'http://www.hulu.com/api/oembed.{format}',
        },
        {
            url => 'http://vimeo.com/*',
            api => 'http://vimeo.com/api/oembed.{format}',
        },
        {
            url => 'http://www.collegehumor.com/video/*',
            api => 'http://www.collegehumor.com/oembed.{format}',
        },
        {
            url => 'http://www.polleverywhere.com/*',
            api => 'http://www.polleverywhere.com/services/oembed/',
        },
        {
            url => 'http://www.ifixit.com/Guide/View/*',
            api => 'http://www.ifixit.com/Embed',
        },
        {
            url => 'http://*.smugmug.com/*',
            api => 'http://api.smugmug.com/services/oembed/',
        },
        {
            url => 'http://soundcloud.com/*',
            api => 'http://soundcloud.com/oembed',
        },
    ];

    $extended = {
        qr{https?://twitter[.]com/(\w+)/status/(\d+)} => sub {
            sprintf 'http://twitter.com/%s/oembed/%d.json', $1, $2;
        },
    };
};

1;
