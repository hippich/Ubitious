package Ubitious::Model::DB;

use strict;
use base 'Catalyst::Model::DBIC::Schema';
use Net::Amazon::S3;
use Moose;
use Digest::SHA1;
use DateTime;
use Switch;
use Imager;

__PACKAGE__->config(
    schema_class => 'Ubitious::Schema',
);

has s3 => (is => 'rw');
has s3_client => (is => 'rw');
has bucket => (is => 'rw');

has aws_access_key_id => (is => 'rw');
has aws_secret_access_key => (is => 'rw');
has bucketname => (is => 'rw');

has ffmpegthumbnailer => (is => 'rw');

sub BUILD {
  my $self = shift;

  $self->s3( Net::Amazon::S3->new(
    {
      aws_access_key_id => $self->aws_access_key_id,
      aws_secret_access_key => $self->aws_secret_access_key,
      retry => 1,
    }
  ) );

  $self->s3_client( Net::Amazon::S3::Client->new(s3 => $self->s3) );
  $self->bucket( $self->s3_client->bucket( name => $self->bucketname ) );
}

sub insert_file {
  my ($self, $path, $filename, $type) = @_;

  # Add default mime content-type
  $type = 'application/octet-stream' unless $type;

  # Adding some stuff to generate nice SHA1 hash
  my $sha1 = Digest::SHA1->new;
  $sha1->add($path);
  $sha1->add($filename);
  $sha1->add(time);

  my $uniqueid = $sha1->hexdigest;
  my $object = $self->bucket->object( 
     key => $uniqueid .'/'. $filename,
     content_type => $type,
  );

  $object->put_filename($path);

  my $file = $self->resultset('File')->new({
      uniqueid => $uniqueid,
      filename => $filename,
      uploaded => DateTime->now(time_zone => 'UTC'),
      expire => DateTime->from_epoch( time_zone => 'UTC', epoch => time() + 3600 * 24 * 7 ),
      downloaded => 0,
    });
  
  $file->insert();

  $self->generate_thumbnails($file, $path);

  return $file;
}


sub generate_thumbnails {
  my ($self, $file, $path) = @_;

  # For now dumb detection of file type by its extension
  # @TODO: redo with mime detection

  my ($ext) = $file->filename =~ /\.([^\.]+)$/;
  my ($save_path) = $path =~ /^(.+\/)/;

  switch ($ext) {
    case (['flv', 'avi', 'mpg', 'mpeg']) {
      # generate thumbnails with ffmpeg
      foreach my $at (qw/1 50 99/) {
        my $screenshot_filename = $file->filename;
        $screenshot_filename =~ s/\.[^\.]+$//;
        $screenshot_filename .= '-' . $at .'.jpg';
        my $output_path = $save_path . $screenshot_filename;
        system $self->ffmpegthumbnailer .' -i '. $path .' -o '. $output_path .' -t ' . $at;
        $self->insert_dependency($file, $output_path);
        unlink $output_path;
      }
    };

    case (['jpeg', 'jpg', 'gif', 'png']) {
      # generate thumbnail with imagemagick
      my $img = Imager->new(file => $path) or die Imager->errstr();
      my $thumb = $img->scale(xpixels=>128, type=>'min');

      my $screenshot_filename = $file->filename;
      $screenshot_filename =~ s/\.[^\.]+$//;
      $screenshot_filename .= '-thumbnail.jpg';
      my $output_path = $save_path . $screenshot_filename;

      $thumb->write(file=>$output_path);

      $self->insert_dependency($file, $output_path);
      unlink $output_path;
    };
  }

  return $file;
};


sub insert_dependency {
  my ($self, $file, $dependency_path) = @_;

  my $dependency = $file->dependencies->new({});
  $dependency->insert();

  # Add default mime content-type
  my $type = 'application/octet-stream';

  my $dependency_filename = $file->filename;
  $dependency_filename =~ s/\.[^\.]+$//;

  $dependency_path =~ /([^\/]+)$/;
  $dependency_filename .= '-'. $1;

  my $object = $self->bucket->object(
    key => $file->uniqueid .'/'. $dependency_filename,
    content_type => $type,
    acl_short => 'public-read',
  );
  $object->put_filename($dependency_path);

  $dependency->filename($file->uniqueid .'/'. $dependency_filename);
  $dependency->update();

  return $dependency;
}

sub file_object_by_uid {
  my ($self, $uniqueid) = @_;

  my $file = $self->resultset('File')->search({ uniqueid => $uniqueid })->single;
  my $object = $self->bucket->object( key => $uniqueid ."/". $file->filename );

  return ($file, $object);
}

sub delete_file {
  my ($self, $uniqueid) = @_;

  my ($file, $object) = $self->file_object_by_uid($uniqueid);

  $self->delete_dependencies($file);

  $object->delete();
  return $file->delete();
}

sub delete_dependencies {
  my ($self, $file) = @_;

  foreach my $dependency ($file->dependencies->all) {
    my $dependency_object = $self->bucket->object( key => $dependency->filename );
    $dependency_object->delete();
  }
}

sub expire_file {
  my ($self, $uniqueid) = @_;

  my ($file, $object) = $self->file_object_by_uid($uniqueid);

  $file->expired(1);
  $file->update();

  $self->delete_dependencies($file);

  return $object->delete();
}

sub s3file {
  my ($self, $uniqueid) = @_;

  my $file = $self->resultset('File')->search({ uniqueid => $uniqueid })->single;
  my $object = $self->bucket->object( 
    key => $uniqueid ."/". $file->filename,
    expires => DateTime->from_epoch( time_zone => 'UTC', epoch => time() + 3600 * 6 ),
  );

  return $object;
}

sub url {
  my ($self, $uniqueid) = @_;

  my $object = $self->s3file($uniqueid);

  return $object->query_string_authentication_uri();
}


sub dependency_url {
  my ($self, $dependency) = @_;

  my $object = $self->bucket->object(
    key => $dependency->filename
  );

  return $object->uri();
};

=head1 NAME

Ubitious::Model::DB - Catalyst DBIC Schema Model

=head1 SYNOPSIS

See L<Ubitious>

=head1 DESCRIPTION

L<Catalyst::Model::DBIC::Schema> Model using schema L<Ubitious::Schema>

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

1;
