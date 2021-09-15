#! /usr/bin/env perl

use v5.34;
use warnings;
no warnings 'experimental';

use Getopt::Long;
use Pod::Usage;
use File::Slurper 'read_text';
use File::Basename;


use Data::Show;

use lib ('lib');
use ExamLib::Parser 'parse_exam_file';
use ExamLib::Generate 'generate_random_exam';
use ExamLib::Util 'get_timestamp', 'write_text';

my $man = 0;
my $help = 0;

# Get command line options or show POD 
GetOptions(
  'help!' => \$help,
  'man!' => \$man,
) or pod2usage(1);

pod2usage(1) if $help;
pod2usage(-exitval => 0, -verbose => 2) if $man;

# Read command and input files from remaining arguments
my $command = shift @ARGV;
my @files = @ARGV;
if (@files == 0) {
  print "No input files specified\n\n";
  pod2usage(1);
}

# Switch based on command arg
given ($command) {
  when ($_ =~ /generate/) {
    cmd_generate();
  }

  default {
    print "No valid command specified.\n\n";
    pod2usage(1);
  }
}

# Generates a random exam file from one or multiple master files. (1a)
sub cmd_generate {
  for my $file (@files) {
    my $exam_file = read_text($file);
    my $exam = parse_exam_file($exam_file);

    my $generated_exam = generate_random_exam($exam);
    my $out_filename = get_timestamp() . '-' . basename($file);
    write_text($out_filename, $generated_exam);

    print "Generated exam file saved to $out_filename\n";
  }
}

#TODO Write POD
__END__
 
=head1 NAME
 
exam_cli - Perl final Project.
 
=head1 SYNOPSIS
 
exam_cli <command> [options] <input file>
  
Commands:

  generate    Generates a random exam file from one or multiple master files.

 
=head1 OPTIONS
 
=over 8
 
=item B<-help>
 
Print a brief help message and exits.
 
=item B<-man>
 
Prints the manual page and exits.
 
=back
 
=head1 DESCRIPTION
 
B<This program> Provides multiple tools to generate, analyze and grade text-based multiple choice exams.
 
=cut