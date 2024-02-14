=encoding utf8

=head1 NAME

CInet::Imset - Integer-valued multiset

=head1 SYNOPSIS

    my $cube = Cube(5);  # see L<CInet::Cube> and L<CInet::Cube::Polyhedral>
    # Create an imset with 1's in [1,3] and [2,3] and -1's in [1,2,3] and [3].
    my $Δ = $cube->ci([1,3], [2,3]);

=cut

# ABSTRACT: Integer-valued multiset
package CInet::Imset;

use Modern::Perl 2018;
use Carp;

=head1 DESCRIPTION

This class represents an integer-valued multiset (I<imset>) over a finite
ground set C<$N>. This maps every subset of C<$N> to an integer. In this
module, subsets of C<$N> are identified with C<< Cube($N)->vertices >>.

=head2 Methods

=cut

# Add a clone method
use parent 'Clone';

use overload (
    q[=]    => sub { shift->clone },
    q[bool] => sub { not shift->is_zero },
    q[+]    => \&_add,
    q[neg]  => \&_neg,
    q[-]    => \&_sub,
    q[*]    => \&_mul,
    q[""]   => \&_str,
);

=head3 new

    my $h = CInet::Imset->new($cube);
    my $h = CInet::Imset->new($cube, @elts);

Create a new CInet::Imset object. The first argument is the mandatory
L<CInet::Cube> instances which provides the ground set of the imset.
All other arguments are subsets of the ground set (encoded as arrayrefs)
which are set to C<1> in the returned imset.

=cut

# A cube must be given. All extra arguments are coordinates to set to 1.
sub new {
    my ($class, $cube, @elts) = @_;
    $cube = Cube($cube) unless $cube->isa('CInet::Cube');
    # $cube->pack indices are 1-based. We keep them 1-based and leave
    # the $cube at the zeroth index, for the future.
    my $v = [ $cube, map { 0 } 1 .. scalar($cube->vertices) ];
    # TODO: If $elt is not an arrayref, then it must be an integer and
    # be the value at the current (starting at 1) position to fill.
    for my $elt (@elts) {
        $v->[$cube->pack($elt)] = 1;
    }
    bless $v, $class
}

=head3 clone

  my $copy = $h->clone;

Creates a deep copy of the imset.

This method is inherited from L<Clone>.

=cut

=head3 is_zero

    my $bool = $h->is_zero;

Returns whether the imset is identically zero.

=cut

sub is_zero {
    my $v = shift;
    for my $i (keys @$v) {
        next unless $i;
        return 0 if $v->[$i] != 0;
    }
    return 1;
}

=head3 cube

    my $cube = $h->cube;

Returns the C<$cube> the imset was created with.

=cut

sub cube {
    shift->[0]
}

=head3 val

    my $v = $h->val($K);

Return the integer C<$v> associated with the subset C<$K>.

=cut

sub val {
    my ($self, $K) = @_;
    $self->[ $self->cube->pack([ [], $K ]) ]
}

=head3 ci

    my $bool = $h->ci($ijK);

Given a 2-face C<(ij|K)> of C<< $h->cube >>, return whether C<$h> is
modular at C<(ij|K)>, i.e., whether it satisfies

    h(iK) + h(jK) == h(ijK) + h(K).

This is the definition of conditional independence C<i ⫫ j | K> for
an imset.

=cut

sub ci {
    my ($self, $ijK) = @_;
    my $cube = $self->[0];
    $self * $cube->ci($ijK) == 0
}

=head3 relation

    my $A = $h->relation;

Return the L<CInet::Relation> associated to this imset by repeatedly
calling L<ci|/"ci">.

=cut

sub relation {
    my $self = shift;
    my $cube = $self->[0];
    my $rel = join '', map { $self->ci($_) ? '0' : '1' } $cube->squares;
    CInet::Relation->new($cube, $rel)
}

=head3 permute

    my $hp = $h->permute($p);

