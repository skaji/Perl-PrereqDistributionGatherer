# NAME

Perl::PrereqDistributionGatherer - gather all prerequisite distributions

# SYNOPSIS

    use Perl::PrereqDistributionGatherer;

    my $gatherer = Perl::PrereqDistributionGatherer->new;

    my ($dists, $core, $miss) = $gatherer->gather(["Plack", "Moose"]);

    # or, from cpanfile
    my ($dists, $core, $miss) = $gatherer->gather_from_cpanfile("cpanfile");

# DESCRIPTION

Perl::PrereqDistributionGatherer gathers all prerequisite distributions for some modules.

# METHODS

### `my $gatherer = Perl::PrereqDistributionGatherer->new`

Constructor. Currently any arguments are ignored.

### `my ($dists, $core, $miss) = $gatherer->gather($modules, %option)`

Gatherer distributions which are prerequisite for `$modules`.
The return values are:

- `$dists`

    Array reference of prerequisite distributions, which are instances of [Distribution::Metadata](https://metacpan.org/pod/Distribution::Metadata).

- `$core`

    Array reference of prerequisite core modules.

- `$miss`

    Array reference of missed modules.

`%option` may be:

- inc

    The search path of modules. Default: `\@INC`.

### `my ($dists, $core, $miss) = $gatherer->gather_from_cpanfile($cpanfile_path, %option)`

This is convenient method, which gathers prerequisite distributions by modules stated in `cpanfile`.
The return values and `%option` are the same as the `gather` method.

# SEE ALSO

[Carton](https://metacpan.org/pod/Carton)

[https://github.com/miyagawa/Carmel](https://github.com/miyagawa/Carmel)

[Distribution::Metadata](https://metacpan.org/pod/Distribution::Metadata)

[Module::Metadata](https://metacpan.org/pod/Module::Metadata)

# LICENSE

Copyright (C) Shoichi Kaji.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# AUTHOR

Shoichi Kaji <skaji@cpan.org>
