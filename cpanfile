requires 'perl', '5.008001';
requires 'CPAN::Meta';
requires 'CPAN::Meta::Requirements';
requires 'Distribution::Metadata', '0.02';
requires 'JSON';
requires 'Module::CPANfile';

on 'test' => sub {
    requires 'Test::More', '0.98';
};
