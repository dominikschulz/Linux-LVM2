package Linux::LVM2::Snapshot;
# ABSTRACT: a class representing a LV snapshot in an Linux LVM2

use 5.010_000;
use mro 'c3';
use feature ':5.10';

use Moose;
use namespace::autoclean;

# use IO::Handle;
# use autodie;
# use MooseX::Params::Validate;

use Carp;
use File::Temp;

use Sys::FS;
use Sys::Run;

=attr name

The name of this snapshot LV

=cut
has 'name' => (
    'is'      => 'ro',
    'isa'     => 'Str',
    'lazy'    => 1,
    'builder' => '_init_name',
);

=attr logger

An instance of Log::Tree

=cut
has 'logger' => (
    'is'       => 'rw',
    'isa'      => 'Log::Tree',
    'required' => 1,
);

=attr lv

The snapshot LV

=cut
has 'lv' => (
    'is'  => 'ro',
    'isa' => 'Linux::LVM2::LV',
);

=attr source

The snapshoted LV

=cut
has 'source' => (
    'is'       => 'ro',
    'isa'      => 'Linux::LVM2::LV',
    'required' => 1,
);

=attr parent

Our parent, must be an instance of Linux::LVM2

=cut
has 'parent' => (
    'is'       => 'ro',
    'isa'      => 'Linux::LVM2',
    'required' => 1,
);

=attr clear_caches

UNDOCUMENTED

=cut
has 'clear_caches' => (
    'is'      => 'ro',
    'isa'     => 'Bool',
    'default' => 0,
);

=attr snapspace

Use this much GB for the snapshot

=cut
has 'snapspace' => (
    'is'      => 'rw',
    'isa'     => 'Int',
    'default' => '5',     # GB
);

=attr mount_point

UNDOCUMENTED

=cut
has 'mount_point' => (
    'is'  => 'ro',
    'isa' => 'Str',
);

=attr verbose

UNDOCUMENTED

=cut
has 'verbose' => (
    'is'      => 'rw',
    'isa'     => 'Int',    # Bool
    'default' => 0,
);

=attr sys

UNDOCUMENTED

=cut
has 'sys' => (
    'is'      => 'rw',
    'isa'     => 'Sys::Run',
    'lazy'    => 1,
    'builder' => '_init_sys',
);

=attr fs

UNDOCUMENTED

=cut
has 'fs' => (
    'is'      => 'rw',
    'isa'     => 'Sys::FS',
    'lazy'    => 1,
    'builder' => '_init_fs',
);

has '_created_mount_point' => (
    'is'    => 'rw',
    'isa'   => 'Bool',
    'default' => 0,
);

sub _init_sys {
    my $self = shift;

    my $Sys = Sys::Run::->new( { 'logger' => $self->logger(), } );

    return $Sys;
}

sub _init_fs {
    my $self = shift;

    my $FS = Sys::FS::->new(
        {
            'logger' => $self->logger(),
            'sys'    => $self->sys(),
        }
    );

    return $FS;
}

sub full_path {
    my $self = shift;

    return $self->lv()->full_path();
}

sub mapper_path {
    my $self = shift;

    return $self->lv()->mapper_path();
}

sub BUILD {
    my $self = shift;

    # clear caches, free pagecache, dentries and inodes
    $self->sys()->clear_caches() if $self->clear_caches();

    # sync; sync; sync; lvcreate ...
    my $cmd =
        'sync; lvcreate -L'
      . $self->snapspace()
      . 'G --snapshot --name '
      . $self->name()
      . ' /dev/'
      . $self->source()->vg()->name() . '/'
      . $self->source()->name();
    if ( !$self->sys()->run_cmd( $cmd, { RaiseError => 1, Verbose => 1, } ) ) {
        my $msg = 'lvcreate failed. Could not create snapshot!';
        $self->logger()->log( message => $msg, level => 'error' );
        return;
    }

    # set our lv object
    $self->source()->vg()->update();
    if ( $self->source()->vg()->lvs()->{ $self->name() } && $self->source()->vg()->lvs()->{ $self->name() }->isa('Linux::LVM2::LV') ) {
        $self->{'lv'} = $self->source()->vg()->lvs()->{ $self->name() };
        $self->lv()->fs_type( $self->source()->fs_type() );
        $self->lv()->fs_options( $self->source()->fs_options() );
        return 1;
    }
    else {
        my $msg = 'LV ' . $self->name() . ' not found!';
        $self->logger()->log( message => $msg, level => 'error' );
        return;
    }
}

