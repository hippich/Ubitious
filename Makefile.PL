#!/usr/bin/env perl
# IMPORTANT: if you delete this file your app will not work as
# expected.  You have been warned.
use inc::Module::Install;
use Module::Install::Catalyst; # Complain loudly if you don't have
                               # Catalyst::Devel installed or haven't said
                               # 'make dist' to create a standalone tarball.

name 'Ubitious';
all_from 'lib/Ubitious.pm';

requires 'Catalyst::Runtime' => '5.80024';
requires 'Catalyst::Plugin::ConfigLoader';
requires 'Catalyst::Plugin::Static::Simple';
requires 'Catalyst::Action::RenderView';
requires 'Moose';
requires 'namespace::autoclean';
requires 'Config::General'; # This should reflect the config file format you've chosen
                 # See Catalyst::Plugin::ConfigLoader for supported formats
requires 'Net::Amazon::S3';
requires 'Catalyst::Plugin::UploadProgress';
requires 'DateTime';
requires 'Finance::Bitcoin' => '0.003';
requires 'Catalyst::Model::Bitcoin' => '0.02';
requires 'Imager' => '0.80';
requires 'Catalyst::Model::DBIC::Schema' => '0.59';

test_requires 'Test::More' => '0.88';
catalyst;

install_script glob('script/*.pl');
auto_install;
WriteAll;
