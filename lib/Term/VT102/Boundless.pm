#!/usr/bin/perl

package Term::VT102::Boundless;
use base qw/Term::VT102/;

use strict;
use warnings;

our $VERSION = "0.01";

sub new {
	my $self = shift->SUPER::new( @_, rows => 1, cols => 1 );

}

sub _process_text {
	my $self = shift;
	my ($text) = @_;

	return if ($self->{'_xon'} == 0);

	substr (
	  ($self->{'scrt'}->[$self->{'y'}] ||= (" " x $self->{'x'})), $self->{'x'} - 1,
	  length $text
	) = $text;

	substr (
	  $self->{'scra'}[$self->{'y'}] ||=(Term::VT102::DEFAULT_ATTR_PACKED x $self->{'x'}), 2 * ($self->{'x'} - 1),
	  2 * (length $text)
	) = $self->{'attr'} x (length $text);

	my $newcols = length( $self->{'scrt'}->[$self->{'y'}] );
	$self->{'cols'} = $newcols if $newcols > $self->{'cols'};

	$self->{'x'} += length $text;

	$self->callback_call ('ROWCHANGE', $self->{'y'}, 0);
}

sub _code_CUD {                         # move cursor down
	my $self = shift;
	my $num = shift;
	$num = 1 if (not defined $num);
	$num = 1 if ($num < 1);

	$self->{'y'} += $num;
	return if ($self->{'y'} <= $self->{'srb'});

	$self->{'srb'} = $self->{'rows'} = $self->{'y'};
}

sub row_attr {
	my $self = shift;
	$self->_extend_row( $_[0] );
	$self->SUPER::row_attr( @_ );
}

sub row_text {
	my $self = shift;
	$self->_extend_row( $_[0] );
	$self->SUPER::row_text( @_ );
}

sub _extend_row {
	my ( $self, $row ) = @_;

	if ( (my $extend = $self->{cols} - length($self->{scrt}[$row]))  > 0 ) {
		$self->{scra}[$row] .= Term::VT102::DEFAULT_ATTR_PACKED x $extend;
		$self->{scrt}[$row] .= (" " x $extend);
	}
}

__PACKAGE__;

__END__

=pod

=head1 NAME

Term::VT102::Boundless - A L<Term::VT102> that grows automatically to
accomodate whatever you print to it.

=head1 SYNOPSIS

	use Term::VT102::Boundless;

=head1 DESCRIPTION

Useful in conjuntion with L<HTML::FromANSI> when you don't have the full text -
you can append lines, and render without reprocessing all of the textual input.

=cut


