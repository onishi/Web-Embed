use t::Embed;
use Test::More tests => 3;
use Web::Embed;

my $guard = t::Embed::guard;

my $api = Web::Embed->new;

ok $api;

my $res = $api->embed('http://example.com');

is $res->metadata->{description}, 'meta-description';
is $res->metadata->{keywords}, 'hoge,fuga';

is $res->title, 'title!';
