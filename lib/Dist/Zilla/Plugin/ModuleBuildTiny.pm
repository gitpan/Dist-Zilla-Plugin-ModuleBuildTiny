package Dist::Zilla::Plugin::ModuleBuildTiny;
{
  $Dist::Zilla::Plugin::ModuleBuildTiny::VERSION = '0.003';
}

use Moose;
with qw/Dist::Zilla::Role::BuildPL Dist::Zilla::Role::TextTemplate Dist::Zilla::Role::PrereqSource/;
use Module::Metadata;

use Dist::Zilla::File::InMemory;

use version;
use MooseX::Types::Perl qw(VersionObject);

has version => (
	is  => 'rw',
	isa => VersionObject,
	default => sub {
		return Module::Metadata->new_from_module('Module::Build::Tiny')->version;
	},
	coerce => 1,
);

my $template = "use Module::Build::Tiny {{ \$version }};\nBuild_PL();\n";

sub register_prereqs {
	my ($self) = @_;

	$self->zilla->register_prereqs({ phase => 'configure' }, 'Module::Build::Tiny' => $self->version);

	return;
}

sub setup_installer {
	my ($self, $arg) = @_;

	my $content = $self->fill_in_string($template, { version => $self->version });
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

version 0.003

=head1 DESCRIPTION

This plugin will create a F<Build.PL> for installing the dist using L<Module::Build::Tiny>.

=head1 ATTRIBUTES

=head2 version

B<Optional:> Specify the minimum version of L<Module::Build::Tiny> to depend on.

Defaults to the version installed on the author's perl installation

=head1 AUTHOR

Leon Timmermans <fawaka@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Leon Timmermans.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

