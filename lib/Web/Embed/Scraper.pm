package Web::Embed::Scraper;
use strict;
use warnings;

use HTML::TreeBuilder::XPath;
use HTML::Selector::XPath;

use Any::Moose;
has content => (is => 'ro');

__PACKAGE__->meta->make_immutable;
no Any::Moose;

sub DEMOLISH {
    my $self = shift;
    $self->tree->delete if $self->tree;
}

sub node {
    my ($self, $selector) = @_;
    my @nodes = $self->tree->findnodes(HTML::Selector::XPath->new($selector)->to_xpath);
    return wantarray ? @nodes : $nodes[0];
}

sub text {
    my ($self, $selector) = @_;
    my $node = $self->node($selector) or return;
    $node->as_text;
}

sub metas {
    my ($self, $name) = @_;
    for my $meta ($self->node('meta')) {
        $meta->attr('name') or next;
        $meta->attr('name') eq $name or next;
        return $meta->attr('content');
    }
}

sub og {
    my $self = shift;
    my $og = {};
    for my $meta ($self->node('meta')) {
        for my $attr_name (qw/name property/) {
            my $attr = $meta->attr($attr_name) || '';
            if ($attr =~ m{^og:(.+)$}) {
                $og->{$1} = $meta->attr('content');
            }
        }
    }
    $og;
}

sub dc {
    my $self = shift;
    my $dc = {};
    for my $rdf ($self->node('//rdf')) {
        for my $attr_name ($rdf->all_attr_names) {
            $attr_name or next;
            $attr_name =~ m{^dc:(\w+)} or next;
            $dc->{$1} = $rdf->attr($attr_name);
        }
    }
    $dc;
}

sub links {
    my $self = shift;
    my $links = {};
    for my $link ($self->node('//link')) {
        my $rel  = $link->attr('rel') or next;
        my $href = $link->attr('href') or next;
        $links->{$rel} = $href;
    }
    $links;
}

sub image {
    my $self = shift;
    for my $id (
        qw{
            prodImage
            main-image
            fbPhotoImage
        }
    ) {
        my $xpath = qq{id("$id")};
        my $node = $self->node($xpath) or next;
        ref($node) eq 'HTML::Element' or next;
        return $node->attr('src');
    }
}

sub tree {
    my $self = shift;
    $self->{_tree} ||= do {
        my $t = HTML::TreeBuilder::XPath->new;
        $t->store_comments(1) if ($t->can('store_comments'));
        $t->ignore_unknown(0);
        $t->parse($self->content) if $self->content;
        $t->eof;
        $t;
    }
}

1;
