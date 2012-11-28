use inc::Module::Install;
name 'Web-Embed';
all_from 'lib/Web/Embed.pm';

requires 'Any::Moose';
requires 'Encode';
requires 'HTML::ResolveLink';
requires 'HTML::Selector::XPath';
requires 'HTML::TreeBuilder::XPath';
requires 'LWP::UserAgent';
requires 'Web::oEmbed';
requires 'Module::Load';

tests 't/*.t';
author_tests 'xt';

test_requires 'Test::More' => '0.94';
auto_set_repository;
auto_include;
WriteAll;
