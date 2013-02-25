package t::Embed;
use strict;
use warnings;
use utf8;
use Test::More;
use File::Slurp qw/read_file/;
use FindBin;
use LWP::Protocol::PSGI;
use Plack::Request;

sub import {
    strict->import;
    warnings->import;
    utf8->import;

    LWP::Protocol::PSGI->register(sub {
        my $env = shift;
        my $req = Plack::Request->new($env);
        my $file = $req->uri;
           $file =~ s<[::/.\?&]+><_>g;
           $file =~ s<_+$><>;

        my $content = read_file("t/stub/$file") or die 'no stub for ' . $req->uri;
        return [
            200,
            [ 'Content-Type' => $req->uri->path =~ /\.json$/ ? 'application/json' : 'text/html' ],
            [ $content ]
        ];
    });

    undef;
}

1;
