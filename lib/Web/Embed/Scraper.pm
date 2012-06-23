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

# sub text {
#     my ($self, $selector) = @_;
#     my $node = $self->node($selector) or return;
#     $node->as_text;
# }

sub metas {
    my ($self, $name) = @_;
    for my $meta ($self->node('//meta')) {
        $meta->attr('name') or next;
        $meta->attr('name') eq $name or next;
        return $meta->attr('content');
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
