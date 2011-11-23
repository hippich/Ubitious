package Ubitious::Controller::Root;
use Moose;
use Data::Dumper;
use DateTime;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller' }

#
# Sets the actions in this controller to be registered with no prefix
# so they function identically to actions created in MyApp.pm
#
__PACKAGE__->config(namespace => '');

=head1 NAME

Ubitious::Controller::Root - Root Controller for Ubitious

=head1 DESCRIPTION

[enter your description here]

=head1 METHODS

=head2 index

The root page (/)

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->response->redirect( $c->uri_for("/file/upload") );
}


=head2 cron

The cron action. Do regular tasks. Should be scheduled by crontab

=cut

sub cron :Local {
  my ($self, $c) = @_;

  # Delete expired files
  my $files = $c->model("DB::File")->search({
      expire => { '<=', DateTime->now(time_zone => 'UTC')->strftime("%F %T") }, 
      expired => \"IS NULL",
  });

  while (my $file = $files->next) { 
    $c->log->debug("About to expire file ID: ". $file->id);
    $c->model("DB")->expire_file(
      $file->uniqueid,
    );
  } 

  my $queue = $c->model("DB::BtcQueue")->search({ processed => \"IS NULL" });

  while (my $item = $queue->next) {
    my $address = $c->model("Bitcoin")->find($item->expect_address);
    if ($address->received(6) >= $item->expect_amount) {
      my $response = $c->model("Bitcoin")->send_to_address($item->pay_address, $item->pay_amount);

      $item->processed(DateTime->now(time_zone => "UTC"));
      $item->result(
        "JSON Response: " . $response . "\n\n" .
        "Error: " . Dumper($c->model('Bitcoin')->api->error)
      );
      $item->update();
    }
  }

  $c->res->body("Done.");
}

=head2 default

Standard 404 error page

=cut

sub default :Path {
    my ( $self, $c ) = @_;
    $c->response->body( 'Page not found' );
    $c->response->status(404);
}

=head2 end

Attempt to render a view, if needed.

=cut

sub end : ActionClass('RenderView') {}

=head1 AUTHOR

Pavel Karoukin <pavel@karoukin.us>

=head1 LICENSE

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

=cut

__PACKAGE__->meta->make_immutable;

1;
