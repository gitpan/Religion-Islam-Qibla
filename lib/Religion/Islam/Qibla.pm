#=Copyright Infomation
#==========================================================
#Module Name      : Religion::Islam::Qibla
#Program Author   : Ahmed Amin Elsheshtawy
#Home Page          : http://www.islamware.com
#Contact Email      : support@islamware.com
#Copyrights © 2006 IslamWare. All rights reserved.
#==========================================================
#==========================================================
package Religion::Islam::Qibla;

use Carp;
use strict;
#use warnings;
use Exporter;

our @ISA = qw(Exporter);
our @EXPORT = qw();

our $VERSION = '1.01';

our $pi = 4 * atan2(1, 1),			# 3.1415926535897932;   # PI=22/7, Pi = Atn(1) * 4
our $DtoR = $pi / 180;				# Degree to Radians
our $RtoD = 180 / $pi;				# Radians to Degrees
#==========================================================
#==========================================================
sub new {
my ($class, %args) = @_;
    
	my $self = bless {}, $class;
	# Default destination point is the  Kabah Lat=21 Deg N, Long 40 Deg E
	$self->{DestLat} = $args{DestLat}? $args{DestLat}: 21;
	$self->{DestLong} = $args{DestLong}? $args{DestLong}: 40;
    return $self;
}
#==========================================================
sub DestLat {
my ($self) = shift; 
	$self->{DestLat} = shift if @_;
	return $self->{DestLat};
}
#==========================================================
sub DestLong {
my ($self) = shift; 
	$self->{DestLong} = shift if @_;
	return $self->{DestLong};
}
#==========================================================
#Inverse Cosine, ArcCos
sub acos {
my ($self, $x) = @_; 
	return ($x<-1 or $x>1) ? undef : (atan2(sqrt(1-$x*$x),$x) ); 
}
#==========================================================
 #Converting from Degrees, Minutes and Seconds to Decimal Degrees
sub DegreeToDecimal {
my ($self, $Degrees, $Minutes, $Seconds) = @_;
	return $Degrees + ($Minutes / 60) + ($Seconds / 3600);
}
#==========================================================
#Converting from Decimal Degrees to Degrees, Minutes and Seconds
sub DecimalToDegree {
my ($self, $DecimalDegree) = @_;
my ($Degrees, $Minutes, $Seconds, $ff);
     
    $Degrees = int($DecimalDegree);
    $ff = $DecimalDegree - $Degrees;
    $Minutes = int(60 * $ff);
    $Seconds = 60 * ((60 * $ff) - $Minutes);
	return ($Degrees, $Minutes, $Seconds);
}
#==========================================================
# The shortest distance between points 1 and 2 on the earth's surface is
# d = arccos{cos(Dlat) - [1 - cos(Dlong)]cos(lat1)cos(lat2)}
# Dlat = lab - lat2
# Dlong = 10ng• - long2
# lati, = latitude of point i
# longi, = longitude of point i

#Conversion of grad to degrees is as follows:
#Grad=400-degrees/0.9 or Degrees=0.9x(400-Grad)

#Latitude is determined by the earth's polar axis. Longitude is determined
#by the earth's rotation. If you can see the stars and have a sextant and
#a good clock set to Greenwich time, you can find your latitude and longitude.

# one nautical mile equals to:
#   6076.10 feet
#   2027 yards
#   1.852 kilometers
#   1.151 statute mile

