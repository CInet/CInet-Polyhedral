=encoding utf8

=head1 NAME

CInet::Polyhedral - Building blocks for polyhedral geometry

=head1 SYNOPSIS

    # Imports all related modules
    use CInet::Polyhedral;

=head2 VERSION

This document describes CInet::Polyhedral v0.0.1.

=cut

# ABSTRACT: Building blocks for polyhedral geometry
package CInet::Polyhedral;

our $VERSION = "v0.0.1";

=head1 DESCRIPTION

TODO

=cut

use Modern::Perl 2018;
use Import::Into;

sub import {
    CInet::Cube::Polyhedral -> import::into(1);
    CInet::Imset            -> import::into(1);
}

=head1 AUTHOR

Tobias Boege <tobs@taboege.de>

=head1 COPYRIGHT AND LICENSE

This software is copyright (C) 2020 by Tobias Boege.

This is free software; you can redistribute it and/or
modify it under the terms of the Artistic License 2.0.

=cut

":wq"
