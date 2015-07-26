#!/usr/bin/env perl
use strict;
use utf8;
use warnings;
use Getopt::Long qw(:config no_auto_abbrev no_ignore_case bundling);
use JSON ();
use Perl::PrereqDistributionGatherer;
use Pod::Usage;
sub say { print @_, "\n" }

@ARGV = map { /^(-I)(.+)/ ? ($1, $2) : $_ } @ARGV;

GetOptions
    "h|help" => sub { pod2usage },
    "f|format=s" => \(my $format = "plain"),
    "I=s@" => \(my $include = []),
or exit 1;

my ($method, $arg)
    = @ARGV ? ("gather", \@ARGV) : ("gather_from_cpanfile", "cpanfile");

$arg eq "cpanfile" && !-f "cpanfile"
    and do { warn "cpanfile or module arguments are required.\n"; pod2usage(1) };

my $gatherer = Perl::PrereqDistributionGatherer->new(inc => [@$include, @INC], fill_archlib => 1);
my ($dists, $core, $miss) = $gatherer->$method($arg);

if ($format eq "json") {
    my $json = JSON->new->pretty(1)->canonical(1)->utf8(1);
    print $json->encode({
        dists => [map { $_->distvname } @$dists],
        core  => $core,
        miss  => $miss,
    });
} else {
    say "\e[32mprereq dists\e[m";
    say " * $_" for map { $_->distvname } @$dists;
    say " * (none)" unless @$dists;

    say "\e[33mprereq core modules\e[m";
    say " * $_" for @$core;
    say " * (none)" unless @$core;

    say "\e[31mprereq but missing modules\e[m";
    say " * $_" for @$miss;
    say " * (none)" unless @$miss;
}

__END__

=head1 NAME

prereq-dist-dump.pl - dump prereq distributions

=head1 SYNOPSIS

    > prereq-dist-dump.pl [--format json] [MODULES]

    Options:
    -I directory        prepend include directories
    -f, --format json   output json
    -h, --help          show this help

    Eg:
    > perl prereq-dist-dump.pl -I local/lib/perl5
    # dump cpanfile prereq distributions

    > perl prereq-dist-dump.pl Plack Moose
    # dump Plack and Moose prereq distributions

=cut
