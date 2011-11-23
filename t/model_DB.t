use strict;
use warnings;
use Test::More;

use lib "lib";

use Test::WWW::Mechanize;
use Ubitious;

BEGIN { use_ok 'Ubitious::Model::DB' }

my $c = Ubitious->new();
my $mech = Test::WWW::Mechanize->new;

my $file = $c->model('DB')->insert_file('README.txt', 'README.txt');
ok($file->uniqueid, "insert_file should succeed.");

my $url = $c->model('DB')->url($file->uniqueid);
$mech->get_ok($url);
$mech->content_contains('ubitious_server.pl', "Make sure correct file downloaded.");

my $dependency = $c->model('DB')->insert_dependency($file, 'README.txt');
ok($dependency->id, "insert_dependency should succeed.");

$url = $c->model('DB')->dependency_url($dependency);
$mech->get_ok($url);
$mech->content_contains('ubitious_server.pl', "Make sure correct dependency downloaded.");

ok($c->model('DB')->delete_file($file->uniqueid), "delete_file should succeed");


# Test video upload as well as thumbnailer
$file = $c->model('DB')->insert_file('t/files/morgana.flv', 'morgana.flv');
ok($file->uniqueid, "video insert should succeed.");

my @dependencies = $file->dependencies->all();

ok($#dependencies == 2, "Number of thumbnails should be equal 5.");

foreach my $dependency (@dependencies) {
  $url = $c->model('DB')->dependency_url($dependency);
  $mech->get_ok($url);
  $mech->content_contains('JFIF', "Make sure correct dependency downloaded.");
}

ok($c->model('DB')->delete_file($file->uniqueid), "delete_file should succeed");


# Test image upload
$file = $c->model('DB')->insert_file('t/files/image.jpg', 'image.jpg');
ok($file->uniqueid, "image insert should succeed.");

@dependencies = $file->dependencies->all();

ok($#dependencies == 0, "Number of thumbnails should be equal 1.");

foreach my $dependency (@dependencies) {
  $url = $c->model('DB')->dependency_url($dependency);
  $mech->get_ok($url);
  $mech->content_contains('JFIF', "Make sure correct dependency downloaded.");
}

ok($c->model('DB')->delete_file($file->uniqueid), "delete_file should succeed");

# Test file expiration. File and dependency should be removed from the S3 bucket.
# By now this should be checked manually.
$file = $c->model('DB')->insert_file('t/files/image.jpg', 'image.jpg');
ok($file->uniqueid, "image insert should succeed.");
ok($c->model('DB')->expire_file($file->uniqueid), "expire_file should succeed. Please check S3 bucket.");

done_testing();
