use strict;
use warnings;

use Test::More qw( no_plan );
use Test::Memory::Cycle;
use Linux::LVM2;
use Test::MockObject::Universal;

my $LVM2 = Linux::LVM2::->new( { 'logger' => Test::MockObject::Universal->new(), } );
$LVM2->vgs();
memory_cycle_ok($LVM2);
isa_ok( $LVM2, 'Linux::LVM2' );
can_ok( $LVM2, qw(vgs) );
