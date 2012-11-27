package Linux::LVM2::VG;
# ABSTRACT: a class representing an VG in a Linux LVM2

use 5.010_000;
use mro 'c3';
use feature ':5.10';

use Moose;
use namespace::autoclean;

# use IO::Handle;
# use autodie;
# use MooseX::Params::Validate;

=attr parent

Our parent node, must be an instance of Linux::LVM2

=cut
has 'parent' => (
    'is'       => 'ro',
    'isa'      => 'Linux::LVM2',
    'required' => 1,
    'weak_ref' => 1,
);

=attr name

The name of this VG.

=cut
has 'name' => (
    'is'       => 'ro',
    'isa'      => 'Str',
    'required' => 1,
);

=attr access

UNDOCUMENTED

=cut
has 'access' => (
    'is'       => 'rw',
    'isa'      => 'Str',
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

=attr vgid

UNDOCUMENTED

=cut
has 'vgid' => (
    'is'       => 'ro',
    'isa'      => 'Int',
    'required' => 1,
);

=attr maxlvs

UNDOCUMENTED

=cut
has 'maxlvs' => (
    'is'       => 'ro',
    'isa'      => 'Int',
    'required' => 1,
);

=attr curlvs

UNDOCUMENTED

=cut
has 'curlvs' => (
    'is'       => 'rw',
    'isa'      => 'Int',
    'required' => 1,
);

=attr openlvs

UNDOCUMENTED

=cut
has 'openlvs' => (
    'is'       => 'rw',
    'isa'      => 'Int',
    'required' => 1,
);

=attr maxlvsize

UNDOCUMENTED

=cut
has 'maxlvsize' => (
    'is'       => 'ro',
    'isa'      => 'Int',
    'required' => 1,
);

=attr maxpvs

UNDOCUMENTED

=cut
has 'maxpvs' => (
    'is'       => 'ro',
    'isa'      => 'Int',
    'required' => 1,
);

=attr curpvs

UNDOCUMENTED

=cut
has 'curpvs' => (
    'is'       => 'rw',
    'isa'      => 'Int',
    'required' => 1,
);

=attr numpvs

UNDOCUMENTED

=cut
has 'numpvs' => (
    'is'       => 'rw',
    'isa'      => 'Int',
    'required' => 1,
);

=attr vgsize

UNDOCUMENTED

=cut
has 'vgsize' => (
    'is'       => 'rw',
    'isa'      => 'Int',
    'required' => 1,
);

=attr pesize

UNDOCUMENTED

=cut
has 'pesize' => (
    'is'       => 'rw',
    'isa'      => 'Int',
    'required' => 1,
);

=attr totalpe

UNDOCUMENTED

=cut
has 'totalpe' => (
    'is'       => 'rw',
    'isa'      => 'Int',
    'required' => 1,
);

=attr allocpe

UNDOCUMENTED

=cut
has 'allocpe' => (
    'is'       => 'rw',
    'isa'      => 'Int',
    'required' => 1,
);

=attr freepe

UNDOCUMENTED

=cut
has 'freepe' => (
    'is'       => 'rw',
    'isa'      => 'Int',
    'required' => 1,
);

=attr uuid

UNDOCUMENTED

=cut
has 'uuid' => (
    'is'       => 'rw',
    'isa'      => 'Str',
    'required' => 1,
);

=attr pvs

UNDOCUMENTED

=cut
has 'pvs' => (
    'is'      => 'rw',
    'isa'     => 'HashRef[Linux::LVM2::PV]',
    'default' => sub { {} },
);

=attr lvs

UNDOCUMENTED

=cut
has 'lvs' => (
    'is'      => 'rw',
    'isa'     => 'HashRef[Linux::LVM2::LV]',
    'default' => sub { {} },
);

sub update {
    my $self = shift;
    $self->parent()->update();
    return 1;
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 NAME

Linux::LVM2::VG - Model a LVM2 volume-group.

=head1 SYNOPSIS

Instances of this class are usually create by Linux::LVM2::_find_vgs.

=head1 DESCRIPTION

This clas models a volume-group inside a Linux LVM2 setup.

=method update

Synchronize the model with the underlying data structures.

=cut

1; # End of Linux::LVM2::VG
