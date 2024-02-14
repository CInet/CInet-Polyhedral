=encoding utf8

=head1 NAME

CInet::Polyhedral - Building blocks for polyhedral geometry

=head1 SYNOPSIS

    # Imports all related modules
    use CInet::Polyhedral;

=head2 VERSION

This document describes CInet::Polyhedral v0.1.0.

=cut

# ABSTRACT: Building blocks for polyhedral geometry
package CInet::Polyhedral;

our $VERSION = "v0.1.0";

=head1 DESCRIPTION

This module provides access to software for polyhedral geometry,
in particular to a linear programming solver. Linear programming is known
to apply to conditional independence through concepts such as polymatroids
and structural semigraphoids.

The main object of this module is a L<CInet::Imset>. An I<imset> is an
B<i>nteger-valued B<m>ultiB<set>. It associates to each subset of a given
set C<N> an integer number. Studený uses imsets in the theory of conditional
independence structures to describe information inequalities, that is linear
inequalities with integer coefficients on the cone on multiinformation
functions, the faces of which correspond to CI structures. The work of
Matúš studies dually integer polymatroids, which are abstractions of
entropies or multiinformation functions, which can also be written as
imsets. Each imset requires a L<CInet::Cube> domain over which (that
is over whose vertices) it is defined.

In the future, syntactic sugar similar to L<CInet::Propositional> will
be provided to write down linear programs for CI purposes clearly and
quickly. Based on this, objects and methods will be added which expose
the link between polyhedral geometry and CI implication but also blend
in with the interface of L<CInet::Base>.

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
