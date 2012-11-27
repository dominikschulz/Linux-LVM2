package Linux::LVM2::LV;
# ABSTRACT: a class representing a LV in a Linux LVM2

use 5.010_000;
use mro 'c3';
use feature ':5.10';

use Moose;
use namespace::autoclean;

# use IO::Handle;
# use autodie;
# use MooseX::Params::Validate;

=attr name

UNDOCUMENTED

=cut
has 'name' => (
    'is'       => 'ro',
    'isa'      => 'Str',
    'required' => 1,
);

=attr vg

UNDOCUMENTED

=cut
has 'vg' => (
    'is'       => 'ro',
    'isa'      => 'Linux::LVM2::VG',
    'required' => 1,
    'weak_ref' => 1,
);

=attr access

UNDOCUMENTED

=cut
has 'access' => (
    'is'       => 'rw',
    'isa'      => 'Int',
    'required' => 1,
);

=attr status

UNDOCUMENTED

=cut
has 'status' => (
    'is'       => 'rw',
    'isa'      => 'Int',
    'required' => 1,
);

=attr intlvnum

UNDOCUMENTED

=cut
has 'intlvnum' => (
    'is'       => 'rw',
    'isa'      => 'Int',
    'required' => 1,
);

=attr opencount

UNDOCUMENTED

=cut
has 'opencount' => (
    'is'       => 'rw',
    'isa'      => 'Int',
    'required' => 1,
);

=attr lvsize

UNDOCUMENTED

=cut
has 'lvsize' => (
    'is'       => 'rw',
    'isa'      => 'Int',
    'required' => 1,
);

=attr leassoc

UNDOCUMENTED

=cut
has 'leassoc' => (
    'is'       => 'rw',
    'isa'      => 'Int',
    'required' => 1,
);

=attr lealloc

UNDOCUMENTED

=cut
has 'lealloc' => (
    'is'       => 'rw',
    'isa'      => 'Int',
    'required' => 1,
);

=attr allocpol

UNDOCUMENTED

=cut
has 'allocpol' => (
    'is'       => 'rw',
    'isa'      => 'Int',
    'required' => 1,
);

=attr rasect

UNDOCUMENTED

=cut
has 'rasect' => (
    'is'       => 'rw',
    'isa'      => 'Int',
    'required' => 1,
);

=attr majornum

UNDOCUMENTED

=cut
has 'majornum' => (
    'is'       => 'rw',
    'isa'      => 'Int',
    'required' => 1,
);

=attr minornum

UNDOCUMENTED

=cut
has 'minornum' => (
    'is'       => 'rw',
    'isa'      => 'Int',
    'required' => 1,
);

=attr origin

UNDOCUMENTED

=cut
has 'origin' => (
    'is'  => 'rw',
    'isa' => 'Linux::LVM2::LV',
);

=attr snap_pc

UNDOCUMENTED

=cut
has 'snap_pc' => (
    'is'  => 'rw',
    'isa' => 'Int',
);

=attr move

UNDOCUMENTED

=cut
has 'move' => (
    'is'  => 'rw',
    'isa' => 'Str',    # ???
);

=attr log

UNDOCUMENTED

=cut
has 'log' => (
    'is'  => 'rw',
    'isa' => 'Str',    # ???
);

=attr copy_pc

UNDOCUMENTED

=cut
has 'copy_pc' => (
    'is'  => 'rw',
    'isa' => 'Int',
);

=attr convert

UNDOCUMENTED

=cut
has 'convert' => (
    'is'  => 'rw',
    'isa' => 'Str',    # ???
);

=attr mount_point

UNDOCUMENTED

=cut
has 'mount_point' => (
    'is'      => 'rw',
    'isa'     => 'Str',
    'default' => q{},
);

=attr fs_type

UNDOCUMENTED

=cut
has 'fs_type' => (
    'is'  => 'rw',
    'isa' => 'Str',
);

=attr fs_options

UNDOCUMENTED

=cut
has 'fs_options' => (
    'is'  => 'rw',
    'isa' => 'Str',
);

sub BUILD {
    my $self = shift;

    $self->vg()->lvs()->{ $self->name() } = $self;

    return 1;
}

sub full_path {
    my $self = shift;

    return '/dev/' . $self->vg()->name() . '/' . $self->name();
}

sub mapper_path {
    my $self = shift;

    my $vg = $self->vg()->name();
    $vg =~ s/(?<!-)-(?!-)/--/;
    my $lv = $self->name();
    $lv =~ s/(?<!-)-(?!-)/--/;
    return '/dev/mapper/' . $vg . '-' . $lv;
}

sub valid {
    my $self = shift;
    $self->vg()->update();
    if ( $self->snap_pc() < 100 ) {
        return 1;
    }
    else {
        return;
    }
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;

=head1 NAME

Linux::LVM2::LV - Model a logical-volume

=head1 SYNOPSIS

Instances of this class are usually created by Linux::LVM2::_find_vgs.

=method BUILD

Invoked by Moose on construction. Sets a reference to this object in our VG.

=method full_path

Returns the /dev/<vg>/<lv> path to the LV.

=method mapper_path

Returns the /dev/mapper/.. path to the LV.

=method valid

Returns true if the snapshot percentage of this LV is below 100%.

=cut
