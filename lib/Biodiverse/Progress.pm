package Biodiverse::Progress;
use strict;
use warnings;
use English qw { -no_match_vars };
use Carp;
use POSIX qw /fmod/;
use List::Util qw /max min/;
my $NULL_STRING = q//;

require Biodiverse::Config;
use Biodiverse::Exception;

our $VERSION = '0.99_001';

sub new {
    my $class = shift;
    my %args = @_;

    my $report_int = $Biodiverse::Config::progress_update_interval_pct;
    my $hash_ref = {
        gui_progress       => undef,
        last_text          => $NULL_STRING,
        print_text         => 1,
        last_reported_prog => -1,
        report_interval    => $report_int,  #  in percent
        gui_only           => 0,  #  only feedback via GUI
        %args,  #  override if user says so
    };

    my $self = bless $hash_ref, $class;

    return $self
      if    $Biodiverse::Config::progress_no_use_gui
        || !$Biodiverse::Config::running_under_gui;

    #  if we are to use the GUI
    #print "RUNNING UNDER GUI:  $Biodiverse::Config::running_under_gui\n";
    if ($Biodiverse::Config::running_under_gui) {
        my $gui_progress;
        eval q{
            require Biodiverse::GUI::ProgressDialog;
            $gui_progress = Biodiverse::GUI::ProgressDialog->new($args{text});  #  should pass on all relevant args
        };
        my $e = $EVAL_ERROR;
        if (! $e and defined $gui_progress) {
            #  if we are in the GUI then we can use a GUI progress dialogue
            $self->{gui_progress} = $gui_progress;
        }
        warn $e if $e;
    }

    return $self;
}


sub destroy {
    my $self = shift;
    
    if ($self->{gui_progress}) {
        eval {$self->{gui_progress}->destroy};
    }

    $self->reset();

    return;
}

sub update {
    my $self     = shift;
    my $text     = shift;
    my $progress = shift; # fraction 0 .. 1
    my $no_update_text = shift;

    croak "No progress set\n" if not defined $progress;

    #  no point doing anything if these conditions are true
    return if $self->{gui_only} && !$self->{gui_progress};

    #  make it tolerant
    $progress = max (0, min (1, $progress));

    if ($self->{gui_progress}) {
        eval {$self->{gui_progress}->update ($text, $progress)};
        if ( Biodiverse::GUI::ProgressDialog::Bounds->caught() ) {
            $EVAL_ERROR->rethrow;
        }
        elsif ( Biodiverse::GUI::ProgressDialog::Cancel->caught() ) {
            $EVAL_ERROR->rethrow;
        }
    }

    return if $self->{gui_only};

    $text //= $NULL_STRING;

    #  trapped above now
    #croak "ERROR [Progress] progress $progress is not between 0 & 1\n"
    #  if ($progress < 0 || $progress > 1);

    #  do something with the text if it differs
    if ($self->{print_text}) {
        print $text . q{     };  #  five spaces
    }
    $self->{print_text} = 0;

    my $prog_pct = int ($progress * 100);
    my $interval = $self->{report_interval};
    return if $prog_pct % $interval != 0 and $self->{last_reported_prog} != -1;
    return if $prog_pct == $self->{last_reported_prog};

    $self->{last_reported_prog} = $prog_pct;

    #  Update the percent progress.
    #  Use printf for a consistent string length.
    printf "\b\b\b\b%3i%%", $prog_pct;

    return;
}

#  need a better name?
sub close_off {
    my $self = shift;
    $self->reset;
    if (!$self->{gui_only}) {
        print "\n";
    }
    return;
}

#  close off this line
sub reset {
    my $self = shift;
    
    $self->{last_text}          = $NULL_STRING;
    $self->{print_text}         =  1;
    $self->{last_reported_prog} = -1;

    #print "\n";

    return;
}

sub pulsate {
    my $self = shift;
    
    eval {$self->{gui_progress} -> pulsate (@_)};

    return;
}

sub pulsate_stop {
    my $self = shift;
    
    eval {$self->{gui_progress} -> pulsate_stop (@_)};
    
    return;
}

sub pulse_progress_bar {
    my $self = shift;
    
    eval {$self->{gui_progress} -> pulsate_progress_bar (@_)};
    
    return;
}

sub DESTROY {
    my $self = shift;
    $self->close_off;
    if ($self->{gui_progress}) {  #  can't use an eval here as it resets $EVAL_ERROR
        $self->{gui_progress}->destroy;  #  take care of any GUI progress
    }
    
    delete @$self{keys %$self};             #  clean out all keys, prob not needed
}

1;


=head1 NAME

Biodiverse::Progress

=head1 SYNOPSIS

  use Biodiverse::Progress;
  my $progress = Biodiverse::Progress->new();

=head1 DESCRIPTION

Provide feedback about progress.
Uses a Biodiverse::GUI::ProgressDialog object if the GUI is running,
console text otherwise.

=head1 METHODS

=over

=item NEED TO INSERT METHODS
also valid arguments

=back

=head1 REPORTING ERRORS

Use the issue tracker at http://www.purl.org/biodiverse

=head1 COPYRIGHT

Copyright (c) 2010 Shawn Laffan. All rights reserved.  

=head1 LICENSE

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

For a full copy of the license see <http://www.gnu.org/licenses/>.

=cut

1;
