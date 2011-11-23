package Ubitious::Schema::Result::File;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 NAME

Ubitious::Schema::Result::File

=cut

__PACKAGE__->table("files");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 1

=head2 uniqueid

  data_type: 'text'
  is_nullable: 1

=head2 type

  data_type: 'text'
  is_nullable: 1

=head2 filename

  data_type: 'text'
  is_nullable: 1

=head2 description

  data_type: 'text'
  is_nullable: 1

=head2 downloaded

  data_type: 'int'
  is_nullable: 1

=head2 uploaded

  data_type: 'datetime'
  is_nullable: 1

=head2 expire

  data_type: 'datetime'
  is_nullable: 1

=head2 payment_address

  data_type: 'text'
  is_nullable: 1

=head2 receive_address

  data_type: 'text'
  is_nullable: 1

=head2 price

  data_type: 'int'
  is_nullable: 1

=head2 expired

  data_type: 'int'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 1 },
  "uniqueid",
  { data_type => "text", is_nullable => 1 },
  "type",
  { data_type => "text", is_nullable => 1 },
  "filename",
  { data_type => "text", is_nullable => 1 },
  "description",
  { data_type => "text", is_nullable => 1 },
  "downloaded",
  { data_type => "int", is_nullable => 1 },
  "uploaded",
  { data_type => "datetime", is_nullable => 1 },
  "expire",
  { data_type => "datetime", is_nullable => 1 },
  "payment_address",
  { data_type => "text", is_nullable => 1 },
  "receive_address",
  { data_type => "text", is_nullable => 1 },
  "price",
  { data_type => "int", is_nullable => 1 },
  "expired",
  { data_type => "int", is_nullable => 1 },
);
__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07000 @ 2011-01-16 23:30:23
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:o84kANVo9aHg3DkYgznhUg


# You can replace this text with custom content, and it will be preserved on regeneration
__PACKAGE__->remove_column('downloaded');

__PACKAGE__->add_column(
  "downloaded" =>  { data_type => "int", is_nullable => 0, default_value => \'0' }
);

__PACKAGE__->has_many(
  "queue_items" => "Ubitious::Schema::Result::BtcQueue", "file_id"
);

__PACKAGE__->has_many(
  "dependencies" => "Ubitious::Schema::Result::Dependency", "file_id"
);

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
