#! /usr/bin/env perl

use v5.34;
use warnings;
no warnings 'experimental';

use File::Slurper 'read_text';
use File::Basename;

use lib ('lib');
use ExamLib::Parser 'parse_exam_file';
use ExamLib::Generate 'generate_random_exam';
use ExamLib::Util 'get_timestamp', 'write_text';

my @files = @ARGV;
if (@files == 0) {
  print "No input files specified\n\n";
}

for my $file (@files) {
  my $exam_file = read_text($file);
  my $exam = parse_exam_file($exam_file);

  my $generated_exam = generate_random_exam($exam);
  my $out_filename = get_timestamp() . '-' . basename($file);
  write_text($out_filename, $generated_exam);

  print "Generated exam file saved to $out_filename\n";
}
