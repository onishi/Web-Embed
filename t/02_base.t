use strict;
use warnings;
use utf8;
use Test::Base;
use Web::Embed;
use File::Slurp qw/read_file/;
use FindBin;

plan tests => 1 * blocks;

filters {
    input    => [qw/chomp/],
    expected => [qw/chomp/],
};

no  warnings qw/redefine once/;
local *LWP::UserAgent::get = sub {
    my ($self, $url) = @_;
    diag $url;
    (my $file = $url) =~ s{[:/.\?&]+}{_}g;
    $file = "$FindBin::Bin/stub/$file";
    diag $file;
    my $content = read_file($file) or die("no stub fo $url");
    my $res = HTTP::Response->new(200);
    $res->content_type('text/html/json'); # XXX
    $res->content($content || '');
    return $res;
};

my $embed = Web::Embed->new;

run {
    my $block = shift;
    is($embed->render($block->input), $block->expected, $block->name);
}

__END__

=== twitter
--- input
https://twitter.com/kentaro/status/13430016778
--- expected
<blockquote class="twitter-tweet" lang="ja"><p>アニソンとか聴いて喜んでいるひとが心底かわいそうに思います。反感を抱かれるでしょうけど、劣っていると思いますよ。</p>&mdash; kentaroさん (@kentaro) <a href="https://twitter.com/kentaro/status/13430016778" data-datetime="2010-05-05T14:42:21+00:00">5月 5, 2010</a></blockquote>
<script src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

=== flickr
--- input
http://www.flickr.com/photos/btaphoto/42185736/in/photostream
--- expected
<a href="http://www.flickr.com/photos/btaphoto/42185736/" title="DSC_0852"><img alt="DSC_0852" src="src" /></a>

