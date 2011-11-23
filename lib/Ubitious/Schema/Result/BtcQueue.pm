package Ubitious::Schema::Result::BtcQueue;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 NAME

Ubitious::Schema::Result::BtcQueue

=cut

__PACKAGE__->table("btc_queue");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 1

=head2 file_id

  data_type: 'integer'
  is_nullable: 1

=head2 expect_amount

  data_type: (empty string)
  is_nullable: 1

=head2 expect_address

  data_type: (empty string)
  is_nullable: 1

=head2 pay_amount

  data_type: (empty string)
  is_nullable: 1

=head2 pay_address

  data_type: (empty string)
  is_nullable: 1

=head2 created

  data_type: 'datetime'
  is_nullable: 1

=head2 processed

  data_type: 'datetime'
  is_nullable: 1

=head2 result

  data_type: 'text'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 1 },
  "file_id",
  { data_type => "integer", is_nullable => 1 },
  "expect_amount",
  { data_type => "", is_nullable => 1 },
  "expect_address",
  { data_type => "", is_nullable => 1 },
  "pay_amount",
  { data_type => "", is_nullable => 1 },
  "pay_address",
  { data_type => "", is_nullable => 1 },
  "created",
  { data_type => "datetime", is_nullable => 1 },
  "processed",
  { data_type => "datetime", is_nullable => 1 },
  "result",
  { data_type => "text", is_nullable => 1 },
);
__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07000 @ 2010-11-21 20:43:30
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:DurkX+yJcCHcAn6Nnv1vLw


# You can replace this text with custom content, and it will be preserved on regeneration

__PACKAGE__->belongs_to(
	"file" => "Ubitious::Schema::Result::File", "file_id"
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
