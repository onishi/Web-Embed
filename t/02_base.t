use t::Embed;
use utf8;
use Test::Base;
use Web::Embed;

plan tests => 1 * blocks;

filters {
    input    => [qw/chomp/],
    expected => [qw/chomp/],
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

