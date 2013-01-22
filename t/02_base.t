use t::Embed;
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
<div class="summary no-image"><a href="http://www.flickr.com/photos/btaphoto/42185736/in/photostream" target="_blank" class="summary-title">http://www.flickr.com/photos/btaphoto/42185736/in/photostream</a></div>

=== gist http
--- input
http://gist.github.com/1156287
--- expected
<script src="https://gist.github.com/1156287.js"> </script>

=== gist https
--- input
https://gist.github.com/1156287
--- expected
<script src="https://gist.github.com/1156287.js"> </script>

=== youtube
--- input
http://www.youtube.com/watch?v=-o58YST68QA
--- expected
<iframe width="420" height="315" src="http://www.youtube.com/embed/-o58YST68QA?wmode=transparent" frameborder="0" allowfullscreen></iframe>

=== ugomemo
--- input
http://ugomemo.hatena.ne.jp/0265A0404CDEDD58@DSi/movie/DEDD58_08ACA9E0E6FD8_000?in=user
--- expected
<object data="http://ugomemo.hatena.ne.jp/js/ugoplayer_s.swf" type="application/x-shockwave-flash" width="279" height="240"><param name="movie" value="http://ugomemo.hatena.ne.jp/js/ugoplayer_s.swf"></param><param name="FlashVars" value="did=0265A0404CDEDD58&file=DEDD58_08ACA9E0E6FD8_000"></param></object>

=== flipnote
--- input
http://flipnote.hatena.com/57F8EF2031CF8A62@DSi/movie/CF8A62_0B9FDBFDE6CA5_001?in=movies&sort=recent
--- expected
<object data="http://flipnote.hatena.com/js/flipplayer_s.swf" type="application/x-shockwave-flash" width="279" height="240"><param name="movie" value="http://flipnote.hatena.com/js/flipplayer_s.swf"></param><param name="FlashVars" value="did=57F8EF2031CF8A62&file=CF8A62_0B9FDBFDE6CA5_001"></param></object>

=== nicovideo
--- input
http://www.nicovideo.jp/watch/sm15345209?top_flog
--- expected
<script type="text/javascript" src="http://ext.nicovideo.jp/thumb_watch/sm15345209"></script>

=== nicovideo live
--- input
http://live.nicovideo.jp/watch/lv95420643?ref=nicotop
--- expected
<script type="text/javascript" src="http://ext.nicovideo.jp/thumb_watch/lv95420643"></script>

=== summary
--- input
http://example.com
--- expected
<div class="summary has-image"><a href="http://example.com" target="_blank" class="summary-image"><img src="http://example.com/image.jpg" alt=""/></a><a href="http://example.com" target="_blank" class="summary-title">title!</a><span class="summary-description">dc-description</span></div>
