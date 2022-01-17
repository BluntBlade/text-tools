#!/usr/bin/env perl

use strict;
use warnings;

use constant DAY_UPBOUND => [[0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31], [0, 31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]];

sub is_leap {
    my $year = shift;
    return ( ($year % 400 == 0) || ($year % 100 != 0 && $year % 4 == 0) ) ? 1 : 0;
} # is_leap

sub step_in {
    my $unit = shift;
    my $re = shift;
    my $year = (shift) + 0;
    my $mon = (shift) + 0;
    my $day = (shift) + 0;
    my $hour = (shift) + 0;
    my $min = (shift) + 0;
    my $sec = (shift) + 0;

    if ($unit eq "SEC") { $sec += 1; goto SEC; }
    if ($unit eq "MIN") { $min += 1; goto MIN; }
    if ($unit eq "HOUR") { $hour += 1; goto HOUR; }
    if ($unit eq "DAY") { $day += 1; goto DAY; }
    if ($unit eq "MON") { $mon += 1; goto MON; }
    if ($unit eq "YEAR") { $year += 1; goto YEAR; }

    SEC:
    if ($sec == 60) {
        $sec = 0;
        $min += 1;
    }

    MIN:
    if ($min == 60) {
        $min = 0;
        $hour += 1;
    }

    HOUR:
    if ($hour == 24) {
        $hour = 0;
        $day += 1;
    }

    DAY:
    if ($day == DAY_UPBOUND->[is_leap($year)][$mon] + 1) {
        $day = 1;
        $mon += 1;
    }

    MON:
    if ($mon == 13) {
        $mon = 1;
        $year += 1;
    }

    YEAR:
    my $tm = sprintf("%04d-%02d-%02d %02d:%02d:%02d", $year, $mon, $day, $hour, $min, $sec);
    my ($ret) = $tm =~ $re;
    return $ret;
} # step_in

my %list = ();

while (my $ln = <STDIN>) {
    chomp($ln);
    my ($ent, $val) = split(/[ \t]/, $ln);
    $list{ $ent } ||= {};
    $list{ $ent } = $val;
} # while

my @keys = sort(keys(%list));
my $ent = $keys[0];
my $max = $keys[-1];

do {
    my ($sec, $min, $hour, $day, $mon, $year) = localtime(time);
    my $next = "";
    $year += 1900;
    $mon += 1;

    if ($ent =~ m,^(\d{4}) ([-/]) (\d{2}) \2 (\d{2})$,x) {
        $year = $1;
        $mon = $3;
        $next = step_in('DAY', '^(\d{4}' . $2 . '\d{2}' . $2 . '\d{2})', $year, $mon, $day, $hour, $min, $sec);
    } elsif ($ent =~ m,^(\d{4}) ([-/]) (\d{2})$,x) {
        $year = $1;
        $mon = $3;
        $next = step_in('MON', '^(\d{4}' . $2 . '\d{2})', $year, $mon, $day, $hour, $min, $sec);
    } elsif ($ent =~ m,^(\d{2}) ([-/]) (\d{2})$,x) {
        $mon = $1;
        $day = $3;
        $next = step_in('DAY', '\b(\d{2}' . $2 . '\d{2})', $year, $mon, $day, $hour, $min, $sec);
    }

    if ($next and not exists($list{ $next })) {
        $list{ $next } = 0;
    }
    $ent = $next;
} while ($ent lt $max);

foreach my $ent (sort(keys(%list))) {
    printf "%s\t%s\n", $ent, $list{ $ent };
}
