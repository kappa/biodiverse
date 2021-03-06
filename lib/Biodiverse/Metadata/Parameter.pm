package Biodiverse::Metadata::Parameter;
use strict;
use warnings;

#  Mostly needed by Biodiverse::GUI::ParametersTable,
#  with params and specified extensively in import and export metadata

use 5.016;
use Carp;
use Readonly;
use Scalar::Util qw /reftype/;

use parent qw /Biodiverse::Metadata/;

our $VERSION = '1.0_002';

#sub new {
#    my ($class, $data) = @_;
#    $data //= {};
#    
#    my $self = bless $data, $class;
#    return $self;
#}


#  Poss too many, but we are a catch-all class.
my %methods_and_defaults = (
    name        => '',
    label_text  => '',
    tooltip     => '',
    type        => '',
    choices     => [],
    default     => '',
    sensitive   => 1,
    min         => undef,
    max         => undef,
    digits      => undef,
    increment   => 1,
    always_sensitive => undef,
    box_group   => undef,
);

sub _get_method_default_hash {
    return wantarray ? %methods_and_defaults : {%methods_and_defaults};
}

__PACKAGE__->_make_access_methods (\%methods_and_defaults);



1;
