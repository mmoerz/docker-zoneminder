# Retrieved from:
# https://forums.zoneminder.com/viewtopic.php?f=36&t=27093&p=105704#p105188
# ==========================================================================
#
# ZoneMinder Acrest 781 IP Control Protocol Module, 20160101, Rev2
# Changes from Rev1:
# Fixed installation instructions text, no changes to functionality.
# Copyright (C) 2016 Herndon Elliott
# alabamatoy at gmail dot com
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
#
# ==========================================================================
#
package ZoneMinder::Control::amcrest841;

use 5.006;
use strict;
use warnings;

use Time::HiRes qw( usleep );

require ZoneMinder::Base;
require ZoneMinder::Control;

our @ISA = qw(ZoneMinder::Control);

# ==========================================================================
#
# Amcrest 781 IP Control Protocol
#
# ==========================================================================

use ZoneMinder::Logger qw(:all);
use ZoneMinder::Config qw(:all);

sub new
{
    my $class = shift;
    my $id = shift;
    my $self = ZoneMinder::Control->new( $id );
    bless( $self, $class );
    srand( time() );
    return $self;
}

our $AUTOLOAD;

sub AUTOLOAD
{
    my $self = shift;
    my $class = ref($self) || croak( "$self not object" );
    my $name = $AUTOLOAD;
    $name =~ s/.*://;
    if ( exists($self->{$name}) )
    {
        return( $self->{$name} );
    }
    Fatal( "Can't access $name member of object of class $class" );
}

sub open
{
    my $self = shift;

    $self->loadMonitor();
    $self->{state} = 'open';
}

sub initUA
{
    my $self = shift;
    my $user = undef;
    my $password = undef;
    my $address = undef;

    if ( $self->{Monitor}->{ControlAddress} =~ /(.*):(.*)@(.*)/ )
    {
      $user = $1;
      $password = $2;
      $address = $3;
    }

    use LWP::UserAgent;
    $self->{ua} = LWP::UserAgent->new;
    $self->{ua}->credentials("$address", "Login to " . $self->{Monitor}->{ControlDevice}, "$user", "$password");
    $self->{ua}->agent( "ZoneMinder Control Agent/".ZoneMinder::Base::ZM_VERSION );
}

sub destroyUA
{
    my $self = shift;

    $self->{ua} = undef;
}

sub close
{
    my $self = shift;
    $self->{state} = 'closed';
}

sub printMsg
{
    my $self = shift;
    my $msg = shift;
    my $msg_len = length($msg);

    Debug( $msg."[".$msg_len."]" );
}

sub sendCmd
{
    my $self = shift;
    my $cmd = shift;
    my $result = undef;

    destroyUA($self);
    initUA($self);

    my $user = undef;
    my $password = undef;
    my $address = undef;

    if ( $self->{Monitor}->{ControlAddress} =~ /(.*):(.*)@(.*)/ )
    {
      $user = $1;
      $password = $2;
      $address = $3;
    }

    printMsg( $cmd, "Tx" );

    my $req = HTTP::Request->new( GET=>"http://$address/$cmd" );
    my $res = $self->{ua}->request($req);

    if ( $res->is_success )
    {
        $result = !undef;
        # Command to camera appears successful, write Info item to log
        Info( "Camera control: '".$res->status_line()."' for URL ".$self->{Monitor}->{ControlAddress}."/$cmd" );
    }
    else
    {
        Error( "Camera control command FAILED: '".$res->status_line()."' for URL ".$self->{Monitor}->{ControlAddress}."/$cmd" );
    }

    #&close;

    return( $result );
}

sub reset
{
    my $self = shift;
    Debug( "Camera Reset" );
    # This does NOT reset the camera, it resets the script, forcing
    # ZM to reread it.
    Exit (0);
}

#Up Arrow
sub Up
{
    my $self = shift;
    Debug( "Move Up" );
    $self->sendCmd( 'cgi-bin/ptz.cgi?action=start&code=Up&channel=0&arg1=0&arg2=1&arg3=0' );
    usleep (500);
    $self->sendCmd( 'cgi-bin/ptz.cgi?action=stop&code=Up&channel=0&arg1=0&arg2=1&arg3=0' );
}

#Down Arrow
sub Down
{
    my $self = shift;
    Debug( "Move Down" );
    $self->sendCmd( 'cgi-bin/ptz.cgi?action=start&code=Down&channel=0&arg1=0&arg2=1&arg3=0' );
    usleep (500);
    $self->sendCmd( 'cgi-bin/ptz.cgi?action=stop&code=Down&channel=0&arg1=0&arg2=1&arg3=0' );
}

