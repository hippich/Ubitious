package Ubitious::Controller::File;
use Moose;
use namespace::autoclean;

BEGIN {extends 'Catalyst::Controller::HTML::FormFu'; }

=head1 NAME

Ubitious::Controller::File - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->response->redirect( $c->uri_for('/file/upload') );
}

sub upload :Local :FormConfig {
  my ($self, $c) = @_;
  my $form = $c->stash->{form};

  if ($form->submitted_and_valid) {
    my $file = $c->model('DB')->insert_file(
      $c->req->upload('file')->tempname,
      $c->req->upload('file')->filename,
      $c->req->upload('file')->type,
    );

    push @{$c->flash->{messages}}, "File uploaded successfully.";
    $c->response->redirect( $c->uri_for('/file/edit/' . $file->uniqueid) );
  }
}


sub edit :Local :Args(1) :FormConfig {
  my ($self, $c, $uniqueid) = @_;
  my $file = $c->model('DB::File')->search({ uniqueid => $uniqueid })->single;

  if (! $file) {
    $c->detach("/default");
  }

  my $form = $c->stash->{form};

  # Generate file "invest" address if there is no one yet
  if (! $file->payment_address) {
    my $price = 2;  
    $file->payment_address( $c->model('Bitcoin')->get_new_address() );
    $file->price($price);
    $file->update();
  }

  my $address = $c->model('Bitcoin')->find($file->payment_address);
  my $received_amount = 0;
  
  if ($address) {
    $received_amount = $address->received(0);
    $c->stash->{address} = $address->address; 
  }

  $c->stash->{received_amount} = $received_amount;
  $c->stash->{file} = $file;

  # Check if user "invested" into file
  if ($received_amount * 100 > $file->price) {
    $file->price($received_amount * 100);
    $file->update();
  }

  # Process form
  if ($received_amount * 100 >= $file->price && $form->submitted_and_valid) {
    $file->description($form->param_value('description'));
    $file->receive_address($form->param_value('receive_address'));
    $file->update();

    push @{$c->stash->{messages}}, "Changes successfully saved.";
  }
  else {
    $form->get_field({name => 'description'})->value($file->description);
    $form->get_field({name => 'receive_address'})->value($file->receive_address);
  }
}


sub download :Local :Args(1) {
  my ($self, $c, $id) = @_;
  my $file = $c->model('DB::File')->find($id);

  if (! $file || $file->expired) {
    $c->detach("/default");
  }

  $c->stash->{file} = $file;

  if ($c->session->{files}[$id]{btc_address}) {
    my $address = $c->model('Bitcoin')->find(
      $c->session->{files}[$id]{btc_address}
    );

    my $received = $address->received(0);

    if ($received * 100 >= $file->price) {
      if ($file->receive_address && !$c->session->{files}[$id]{paid}) {
        $c->session->{files}[$id]{paid} = $received;

        my $pay_amount = sprintf('%.2f', $received * 0.7);

        if ($pay_amount < 0.01) {
          $pay_amount = 0.01;
        }

        my $queue_item = $file->add_to_queue_items({
          expect_amount => $received,
          expect_address => $address->address,
          pay_amount => $pay_amount,
          pay_address => $file->receive_address,  
          created => DateTime->now,
        });
      }

      # Increment number of downloads
      $file->update({ downloaded => \'downloaded + 1' })->discard_changes();

      # Add few hours to expiration field if someone downloaded file
      my $expire_delta = $file->expire->subtract_datetime_absolute(DateTime->now(time_zone => 'UTC'));

      $c->log->debug("Expiration delta: ". $expire_delta->delta_seconds ." seconds.");

      if ($expire_delta->delta_seconds < 3600*24*7) {
        $file->expire->add(
          seconds => 3600*24*7 - $expire_delta->delta_seconds,
        );
        $file->make_column_dirty("expire");
        $file->update();
      }

      my $url = $c->model('DB')->url( $file->uniqueid );

      $c->res->redirect($url);
    }
  }
  else {
    $c->session->{files}[$id]{btc_address} = $c->model('Bitcoin')->get_new_address();
  }

  $c->stash->{btc_address} = $c->session->{files}[$id]{btc_address};
  $c->stash->{price} = $file->price / 100;

  # Add thumbnails URLs into stash
  my @thumbnails = $file->dependencies->all();
  if ($#thumbnails >= 0) {
    foreach my $dep (@thumbnails) {
      push @{$c->stash->{thumbnails}}, $c->model('DB')->dependency_url($dep);
    }
  }
}

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
