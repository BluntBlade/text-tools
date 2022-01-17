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

my %raw_counts = ();

while (my $date = <>) {
    chomp($date);
    $date = format_date($date);
    $raw_counts{$date} ||= 0;
    $raw_counts{$date} += 1;
} # while

my @dates = sort(keys(%raw_counts));
my $first_epoch = calculate_first_epoch(to_epoch($dates[0]));
my $last_epoch = calculate_last_epoch(to_epoch($dates[-1]));

my @counts = (
    [ 0 x 31 ], # 1
    [ 0 x 28 ], # 2
    [ 0 x 31 ], # 3
    [ 0 x 30 ], # 4
    [ 0 x 31 ], # 5
    [ 0 x 30 ], # 6
    [ 0 x 31 ], # 7
    [ 0 x 31 ], # 8
    [ 0 x 30 ], # 9
    [ 0 x 31 ], # 10
    [ 0 x 30 ], # 11
    [ 0 x 31 ], # 12
);

for (my $curr_epoch = $first_epoch; $curr_epoch <= $last_epoch; $curr_epoch = calculate_next_epoch($curr_epoch)) {
    my $curr_date = to_date($curr_epoch);
    my (undef, undef, undef, $day, $mon, $year) = localtime($curr_epoch);
    $mon += 1;

    my $val = $raw_counts{$curr_date};

    if (! defined($val)) {
        $val = 0;
    }
    if ($val == 0 and is_sunday($curr_epoch)) {
        $val = "S";
    }
    if ($mon == 2 and $day == 29) {
        push @{$counts[$mon - 1]}, $val;
    } else {
        $counts[$mon - 1][$day - 1] = $val;
    }
} # for

for my $values (values(@counts)) {
    printf "%s\n", join("\t", @$values);
} # for
