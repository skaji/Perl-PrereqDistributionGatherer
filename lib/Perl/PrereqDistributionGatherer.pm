package Perl::PrereqDistributionGatherer;
use 5.008001;
use strict;
use warnings;
use CPAN::Meta::Requirements;
use CPAN::Meta;
use Distribution::Metadata::Factory;
use Module::CPANfile;

our $VERSION = "0.01";

sub new {
    my ($class, %option) = @_;
    my $factory = Distribution::Metadata::Factory->new(
        inc => $option{inc} || \@INC, fill_archlib => $option{fill_archlib}
    );
    bless { factory => $factory }, $class;
}

sub gather {
    my ($self, $modules) = @_;
    my (@dist, %core, %missing, %seen);
    for my $module (@$modules) {
        $self->_gather(\@dist, $module, \%core, \%missing, \%seen);
    }
    return (
        [ sort { $a->distvname cmp $b->distvname } @dist ],
        [ sort keys %core ],
        [ sort keys %missing ],
    );
}

sub gather_from_cpanfile {
    my ($self, $cpanfile) = @_;
    my @module = Module::CPANfile->load($cpanfile)
        ->merged_requirements->required_modules;
    $self->gather(\@module);
}

# TODO: gather distributions as tree
sub _gather {
    my ($self, $result, $module, $core, $missing, $seen) = @_;

    return if $module eq "perl";
    return if $core->{ $module };
    return if $missing->{ $module };
    return if $seen->{ $module }++;

    my $dist = $self->{factory}->create_from_module($module);
    if ( ($dist->name || "") eq "perl" ) {
        $core->{ $module }++;
        return;
    }
    my $meta_file = $dist->mymeta_json;
    unless ($meta_file) {
        $missing->{$module}++;
        return;
    }
    if ( my $provids = ( $dist->install_json_hash || +{} )->{provides} ) {
        $seen->{$_}++ for keys %$provids;
    }

    push @$result, $dist;
    my $prereqs = CPAN::Meta->load_file($meta_file)->effective_prereqs;
    my $reqs = CPAN::Meta::Requirements->new;
    $reqs->add_requirements($prereqs->requirements_for($_, 'requires'))
        for qw( configure build runtime );
    for my $module ($reqs->required_modules) {
        $self->_gather( $result, $module, $core, $missing, $seen );
    }
}

1;
__END__

=encoding utf-8

=head1 NAME

Perl::PrereqDistributionGatherer - gather all prerequisite distributions

=head1 SYNOPSIS

    use Perl::PrereqDistributionGatherer;

    my $gatherer = Perl::PrereqDistributionGatherer->new;

    my ($dists, $core, $miss) = $gatherer->gather(["Plack", "Moose"]);

    # or, from cpanfile
    my ($dists, $core, $miss) = $gatherer->gather_from_cpanfile("cpanfile");

=head1 DESCRIPTION

Perl::PrereqDistributionGatherer gathers all prerequisite distributions for some modules.

=head1 METHODS

=over 4

=item * C<< my $gatherer = Perl::PrereqDistributionGatherer->new(%option) >>

Constructor. C<%option> may be:

=over 4

=item * inc

The search path of modules. Default: C<\@INC>.

=item * fill_archlib

If this is true, then prepend archlib to inc directories.

=back

=item * C<< my ($dists, $core, $miss) = $gatherer->gather($modules) >>

Gatherer distributions which are prerequisite for C<$modules>.
The return values are:

=over 4

=item * C<$dists>

Array reference of prerequisite distributions, which are instances of L<Distribution::Metadata>.

=item * C<$core>

Array reference of prerequisite core modules.

=item * C<$miss>

Array reference of missed modules.

=back

=item * C<< my ($dists, $core, $miss) = $gatherer->gather_from_cpanfile($cpanfile_path) >>

This is convenient method, which gathers prerequisite distributions by modules stated in C<cpanfile>.
The return values is the same as the C<gather> method.

=back

=head1 SEE ALSO

L<Carton>

L<https://github.com/miyagawa/Carmel>

L<Distribution::Metadata>

L<Module::Metadata>

=head1 LICENSE

Copyright (C) 2016 Shoichi Kaji <skaji@cpan.org>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Shoichi Kaji E<lt>skaji@cpan.orgE<gt>

=cut

