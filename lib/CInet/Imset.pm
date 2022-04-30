=encoding utf8

=head1 NAME

CInet::Imset - Integer-valued multiset

=head1 SYNOPSIS

    my $cube = Cube(5);  # see L<CInet::Cube>
    my $h = $cube->ci();

=cut

# ABSTRACT: Integer-valued multiset
package CInet::Imset;

use Modern::Perl 2018;
use Carp;

=head1 DESCRIPTION

=head2 Methods

=head3 clone

  my $copy = $h->clone;

Creates a deep copy of the imset.

This method is inherited from L<Clone>.

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

sub is_zero {
    my $v = shift;
    for my $i (keys @$v) {
        next unless $i;
        return 0 if $v->[$i] != 0;
    }
    return 1;
}

sub cube {
    shift->[0]
}

sub ci {
    my ($self, $ijK) = @_;
    my $cube = $self->[0];
    $self * $cube->ci($ijK) == 0
}

sub relation {
    my $self = shift;
    my $cube = $self->[0];
    my $rel = join '', map { $self->ci($_) ? '0' : '1' } $cube->squares;
    CInet::Relation->new($cube, $rel)
}

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

sub dual {
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

sub to_string {
    shift->_str
}

=head2 Overloaded operators

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

sub _neg {
    my $u = shift->clone;
    for my $i (keys @$u) {
        next unless $i;
        $u->[$i] = - $u->[$i];
    }
    $u
}

sub _sub {
    my ($v, $w, $swap) = @_;

    my $u = $v->clone;
    for my $i (keys @$w) {
        next unless $i;
        $u->[$i] -= $w->[$i];
    }
    $u
}

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
