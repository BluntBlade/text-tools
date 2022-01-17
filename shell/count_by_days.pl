#!/usr/bin/env perl

use strict;
use warnings;

sub is_sunday {
    my $epoch = shift;
    my (undef, undef, undef, undef, undef, undef, $wday) = localtime($epoch);
    return $wday == 0;
} # is_sunday

sub to_epoch {
    my $date = shift;
    return qx/date -d'$date' +'%s'/;
} # to_epoch

sub to_date {
    my $epoch = shift;

    my ($sec, $min, $hour, $day, $mon, $year) = localtime($epoch);
    return sprintf("%04d-%02d-%02d", $year + 1900, $mon + 1, $day);
} # to_date

sub format_date {
    my $date = shift;
    if ($date !~ m/^\d{4}-\d{2}-\d{2}$/) {
        return to_date(to_epoch($date));
    }
    return $date;
} # format_date

sub calculate_first_epoch {
    my $epoch = shift;
    my ($sec, $min, $hour, $day, $mon, $year) = localtime($epoch);
    return to_epoch(sprintf("%04d-%02d-%02d", $year + 1900, 1, 1));
} # calculate_first_epoch

sub calculate_last_epoch {
    my $epoch = shift;
    my ($sec, $min, $hour, $day, $mon, $year) = localtime($epoch);
    return to_epoch(sprintf("%04d-%02d-%02d", $year + 1900, 12, 31));
} # calculate_last_epoch

sub calculate_next_epoch {
    return (shift) + 86400;
} # calculate_next_epoch

my %counts = ();

while (my $date = <>) {
    chomp($date);
    $date = format_date($date);
    $counts{$date} ||= 0;
    $counts{$date} += 1;
} # while

my @dates = sort(keys(%counts));
my $first_epoch = calculate_first_epoch(to_epoch($dates[0]));
my $last_epoch = calculate_last_epoch(to_epoch($dates[-1]));

for (my $curr_epoch = $first_epoch; $curr_epoch <= $last_epoch; $curr_epoch = calculate_next_epoch($curr_epoch)) {
    my $curr_date = to_date($curr_epoch);
    my $val = ($counts{$curr_date} || 0);
    if ($val == 0 and is_sunday($curr_epoch)) {
        $val = "S";
    }
    printf "%s", $val;
    if ($curr_date =~ m/^\d{4}-(?:0[13578]-31|1[02]-31|0[469]-30|11-30|02-2[89])$/) {
        printf "\n";
    } else {
        printf "\t";
    }
} # for