sub _init_name {
    my $self = shift;

    # finds a free replisnapname
    my $basename = 'replisnap';
    my $try      = 0;
    while ( $self->parent()->is_lv( $self->source()->vg()->name(), $basename . $try ) ) {
        $try++;

        # safety guard
        if ( $try > 1024 ) {
            my $msg = 'Could not find a free replisnap name within $try tries! Giving up.';
            $self->logger()->log( message => $msg, level => 'error' );
            return;
        }
    }

    # found an unused name for the
    # snapshot
    return $basename . $try;
}

sub mount {
    my $self        = shift;
    my $mount_point = shift;

    if ( !$mount_point || !-d $mount_point ) {
        $mount_point = File::Temp::tempdir( CLEANUP => 0 );
        $self->_created_mount_point(1);
    }

    if ( $self->fs()->mount( $self->full_path(), $mount_point, $self->lv()->fs_type(), 'ro,noatime', { Verbose => $self->verbose(), } ) ) {
        $self->{'mount_point'} = $mount_point;
        return $mount_point;
    }
    else {
        my $msg = 'Could not mount ' . $self->full_path() . ' at '.$mount_point;
        $self->logger()->log( message => $msg, level => 'error' );
        return;
    }
}

sub umount {
    my $self = shift;

    my $mounted_dev = $self->mapper_path();
    if ( !$self->fs()->is_mounted($mounted_dev) ) {
        $mounted_dev = $self->full_path();
        if ( !$self->fs()->is_mounted($mounted_dev) ) {
            my $msg = 'Tried to unmount snapshot (' . $self->full_path() . ') which does not appear to be mounted.';
            $self->logger()->log( message => $msg, level => 'warning' );
        }
    }
    else {
        my $msg = 'Trying to unmount device ' . $mounted_dev;
        $self->logger()->log( message => $msg, level => 'debug' );
        if ( $self->fs()->umount( $mounted_dev, ) ) {
            if($self->_created_mount_point()) {
                $self->sys()->run_cmd( 'rm -rf ' . $self->mount_point() );
            }
            $msg = 'Unmounted snapshot ' . $mounted_dev . ' from ' . $self->mount_point();
            $self->logger()->log( message => $msg, level => 'debug' );
            return 1;
        }
        else {
            $msg = 'Could not unmount ' . $mounted_dev;
            $self->logger()->log( message => $msg, level => 'error' );
        }
    }

    return;
}

sub remove {
    my $self = shift;

    $self->umount()
      or return;

    # remove it
    my $cmd = '/sbin/lvremove -f ' . $self->full_path();
    if ( $self->sys()->run_cmd( $cmd, { Verbose => $self->verbose(), } ) ) {
        my $msg = 'Removed snapshot LV ' . $self->full_path();
        $self->logger()->log( message => $msg, level => 'debug' );
        return 1;
    }
    else {
        my $msg = 'Failed to remove snapshot LV ' . $self->full_path();
        $self->logger()->log( message => $msg, level => 'debug' );
        return;
    }
}

sub DEMOLISH {
    my $self = shift;

    return $self->remove();
}

sub valid {
    my $self = shift;
    return $self->lv()->valid();
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 NAME

Linux::LVM2::Snapshot - Model a Snapshot LV.

=head1 SYNOPSIS

    use Linux::LVM2::Snapshot;
    my $Mod = Linux::LVM2::Snapshot::->new();

=head1 DESCRIPTION

This class models a snapshoted LV from an Linux LVM2 LV.

=method BUILD

Invoked by Moose on instantiation. Create the snapshot.

=method DEMOLISH

Invoked by Moose on destruction. Removes the snapshot.

=method full_path

Return the full path to this LV.

=method mapper_path

Return the dev-mapper path to this LV.

=method mount

Try to mount this LV snapshot to the given mount point.

=method remove

Try to unmount this LV, if mounted, and remove the LV afterwards.

=method umount

Try to unmount this LV.

=method valid

Returns true unless the snapshot is 100% full.

=cut

1; # End of Linux::LVM2::Snapshot
