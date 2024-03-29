=encoding utf8

=head1 NAME

CInet::Cube::Polyhedral - Extend CInet::Cube

=head1 SYNOPSIS

    use CInet::Base;
    use CInet::Cube::Polyhedral; # extend CInet::Cube

    my $h = Cube(4)->h([1,2]); # unit vector in RR^{2^4}.
    my $Δ = Cube(4)->ci([1,4], [2,4]); # submodular inequality

=cut

# ABSTRACT: Extend CInet::Cube
package CInet::Cube::Polyhedral;

use Modern::Perl 2018;

use List::Util qw(uniq);
use Array::Set qw(set_union set_intersect);

use CInet::Cube;
use CInet::Imset;

=head1 DESCRIPTION

This class extends L<CInet::Cube> from the L<CInet::Base> package in the
following way.

=head2 Methods

=head3 h

    my $h = $cube->h($unit);

Creates a zero or unit L<CInet::Imset> on this cube. The C<$unit> argument
is optional but if given must be a subset of the ground set. This coordinate
of the returned imset is set to 1, all others to 0.

The C<$unit> arrayref is automatically deduplicated.

=cut

sub CInet::Cube::h {
    my $self = shift;
    my $unit = shift // [];
    CInet::Imset->new($self => [ [], [uniq $unit->@*] ])
}

=head3 ci

    my $Δ = $cube->ci($I, $J);
    my $δ = $cube->ci($ijK);

Each pair of sets C<$I> and C<$J> defines an instance of the submodular
inequality on an imset whose domain is C<$cube>, namely

    h(I) + h(J) - h(I ∪ J) - h(I ∩ J) ≥ 0

This is an inequality over a linear functional on the imset and the
C<< -> ci >> method returns the imset of coefficients of this functional.
Matúš uses the notation C<< Δ_{I,J} >> for this and Studený calls it
a semielementary imset.

When a single argument 2-face C<$ijK> is passed, the corresponding
elementary imset is returned, where C<I = i ∪ K> and C<J = j ∪ K>.

This method is called "ci" because equality in the submodular inequality
(so being on the hyperplane orthogonal to the returned imset) for an imset
which is proportional to an entropy vector characterizes conditional
independence in the backing probability distribution.

TODO: Also support the C<< Δ_{I,J|K} >> syntax where C<K> is subtracted
instead of C<IK ∩ JK>.

=cut

sub CInet::Cube::ci {
    my $self = shift;
    my ($I, $J) = @_;
    if (not defined $J) {
        my $ijK = $I;
        $I = set_union([$ijK->[0]->[0]], $ijK->[1]);
        $J = set_union([$ijK->[0]->[1]], $ijK->[1]);
    }
    $self->h($I) + $self->h($J) - $self->h(set_union($I, $J)) - $self->h(set_intersect($I, $J))
}

=head1 AUTHOR

Tobias Boege <tobs@taboege.de>

=head1 COPYRIGHT AND LICENSE

This software is copyright (C) 2020 by Tobias Boege.

This is free software; you can redistribute it and/or
modify it under the terms of the Artistic License 2.0.

=cut

":wq"
