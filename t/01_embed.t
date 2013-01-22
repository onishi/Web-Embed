use t::Embed;
use Test::More tests => 10;
use Web::Embed;

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

# dc
{
    is $res->dc->{description}, 'dc-description';
};

# link
{
    is $res->link->{image_src}, 'http://example.com/image_src.jpg';
};

# image ... 動かない
# {
#     is $res->scraper->image, 'http://example.com/main.jpg';
# };