Given a permutation C<$p> of the ground set (in one-line notation),
return the permuted imset which exists over the same C<$cube>.

=cut

sub permute {
    my ($self, $p) = @_;
    my $new = $self->clone;
    my $cube = $new->[0];
    for my $I ($cube->vertices) {
        my $i = $cube->pack($I);
        my $j = $cube->pack($cube->permute($p => $I));
        $new->[$j] = $self->[$i];
    }
    $new
}

=head3 co

    my $hc = $h->co;

Return the co-imset of C<$h> which at a subset C<$K> takes the value
which C<$h> takes at the complement of C<$K>.

=cut

sub co {
    my $self = @_;
    my $new = $self->clone;
    my $cube = $new->[0];
    for my $I ($cube->vertices) {
        my $i = $cube->pack($I);
        my $j = $cube->pack($cube->dual($I));
        $new->[$j] = $self->[$i];
    }
    $new
}

=head3

    my $hZ = $h->swap($Z);

Apply a swap of the ground set to the relation. The resulting imset
exists over the same C<$cube> and contains exactly the images of the
invocant's squares under the C<< $cube->swap >> method.

=cut

sub swap {
    my ($self, $Z) = @_;
    my $new = $self->clone;
    my $cube = $new->[0];
    for my $I ($cube->vertices) {
        my $i = $cube->pack($I);
        my $j = $cube->pack($cube->swap($Z => $I));
        $new->[$j] = $self->[$i];
    }
    $new
}

=head3 to_string

    my $str = $h->to_string;

Stringify the imset. The result is a space-separated string of the
integer values, in the order of C<< $cube->vertices >>.

=cut

sub to_string {
    shift->_str
}

=head2 Overloaded operators

=cut

=head3 Addition

    my $f = $g + $h;

Add imsets over the same cube element-wise.

=cut

sub _add {
    my ($v, $w, $swap) = @_;

    my $u = $v->clone;
    for my $i (keys @$w) {
        next unless $i;
        $u->[$i] += $w->[$i];
    }
    $u
}

=head3 Unary negation

    my $mh = -$h;

Negate the imset element-wise.

=cut

sub _neg {
    my $u = shift->clone;
    for my $i (keys @$u) {
        next unless $i;
        $u->[$i] = - $u->[$i];
    }
    $u
}

=head3 Subtraction

    my $f = $g - $h;

The inverse of addition.

=cut

sub _sub {
    my ($v, $w, $swap) = @_;

    my $u = $v->clone;
    for my $i (keys @$w) {
        next unless $i;
        $u->[$i] -= $w->[$i];
    }
    $u
}

=head3 Multiplication

    my $v = $g * $h;
    my $hc = $c * $h;

If both operands are imsets, then the operation performed is the scalar
product of them and the result is a scalar. If one operand is a scalar,
then it scales the imset element-wise and the result is an imset over
the same cube.

=cut

sub _mul {
    my ($v, $w, $swap) = @_;
    ($v, $w) = ($w, $v) if $swap;

    # Inner product
    if ($v->isa('CInet::Imset')) {
        my $d = 0;
        for my $i (keys @$v) {
            next unless $i;
            $d += $v->[$i] * $w->[$i];
        }
        return $d
    }
    # Scaling
    else {
        my $u = $w->clone;
        for my $i (keys @$w) {
            next unless $i;
            $u->[$i] = $v * $w->[$i];
        }
        return $u;
    }
}

=head3 Stringification

    my $str = "$h";

Stringify an imset, cf. L<to_string|/"to_string">.

=cut

sub _str {
    my $v = shift;
    join ' ', $v->@[1 .. $v->$#*]
}

=head1 AUTHOR

Tobias Boege <tobs@taboege.de>

=head1 COPYRIGHT AND LICENSE

This software is copyright (C) 2020 by Tobias Boege.

This is free software; you can redistribute it and/or
modify it under the terms of the Artistic License 2.0.

=cut

":wq"
