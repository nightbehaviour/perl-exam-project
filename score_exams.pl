#! /usr/bin/env perl

use v5.34;
use warnings;
no warnings 'experimental';

use File::Slurper 'read_text';
use List::Util 'first';

use lib ('lib');
use ExamLib::Parser 'parse_exam_file', 'get_questions';
use ExamLib::Util 'get_timestamp', 'write_text';
use ExamLib::Language 'normalize', 'compare_edit_distance';

my @files = @ARGV;
if (@files == 0) {
  die "No input files specified\n\n";
}

# Load and parse the master exam file
my $master_filename = shift @files;
my $master_file = read_text($master_filename);
my $master_exam = parse_exam_file($master_file);

my @master_questions = get_questions($master_exam);
my $num_questions = @master_questions;

# Print some statistics about the master file
my $divider = "________________________________________________________________________________\n\n";

print "Master File: $master_filename\n";
print "Number of questions: $num_questions\n";
print $divider;

# Loop through each solution
for my $file (@files) {
  print $file . "\n";

  # Load and parse the student file
  my $exam_file = read_text($file);
  my $exam = parse_exam_file($exam_file);
  my @questions = get_questions($exam);
  
  # Test statistics
  my $num_correct = 0;
  my $num_answered = 0;

  # Loop through master questions
  for my $master_question (@master_questions) {
    my $master_question_text = $master_question->{'question_text'}->{'text'};
    my $master_question_number = $master_question->{'question_text'}->{'question_number'};

    # Try to find the question in the student file
    my $student_question = first { compare_edit_distance($master_question_text, $_->{'question_text'}->{'text'}) } @questions or do{
      print "Missing Question: $master_question_text";
      next;
    };

    my @master_answers = @{$master_question->{'answer'}};
    my @student_answers = @{$student_question->{'answer'}};

    my $question_score = 0;
    my $num_checked = 0;

    # Iterate through master answers
    for my $answer (@master_answers) {
      my $master_answer_text = $answer->{'text'};

      # Try to find the answer option in the student's file
      # First we try to find an exact match
      my $student_answer;
      $student_answer = first { $master_answer_text eq $_->{'text'} } @student_answers or do {
        # Try to find a fuzzy match.
        $student_answer = first { compare_edit_distance($master_answer_text, $_->{'text'}) } @student_answers or do {
          print "Missing answer in question $master_question_number: $master_answer_text";
          next;
        };
        print "Warning: Fuzzy matching answers in question ". $master_question_number . " This may lead to inexact scoring.\n";
      };

      # Evaluate checkboxes on master and student files
      my $is_correct = is_checked($answer->{'checkbox'});
      my $student_checked = is_checked($student_answer->{'checkbox'});

      if ($student_checked) {
        $num_checked++; # Count how many boxes have been checked
        $question_score = 1 if $is_correct; # Student checked the correct answer
      }
    }

    # If at least one checkbox was checked, an answer exists
    if ($num_checked > 0) {
      $num_answered++;
    }

    # If more than one box was checked, the answer is invalid
    if ($num_checked <= 1) {
      $num_correct += $question_score;
    }
    else {
      print "Answer invalid in question $master_question_number: student checked multiple answers\n"
    }
  }

  print "Correct: $num_correct/$num_answered\n";
  print $divider;
}

sub is_checked {
  my ($checkbox) = @_;
  return $checkbox =~ /\[\s*[Xx]\s*\]/;
}