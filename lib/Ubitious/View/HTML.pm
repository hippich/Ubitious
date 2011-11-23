package Ubitious::View::HTML;

use strict;
use warnings;

use base 'Catalyst::View::TT';

__PACKAGE__->config(
    TEMPLATE_EXTENSION => '.tt',
    render_die => 1,
    INCLUDE_PATH => [
      Ubitious->path_to('root','src'),
      Ubitious->path_to('root','lib'),
    ],
    WRAPPER => 'site/wrapper',
);

=head1 NAME

Ubitious::View::HTML - TT View for Ubitious

=head1 DESCRIPTION

TT View for Ubitious.

=head1 SEE ALSO

L<Ubitious>

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