#Left Arrow
sub Left
{
    my $self = shift;
    Debug( "Move Left" );
    $self->sendCmd( 'cgi-bin/ptz.cgi?action=start&code=Left&channel=0&arg1=0&arg2=1&arg3=0' );
    usleep (500);
    $self->sendCmd( 'cgi-bin/ptz.cgi?action=stop&code=Left&channel=0&arg1=0&arg2=1&arg3=0' );
}

#Right Arrow
sub Right
{
    my $self = shift;
    Debug( "Move Right" );
#    $self->sendCmd( 'cgi-bin/ptz.cgi?action=start&code=PositionABS&channel=0&arg1=270&arg2=5&arg3=0' );
    $self->sendCmd( 'cgi-bin/ptz.cgi?action=start&code=Right&channel=0&arg1=0&arg2=1&arg3=0' );
    usleep (500);
    Debug( "Move Right Stop" );
    $self->sendCmd( 'cgi-bin/ptz.cgi?action=stop&code=Right&channel=0&arg1=0&arg2=1&arg3=0' );
}

#Diagonally Up Right Arrow
sub UpRight
{
    my $self = shift;
    Debug( "Move Diagonally Up Right" );
    $self->sendCmd( 'cgi-bin/ptz.cgi?action=start&code=RightUp&channel=0&arg1=1&arg2=1&arg3=0' );
    usleep (500);
    $self->sendCmd( 'cgi-bin/ptz.cgi?action=stop&code=RightUp&channel=0&arg1=0&arg2=1&arg3=0' );
}

#Diagonally Down Right Arrow
sub DownRight
{
    my $self = shift;
    Debug( "Move Diagonally Down Right" );
    $self->sendCmd( 'cgi-bin/ptz.cgi?action=start&code=RightDown&channel=0&arg1=1&arg2=1&arg3=0' );
    usleep (500);
    $self->sendCmd( 'cgi-bin/ptz.cgi?action=stop&code=RightDown&channel=0&arg1=0&arg2=1&arg3=0' );
}

#Diagonally Up Left Arrow
sub UpLeft
{
    my $self = shift;
    Debug( "Move Diagonally Up Left" );
    $self->sendCmd( 'cgi-bin/ptz.cgi?action=start&code=LeftUp&channel=0&arg1=1&arg2=1&arg3=0' );
    usleep (500);
    $self->sendCmd( 'cgi-bin/ptz.cgi?action=stop&code=LeftUp&channel=0&arg1=0&arg2=1&arg3=0' );
}

#Diagonally Down Left Arrow
sub DownLeft
{
    my $self = shift;
    Debug( "Move Diagonally Down Left" );
    $self->sendCmd( 'cgi-bin/ptz.cgi?action=start&code=LeftDown&channel=0&arg1=1&arg2=1&arg3=0' );
    usleep (500);
    $self->sendCmd( 'cgi-bin/ptz.cgi?action=stop&code=LeftDown&channel=0&arg1=0&arg2=1&arg3=0' );
}

#Stop - not correctly implemented
sub moveStop
{
    my $self = shift;
    Debug( "Move Stop" );
    $self->sendCmd( 'cgi-bin/ptz.cgi?action=stop&code=Right&channel=0&arg1=0&arg2=0&arg3=0&arg4=0' );
}

#Move Camera to Home Position - not implemented, sorry
#sub presetHome
#{
#    my $self = shift;
#    Debug( "Home Preset" );
#    $self->sendCmd( 'decoder_control.cgi?command=25&' );
#}

sub presetGoto
{
    my $self = shift;
    my $params = shift;
    my $preset = $self->getParam( $params, 'preset' );
    Debug( "Go To Preset 1" );
    $self->sendCmd( 'cgi-bin/ptz.cgi?action=start&channel=0&code=GotoPreset&&arg1=0&arg2='.$preset.'&arg3=0&arg4=0' );
}

sub presetSet
{
    my $self = shift;
    my $params = shift;
    my $preset = $self->getParam( $params, 'preset' );
    Debug( "Set Preset" );
    $self->sendCmd( 'cgi-bin/ptz.cgi?action=start&channel=0&code=SetPreset&arg1=0&arg2='.$preset.'&arg3=0&arg4=0' );
}

