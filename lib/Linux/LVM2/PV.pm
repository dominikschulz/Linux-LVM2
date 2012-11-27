package Linux::LVM2::PV;
# ABSTRACT: a class representing a PV in a Linux LVM2

use 5.010_000;
use mro 'c3';
use feature ':5.10';

use Moose;
use namespace::autoclean;

# use IO::Handle;
# use autodie;
# use MooseX::Params::Validate;

=attr name

The name of this PV

=cut
has 'name' => (
    'is'       => 'ro',
    'isa'      => 'Str',
    'required' => 1,
);

=attr vg

The VG that is using this PV

=cut
has 'vg' => (
    'is'       => 'ro',
    'isa'      => 'Linux::LVM2::VG',
    'required' => 1,
    'weak_ref' => 1,
);

=attr size

The size of this PV

=cut
has 'size' => (
    'is'       => 'ro',
    'isa'      => 'Int',
    'required' => 1,
);

=attr pesize

UNDOCUMENTED

=cut
has 'pesize' => (
    'is'       => 'ro',
    'isa'      => 'Int',
    'required' => 1,
);

=attr totalpe

UNDOCUMENTED

=cut
has 'totalpe' => (
    'is'       => 'ro',
    'isa'      => 'Int',
    'required' => 1,
);

=attr freepe

UNDOCUMENTED

=cut
has 'freepe' => (
    'is'       => 'ro',
    'isa'      => 'Int',
    'required' => 1,
);

=attr allocpe

UNDOCUMENTED

=cut
has 'allocpe' => (
    'is'       => 'ro',
    'isa'      => 'Int',
    'required' => 1,
);

=attr uuid

UNDOCUMENTED

=cut
has 'uuid' => (
    'is'       => 'ro',
    'isa'      => 'Str',
    'required' => 1,
);

sub BUILD {
    my $self = shift;

    $self->vg()->pvs()->{ $self->name() } = $self;

    return 1;
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;

__END__


=head1 NAME

Linux::LVM2::PV - Model a physical-volume.

=head1 SYNOPSIS

Instances of this class are usually create by Linux::LVM2::_find_vgs.

=head1 DESCRIPTION

This class models a physical-volume inside a Linux LVM2 setup.

=method BUILD

Invoked by Moose on instantiation. Sets a reference to this class in our parent
VG.

=cut
