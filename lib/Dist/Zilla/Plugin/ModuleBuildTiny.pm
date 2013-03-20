package Dist::Zilla::Plugin::ModuleBuildTiny;
{
  $Dist::Zilla::Plugin::ModuleBuildTiny::VERSION = '0.004';
}

use Moose;
with qw/Dist::Zilla::Role::BuildPL Dist::Zilla::Role::TextTemplate Dist::Zilla::Role::PrereqSource/;

use Dist::Zilla::File::InMemory;
use Module::Metadata;
use MooseX::Types::Moose qw/Str/;

has version => (
	is      => 'ro',
	isa     => Str,
	default => sub {
		return Module::Metadata->new_from_module('Module::Build::Tiny')->version->stringify;
	},
);

has minimum_perl => (
	is      => 'ro',
	isa     => Str,
	lazy    => 1,
	default => sub {
		my $self = shift;
		return $self->zilla->prereqs->requirements_for('runtime', 'requires')->requirements_for_module('perl') || '5.006'
	},
);

my $template = "use {{ \$minimum_perl }};\nuse Module::Build::Tiny {{ \$version }};\nBuild_PL();\n";

sub register_prereqs {
	my ($self) = @_;

	$self->zilla->register_prereqs({ phase => 'configure' }, 'Module::Build::Tiny' => $self->version);

	return;
}

sub setup_installer {
	my ($self, $arg) = @_;

	my $content = $self->fill_in_string($template, { version => $self->version, minimum_perl => $self->minimum_perl });
	my $file = Dist::Zilla::File::InMemory->new({ name => 'Build.PL', content => $content });
	$self->add_file($file);

	return;
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

# ABSTRACT: Build a Build.PL that uses Module::Build::Tiny



__END__
=pod

=head1 NAME

Dist::Zilla::Plugin::ModuleBuildTiny - Build a Build.PL that uses Module::Build::Tiny

=head1 VERSION

version 0.004

=head1 DESCRIPTION

This plugin will create a F<Build.PL> for installing the dist using L<Module::Build::Tiny>.

=head1 ATTRIBUTES

=head2 version

B<Optional:> Specify the minimum version of L<Module::Build::Tiny> to depend on.

Defaults to the version installed on the author's perl installation

=head2 minimum_perl

B<Optional:> Specify the minimum version of perl to require in the F<Build.PL>.

This is normally taken from dzils prereq metadata.

=head1 AUTHOR

Leon Timmermans <fawaka@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Leon Timmermans.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