sub moveMap
{
    my $self = shift;
    my $params = shift;

    my $xcoord = $self->getParam( $params, 'xcoord', $self->{Monitor}{Width}/2 );
    my $ycoord = $self->getParam( $params, 'ycoord', $self->{Monitor}{Height}/2 );
    # if the camera is mounted upside down, you may have to inverse these coordinates
    # just use 360 minus pan instead of pan, 90 minus tilt instead of tilt
    # Convert xcoord into pan position 0 to 359
    my $pan = int(360 * $xcoord / $self->{Monitor}{Width});
    # Convert ycoord into tilt position 0 to 89
    my $tilt = 90 - int(90 * $ycoord / $self->{Monitor}{Height});
    # Now get the following url:
    $self->sendCmd( 'cgi-bin/ptz.cgi?action=start&code=PositionABS&channel=0&arg1='.$pan.'&arg2='.$tilt.'&arg3=1&arg4=1');
}

sub Tele
{
    my $self = shift;
    Debug( "Set Zoom" );
    $self->sendCmd( 'cgi-bin/ptz.cgi?action=start&channel=0&code=ZoomTele&arg1=0&arg2=0&arg3=0&arg4=0' );
    usleep (100000);
    $self->sendCmd( 'cgi-bin/ptz.cgi?action=stop&channel=0&code=ZoomTele&arg1=0&arg2=0&arg3=0&arg4=0' );
}

sub Wide
{
    my $self = shift;
    #my $params = shift;
    #my $preset = $self->getParam( $params, 'preset' );
    Debug( "Set Zoom" );
    $self->sendCmd( 'cgi-bin/ptz.cgi?action=start&channel=0&code=ZoomWide&arg1=0&arg2=0&arg3=0&arg4=0' );
}

1;

__END__
=pod

=head1 NAME

ZoneMinder::Control::amcrest841 - Amcrest camera control

=head1 DESCRIPTION

This module contains the implementation of the Amcrest Camera
controllable SDK API.  It implements only the pan and tilt functions.  The
Amcrest HTTP API SDK is available here:
https://support.amcrest.com/hc/en-us/article_attachments/215199368/AMCREST_HTTP_API_SDK_V2.10.pdf

NOTE: This module implements interaction with the camera in clear text.
I have not been able to get around this.  The login and password are
transmitted from ZM to the camera in clear text, and as such, this module
should be used ONLY on a blind LAN implementation where interception of the
packets is very low risk.

Copy the file amcrest781.pm to /usr/share/perl5/ZoneMinder/Control folder.
This is where it belongs in Ubuntu 16.04, your setup may be different.

Next, in the camera monitor, under the control tab, select "Controllable".

Select "edit" beside the "Control Type" text box, and a new window will open,
click on "ADD NEW CONTROL" and give it whatever name you want, I used
"Amcrest 781".  Select "TYPE as "Remote" and "PROTOCOL" as "amcrest781".
Select "CAN RESET".  Under the "Move" tab, select "CAN MOVE, "CAN MOVE
DIAGONALLY" and "CAN MOVE MAPPED".  Under the "Pan" tab, select "CAN PAN".
Under the "Tilt" tab, select "CAN TILT". Under the "Zoom" tab, select
"CAN ZOOM".  Under "Presets" tab, select "HAS PRESETS", I used 3 for num
presets, but your camera documentation should tell
you how many you actually can have, also select "CAN SET PRESETS".  The Amcrest
documentation linked above indicates no home preset, so that is not implemented,
don't select it.  Click on "SAVE" at the bottom.  You should have a new control
capability listed with whatever name you gave it.

Set "Control Type" to whatever you named the new control.  This choice
should be listed as one available in the pulldown.

Set "Control Address" to "login:password@ip_address:port" where login is your
camera login, password is your camera password, and ip_address is the camera
IP.  Port is required by the digest authentication.  Please be mindful of NOTE
above.

Set "Control Device" to be the camera's serial number string.  This will be
appended to the string "Login to " to form the realm used by the digest
authentication.  It can be found on the Information -> Version tab when you
login to the camera.

Save the monitor.

Open the camera and you should see a hyperlinked word "control" above the
camera display.  Click on that, and you should get a rose of controls below
the camera image.  You can also click on the image itself to make gross
adjustments.

The "usleep (X);" lines throughout the script may need adjustments for your
situation.  This is the time that the script waits between sending a "start"
and a "stop" signal to the camera.  For example, the pan left arrow would
result in the camera panning full to its leftmost position if there were no
stop signal.  So the usleep time sets how long the script waits to allow the
camera to start moving before issuing a stop.  The X value of usleep is in
microseconds, so "usleep (100000);" is equivalent to wait one second.

=cut
