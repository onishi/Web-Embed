use t::Embed;
use Test::More tests => 8;
use Web::Embed;

my $guard = t::Embed::guard;

my $api = Web::Embed->new;

ok $api;

my $res = $api->embed('http://example.com');

# meta
{
    is $res->metadata->{description}, 'meta-description';
    is $res->metadata->{keywords}, 'hoge,fuga';
};

# title
{
    is $res->title, 'title!';
};

# og
{
    is $res->og->{title}, 'og-title';
    is $res->og->{type},  'article';
    is $res->og->{url},   'http://example.com/';
    is $res->og->{image}, 'http://example.com/image.jpg';
};