# Calculates the distance between any two points on the Earth
sub  GreatCircleDistance {
my ($self, $OrigLat , $DestLat, $OrigLong, $DestLong) = @_;
my ($D, $L1, $L2, $I1, $I2);
    
    $L1 = $OrigLat * $DtoR;
    $L2 = $DestLat * $DtoR;
    $I1 = $OrigLong * $DtoR;
    $I2 = $DestLong * $DtoR;
    
    $D = $self->acos(cos($L1 - $L2) - (1 - cos($I1 - $I2)) * cos($L1) * cos($L2));
    # One degree of such an arc on the earth's surface is 60 international nautical miles NM
    return $D * 60 * $RtoD;
}
#==========================================================
#Calculates the direction from one point to another on the Earth
# a = arccos{[sin(lat2) - cos(d + lat1 - 1.5708)]/cos(lat1)/sin(d) + 1}
# Great Circle Bearing
sub GreatCircleDirection {
my ($self, $OrigLat, $DestLat, $OrigLong, $DestLong, $Distance) = @_;
my ($A, $B, $D, $L1, $L2, $I1, $I2, $Result, $Dlong);
    
	$L1 = $OrigLat * $DtoR;
	$L2 = $DestLat * $DtoR;
	$D = ($Distance / 60) * $DtoR; # divide by 60 for nautical miles NM to degree

	$I1 = $OrigLong * $DtoR;
	$I2 = $DestLong * $DtoR;
	$Dlong = $I1 - $I2;

	$A = sin($L2) - cos($D + $L1 - $pi / 2);
	$B = $self->acos($A / (cos($L1) * sin($D)) + 1);

	#If (Abs(Dlong) < pi And Dlong < 0) Or (Abs(Dlong) > pi And Dlong > 0) Then
	#        Result = (2 * pi) - B
	#Else
	#        Result = B
	#End If

	$Result = $B;
	return $Result * $RtoD;
}
#==========================================================
#The Equivalent Earth redius is 6,378.14 Kilometers.
# Calculates the direction of the Qibla from any point on
# the Earth From North Clocklwise
sub QiblaDirection {
my ($self, $OrigLat, $OrigLong) = @_;
my ($Distance, $Bearing);
    
	# Kabah Lat=21 Deg N, Long 40 Deg E
	$Distance = $self->GreatCircleDistance($OrigLat, $self->{DestLat}, $OrigLong, $self->{DestLong});
	$Bearing = $self->GreatCircleDirection($OrigLat, $self->{DestLat}, $OrigLong, $self->{DestLong}, $Distance);
	return $Bearing;
}
#==========================================================
#==========================================================

1;
__END__

=head1 NAME

Religion::Islam::Qibla - Calculates the Muslim Qiblah Direction, Great Circle Distance, and Great Circle Direction

=head1 SYNOPSIS

	use Religion::Islam::Qibla;
	#create new object with default options, Destination point is Kabah Lat=21 Deg N, Long 40 Deg E
	my $qibla = Religion::Islam::Qibla->new();
	
	# OR
	#create new object and set your destination point Latitude and/or  Longitude
	my $qibla = Religion::Islam::Qibla->new(DestLat => 21, DestLong => 40);
	
	# Calculate the Qibla direction From North Clocklwise for Cairo : Lat=30.1, Long=31.3
	my $Latitude = 30.1;
	my $Longitude = 31.3;
	my $QiblaDirection = $qibla->QiblaDirection($Latitude, $Longitude);
	print "The Qibla Direction for $Latitude and $Longitude From North Clocklwise is: " . $QiblaDirection ."\n";
	
	# Calculates the distance between any two points on the Earth
	my $OrigLat = 31; my $DestLat = 21; my $OrigLong = 31.3; $DestLong = 40;
	my $distance = $qibla->GreatCircleDistance($OrigLat , $DestLat, $OrigLong, $DestLong);
	print "The distance is: $distance \n";

	# Calculates the direction from one point to another on the Earth. Great Circle Bearing
	my $direction = $qibla->GreatCircleDirection($OrigLat, $DestLat, $OrigLong, $DestLong, $Distance);
	print "The direction is: $direction \n";
	
	# You can get and set the distination point Latitude and Longitude
	# $qibla->DestLat(21);		#	set distination Latitude
	# $qibla->DestLong(40);	# set distincatin Longitude
	print "Destination Latitude:" . $qibla->DestLat();
	print "Destination Longitude:" . $qibla->DestLong();

=head1 DESCRIPTION

This module calculates the Qibla direction where muslim prayers directs their face. It 
also calculates and uses the Great Circle Distance and Great Circle Direction.

=head1 SEE ALSO

L<Religion::Islam::PrayerTimes>
L<Religion::Islam::Quran>

=head1 AUTHOR

Ahmed Amin Elsheshtawy, E<lt>support@islamware.com<gt>
Website: http://www.islamware.com

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2006 by Ahmed Amin Elsheshtawy support@islamware.com,
L<http://www.islamware.com>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
