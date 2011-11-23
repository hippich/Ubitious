#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;

BEGIN { use_ok 'Catalyst::Test', 'Ubitious' }

use_ok 'Test::WWW::Mechanize::Catalyst';

my $mech = Test::WWW::Mechanize::Catalyst->new(catalyst_app => 'Ubitious');

$mech->get_ok("http://localhost/file/upload", "Open file upload page");

done_testing();
